defmodule Mnesia.Repo do
  @moduledoc """
  Thin wrapper between Ecto and Mnesia, allows Ecto.Changeset's to be used in
  conjunction with ETS.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      def table, do: [attributes: fields]

      def fields, do: __schema__(:fields)

      def record(game) do
        get = &Map.get(game, &1)
        attrs = Enum.map(fields, get)
        List.to_tuple [__MODULE__ |attrs]
      end

      def load(record) do
        [__MODULE__ |attrs] = Tuple.to_list(record)
        attrs = Enum.zip(fields, attrs)
        struct(__MODULE__, attrs)
      end

      def all do
        fn ->
          :qlc.e(:mnesia.table __MODULE__)
        end
        |> :mnesia.async_dirty()
        |> Enum.map(&load/1)
      end

      def last do
        load :mnesia.last(__MODULE__)
      end

      def get(id) do
        read = fn ->
          :mnesia.read __MODULE__, id
        end

        {:atomic, [record]} = :mnesia.transaction read

        load(record)
      end
    end
  end
end
