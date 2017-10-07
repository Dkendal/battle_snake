defmodule BsWeb.EventView do
  use BsWeb, :view

  def render("snake.json", %{snake: snake}) do
    %{id: snake.id, url: snake.url}
  end

  def render("snakes.json", %{snakes: snakes}) do
    Phoenix.View.render_many snakes, __MODULE__, "snake.json", as: :snake
  end

  def render("response.json", %{response: response, tc: tc}) do
    %{
      tc: tc,
      status_code: response.status_code,
      body: response.body
    }
  end

  def render("error.json", %{error: error}) do
    msg = case error do
      %HTTPoison.Error{reason: :timeout} ->
        "timeout"

      %{message: message} ->
        message
    end

    %{error: msg}
  end
end
