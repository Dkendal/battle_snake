defmodule Bs.HTTP do
  @callback post!(binary(), any(), HTTPoison.headers(), Keyword.t()) ::
              HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()
end
