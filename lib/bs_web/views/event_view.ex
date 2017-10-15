defmodule BsWeb.EventView do
  use BsWeb, :view

  def render("permalink.json", %{permalink: permalink}) do
    %{id: permalink.id, url: permalink.url}
  end

  def render("snake_loaded.json", %{snake: snake}) do
    %{
      id: snake.id,
      url: snake.url,
      name: snake.name,
      taunt: snake.taunt,
      color: snake.color,
      headUrl: snake.head_url
    }
  end

  def render("permalinks.json", %{permalinks: permalinks}) do
    Phoenix.View.render_many(
      permalinks,
      __MODULE__,
      "permalink.json",
      as: :permalink
    )
  end

  def render("response.json", %{response: response, tc: tc}) do
    %{
      tc: tc,
      statusCode: response.status_code,
      body: response.body
    }
  end

  def render("error.json", %{error: error}) do
    msg =
      case error do
        %HTTPoison.Error{reason: reason} ->
          to_string(reason)

        %{message: message} ->
          message
      end

    %{error: msg}
  end
end
