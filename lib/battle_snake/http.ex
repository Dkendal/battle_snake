defmodule BattleSnake.HTTP do
  use HTTPoison.Base

  @spec process_request_body(struct) :: String.t
  def process_request_body(struct) do
    Poison.encode!(struct)
  end

  def process_request_headers(headers) do
    put_in(headers, [:"content-type"], "application/json")
  end
end
