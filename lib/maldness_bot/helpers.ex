defmodule MaldnessBot.Helpers do
  def format_user(%{"first_name" => first_name, "last_name" => last_name}),
    do: "#{first_name} #{last_name}"

  def format_user(%{"first_name" => first_name}), do: first_name
end
