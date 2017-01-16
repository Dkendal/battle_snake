defmodule BattleSnake.HTTP do
  use HTTPoison.Base

  def process_request_headers(headers) do
    put_in(headers, [:"content-type"], "application/json")
  end
end
