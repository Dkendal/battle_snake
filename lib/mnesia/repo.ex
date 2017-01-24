defmodule Mnesia.RecordNotFoundError do
  defexception [:table, :id]

  def message(%{table: table, id: id}),
    do: "Couldn't find #{inspect table} with id=#{id}"
end

defmodule Mnesia.Repo do
  @moduledoc """
  Thin wrapper between Ecto and Mnesia, allows Ecto.Changeset's to be used in
  conjunction with ETS.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      def table, do: [attributes: fields()]

      def fields, do: __schema__(:fields)

      def record(struct) do
        get = &Map.get(struct, &1)
        attrs = Enum.map(fields(), get)
        List.to_tuple [__MODULE__ |attrs]
      end

      def load(record) do
        [__MODULE__ |attrs] = Tuple.to_list(record)
        attrs = Enum.zip(fields(), attrs)
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
        load(:mnesia.last(__MODULE__))
      end

      def save(struct) do
        write = fn ->
          :mnesia.write(record(struct))
        end

        {:atomic, :ok} = :mnesia.transaction(write)

        struct
      end

      def get(id) do
        read = fn ->
          :mnesia.read(__MODULE__, id)
        end

        with {:atomic, [record]} <- :mnesia.transaction(read) do
          {:ok, load(record)}
        else
          {:atomic, []} ->
            {:error, %Mnesia.RecordNotFoundError{id: id, table: __MODULE__}}
        end
      end

      @spec create_table(Keyword.t) :: {:atomic, :ok} | {:aborted, any}
      def create_table(opts \\ []) do
        :mnesia.create_table(__MODULE__, opts ++ table())
      end

      def delete_table do
        :mnesia.delete_table(__MODULE__)
      end
    end
  end
end
