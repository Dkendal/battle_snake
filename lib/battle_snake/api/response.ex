defmodule BattleSnake.Api.Response do
  alias __MODULE__

  @type error :: {:error, any} | {:error, :no_response}
  @type raw_response :: {:ok, HTTPoison.Response.t} | error
  @type parsed_response :: {:ok, map | struct} | error
  @type t :: %__MODULE__{
    raw_response: raw_response,
    parsed_response: parsed_response
  }

  @no_response {:error, :no_response}

  @moduledoc """
  An api response. Contains the raw response and parsed details.
  """

  defstruct [
    raw_response: {:error, :init},
    parsed_response: {:error, :init}
  ]

  @spec parse(t, as: struct) :: parsed_response
  def parse(response, as: as) do
    parsed_response =
      with({:ok, %HTTPoison.Response{} = raw} <- response.raw_response,
           body = raw.body,
           parsed_result = Poison.decode(body, as: as)) do
        parsed_result
      else
        {:error, _} ->
          @no_response
      end

    put_in(response.parsed_response, parsed_response)
  end

  @spec new(raw_response, as: struct) :: t
  def new(raw_response, as: as) do
    parse(%__MODULE__{raw_response: raw_response}, as: as)
  end

  @spec val(t) :: parsed_response
  def val(response) do
    response.parsed_response
  end
end
