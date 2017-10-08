defmodule Bs.Api.Response do
  @no_response {:error, :no_response}

  @moduledoc """
  An api response. Contains the raw response and parsed details.
  """

  defstruct [
    :url,
    raw_response: {:error, :init},
    parsed_response: {:error, :init}
  ]

  def parse(response, as: as) do
    parsed_response =
      with {:ok, %HTTPoison.Response{} = raw} <- response.raw_response,
           body = raw.body,
           parsed_result = Poison.decode(body, as: as) do
        parsed_result
      else
        {:error, _} ->
          @no_response
      end

    put_in(response.parsed_response, parsed_response)
  end

  def new(raw_response, as: as) do
    parse(%__MODULE__{raw_response: raw_response}, as: as)
  end

  def val(response) do
    response.parsed_response
  end
end
