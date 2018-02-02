defmodule Bs.Api do
  @http Application.get_env(:bs, :http)
  @headers ["content-type": "application/json"]

  @callback move(String, String, Keyword) :: String
  @callback start(String, String, Keyword) :: String

  def move(url, json, options \\ [])

  def move(url, json, options) do
    (url <> "/move")
    |> @http.post!(json, @headers, options)
  end

  def start(url, json, options \\ [])

  def start(url, json, options) do
    (url <> "/start")
    |> @http.post!(json, @headers, options)
  end
end
