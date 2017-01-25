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

  @doc """
  Precompilation callback. save/1 needs to be appended to module defintion
  because __struct__ must be defined first.
  """
  defmacro __before_compile__(_env) do
    quote do
      def save(%Ecto.Changeset{} = changeset) do
        changeset
        |> Ecto.Changeset.apply_changes()
        |> save()
      end

      def save(%__MODULE__{} = struct) do
        write = fn ->
          :mnesia.write(record(struct))
        end

        {:atomic, :ok} = :mnesia.transaction(write)

        struct
      end
    end
  end

  defmacro __using__(_) do
    quote do
      @before_compile unquote __MODULE__
      @table_name __MODULE__

      use Ecto.Schema

      def table, do: [attributes: fields()]

      def fields, do: __schema__(:fields)

      def record(struct) do
        get = &Map.get(struct, &1)
        attrs = Enum.map(fields(), get)
        List.to_tuple [@table_name |attrs]
      end

      def load(record) do
        [@table_name |attrs] = Tuple.to_list(record)
        attrs = Enum.zip(fields(), attrs)
        struct(@table_name, attrs)
      end

      def all do
        fn ->
          :qlc.e(:mnesia.table @table_name)
        end
        |> :mnesia.async_dirty()
        |> Enum.map(&load/1)
      end

      def last do
        load(:mnesia.last(@table_name))
      end

      def get(id) do
        read = fn ->
          :mnesia.read(@table_name, id)
        end

        with {:atomic, [record]} <- :mnesia.transaction(read) do
          {:ok, load(record)}
        else
          {:atomic, []} ->
            {:error, %Mnesia.RecordNotFoundError{id: id, table: @table_name}}
        end
      end

      @spec create_table(Keyword.t) :: {:atomic, :ok} | {:aborted, any}
      def create_table(opts \\ []) do
        :mnesia.create_table(@table_name, opts ++ table())
      end

      def delete_table do
        :mnesia.delete_table(@table_name)
      end

      def delete_all do
        :mnesia.clear_table(@table_name)
      end
    end
  end
end
