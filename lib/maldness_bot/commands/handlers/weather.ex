defmodule MaldnessBot.Commands.Handlers.Weather do
  @weather_url "https://api.openweathermap.org/data/2.5/weather"
  @geocode_url "https://api.openweathermap.org/geo/1.0/direct"
  @config Application.compile_env!(:maldness_bot, MaldnessBot.OpenWeather)
  @appid @config |> Keyword.fetch!(:key)

  alias MaldnessBot.TelegramAPI.API
  alias MaldnessBot.Models.User
  import MaldnessBot.Gettext

  def handle(arg, message, state) do
    query_params = %{
      "units" => Keyword.get(@config, :units, "metric"),
      "appid" => @appid,
      "lang" => Map.get(state, :language, "en")
    }

    case build_query_params(arg, message) do
      {:ok, search_params} ->
        Map.merge(query_params, search_params)
        |> query_openweather()
        |> send_message(message)

      {:error, "user does not have a location set"} ->
        send_error_message(message)
    end
  end

  defp emoji(2, _), do: "⛈"
  defp emoji(3, _), do: "🌧"
  defp emoji(5, _), do: "🌧"
  defp emoji(6, _), do: "🌨"
  defp emoji(7, 11), do: "🔥💨"
  defp emoji(7, 62), do: "🌋💨"
  defp emoji(7, rem) when rem in [1, 21, 41], do: "🌫"
  defp emoji(7, rem) when rem in [31, 51, 61], do: "🏜💨"
  defp emoji(7, rem) when rem in [71, 81], do: "🌪"
  defp emoji(8, 0), do: "☀️"
  defp emoji(8, 1), do: "🌤"
  defp emoji(8, 2), do: "⛅️"
  defp emoji(8, 3), do: "🌥"
  defp emoji(8, 4), do: "☁️"
  defp emoji(_, _), do: ""

  defp format_weather(%{"id" => id, "description" => desc}) do
    group = div(id, 100)
    remainder = rem(id, 100)

    [emoji(group, remainder), desc] |> Enum.join(" ")
  end

  @spec format_temp(float()) :: binary()
  defp format_temp(temp) do
    sign =
      cond do
        temp > 0 -> "+"
        temp < 0 -> "-"
      end

    f_temp = temp |> abs() |> Float.round(1) |> Float.to_string()

    "#{sign}#{f_temp}"
  end

  defp build_query_params(nil, message) do
    user = User.get_by_telegram(message["from"]["id"])

    with latitude when not is_nil(latitude) <- user.latitude,
         longitude when not is_nil(longitude) <- user.longitude do
      {:ok, %{lat: latitude, lon: longitude}}
    else
      _ -> {:error, "user does not have a location set"}
    end
  end

  defp build_query_params(location, _) do
    [%{"lat" => latitude, "lon" => longitude}] = query_geocoder(location)
    {:ok, %{lat: latitude, lon: longitude}}
  end

  defp query_openweather(params) do
    url =
      URI.parse(@weather_url)
      |> Map.put(:query, URI.encode_query(params))
      |> URI.to_string()

    Finch.build(:get, url)
    |> Finch.request(MaldnessBot.Finch)
    |> (fn {:ok, %Finch.Response{body: body}} -> body end).()
    |> Jason.decode!()
  end

  defp query_geocoder(query) do
    url =
      URI.parse(@geocode_url)
      |> Map.put(:query, URI.encode_query(%{q: query, limit: 1, appid: @appid}))
      |> URI.to_string()

    Finch.build(:get, url)
    |> Finch.request(MaldnessBot.Finch)
    |> (fn {:ok, %Finch.Response{body: body}} -> body end).()
    |> Jason.decode!()
  end

  defp send_message(
         %{
           "name" => city_name,
           "main" => %{
             "temp" => temperature,
             "feels_like" => feels_like
           },
           "weather" => weather
         },
         message
       ) do
    description = weather |> Enum.map_join(", ", &format_weather/1)
    temperature = format_temp(temperature)
    feels_like = format_temp(feels_like)

    text =
      gettext("%{city_name}: %{temperature} (feels like %{feels_like}), %{description}", %{
        city_name: city_name,
        temperature: temperature,
        feels_like: feels_like,
        description: description
      })

    API.send_message(message["chat"]["id"], text)
    :ok
  end

  defp send_error_message(message) do
    API.send_message(
      message["chat"]["id"],
      gettext(
        "Failed to get weather: no argument provided and you don't have a location set. Send a location and reply to it with /set_location."
      )
    )

    :ok
  end
end
