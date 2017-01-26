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

  @callback fields() :: [atom]

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @behaviour unquote(__MODULE__)
      @primary_key {:id, :id, autogenerate: true}

      def table_name() do
        __MODULE__
      end

      def table, do: [attributes: fields()]

      def record(struct) do
        get = &Map.get(struct, &1)
        attrs = Enum.map(fields(), get)
        List.to_tuple [table_name() |attrs]
      end

      def load(record) do
        [_table_name |attrs] = Tuple.to_list(record)
        attrs = Enum.zip(fields(), attrs)
        struct(table_name(), attrs)
      end

      def fields do
        __schema__(:fields)
      end

      def all do
        fn ->
          :qlc.e(:mnesia.table table_name())
        end
        |> :mnesia.async_dirty()
        |> Enum.map(&load/1)
      end

      def last do
        load(:mnesia.last(table_name()))
      end

      def get(id) do
        read = fn ->
          :mnesia.read(table_name(), id)
        end

        with {:atomic, [record]} <- :mnesia.transaction(read) do
          {:ok, load(record)}
        else
          {:atomic, []} ->
            {:error, %Mnesia.RecordNotFoundError{id: id, table: table_name()}}
        end
      end

      @spec create_table(Keyword.t) :: {:atomic, :ok} | {:aborted, any}
      def create_table(opts \\ []) do
        :mnesia.create_table(table_name(), opts ++ table())
      end

      def delete_table do
        :mnesia.delete_table(table_name())
      end

      def change_table_copy_type(node, type) do
        :mnesia.change_table_copy_type(table_name(), node, type)
      end

      def delete_all do
        :mnesia.clear_table(table_name())
      end

      defp primary_key_field() do
        {field, _, _} = @primary_key
        field
      end

      defp primary_key_opts() do
        {_, _, opts} = @primary_key
        opts
      end

      defp get_primary_key(struct) do
        Map.fetch!(struct, primary_key_field())
      end

      def save(%Ecto.Changeset{} = changeset) do
        changeset
        |> Ecto.Changeset.apply_changes()
        |> save()
      end

      def generate_primary_key(%{__struct__: __MODULE__} = struct) do
        Map.put(struct, primary_key_field(), make_ref())
      end

      defp should_generate_primary_key(%{__struct__: __MODULE__} = struct) do
        get_primary_key(struct) == nil and
        {:ok, true} == Keyword.fetch(primary_key_opts(), :autogenerate)
      end

      def save(%{__struct__: __MODULE__} = struct) do
        struct = if should_generate_primary_key(struct),
          do: generate_primary_key(struct),
          else: struct

        write = fn ->
          :mnesia.write(record(struct))
        end

        {:atomic, :ok} = :mnesia.transaction(write)

        struct
      end

      defoverridable [fields: 0, table_name: 0]
    end
  end
end
