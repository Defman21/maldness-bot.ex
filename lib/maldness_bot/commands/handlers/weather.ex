defmodule MaldnessBot.Commands.Handlers.Weather do
  @base_url "https://api.openweathermap.org/data/2.5/weather"
  alias MaldnessBot.TelegramAPI.API
  import MaldnessBot.Gettext

  defp format_weather(%{"id" => id, "description" => desc}) do
    group = div(id, 100)
    remainder = rem(id, 100)

    icon =
      case group do
        2 ->
          "⛈"

        3 ->
          "🌧"

        5 ->
          "🌧"

        6 ->
          "🌨"

        7 ->
          case remainder do
            n when n in [1, 21, 41] -> "🌫"
            11 -> "🔥💨"
            n when n in [31, 51, 61] -> "🏜💨"
            62 -> "🌋💨"
            n when n in [71, 81] -> "🌪"
            _ -> ""
          end

        8 ->
          case remainder do
            0 -> "☀️"
            1 -> "🌤"
            2 -> "⛅️"
            3 -> "🌥"
            4 -> "☁️"
            _ -> ""
          end

        _ ->
          ""
      end

    [icon, desc] |> Enum.join(" ")
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

  def handle(arg, message) do
    open_weather = Application.fetch_env!(:maldness_bot, OpenWeather)

    url =
      URI.parse(@base_url)
      |> Map.put(
        :query,
        URI.encode_query(%{
          "units" => Keyword.get(open_weather, :units, "metric"),
          "appid" => Keyword.fetch!(open_weather, :key),
          "lang" => Keyword.get(open_weather, :lang, "en"),
          "q" => arg
        })
      )
      |> URI.to_string()

    %{
      "name" => city_name,
      "main" => %{
        "temp" => temperature,
        "feels_like" => feels_like
      },
      "weather" => weather
    } =
      Finch.build(:get, url)
      |> Finch.request(MaldnessBot.Finch)
      |> (fn {:ok, %Finch.Response{body: body}} -> body end).()
      |> Jason.decode!()

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
  end
end
