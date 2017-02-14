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

  def save(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.apply_changes()
    |> save()
  end

  def save(struct) do
    module = struct.__struct__

    struct = if module.should_generate_primary_key?(struct),
      do: module.generate_primary_key(struct),
      else: struct

    {created_at, updated_at} = module.timestamps()

    struct = if Map.has_key?(struct, created_at) do
      Map.update(struct, created_at, nil, &keep_timestamp/1)
    else
      struct
    end

    struct = if Map.has_key?(struct, updated_at) do
      Map.update(struct, updated_at, nil, &put_timestamp/1)
    else
      struct
    end

    write = fn ->
      :mnesia.write(module.record(struct))
    end

    {:atomic, :ok} = :mnesia.transaction(write)

    struct
  end

  def reload(struct) do
    struct
    |> struct.__struct__.get_primary_key
    |> struct.__struct__.get
  end

  def dirty_find!(tab, id) do
    case dirty_find(tab, id) do
      {:ok, r} -> r
      {:error, e} -> raise e
    end
  end

  def dirty_find(tab, id) do
    with [record] <- :mnesia.dirty_read(tab, id) do
      {:ok,
       Mnesia.Repo.load(record)}
    else
      [] ->
        {:error,
         %Mnesia.RecordNotFoundError{id: id, table: tab}}
    end
  end

  def load(record) when is_tuple(record) do
    [table_name |attrs] = Tuple.to_list(record)
    attrs = Enum.zip(table_name.fields, attrs)
    struct(table_name, attrs)
  end

  def load(l, acc \\ [])

  def load([], acc) do
    acc
  end

  def load([h|t], acc) do
    load(t, [load(h)|acc])
  end

  def all(module) when is_atom(module) do
    fn ->
      :qlc.e(:mnesia.table module.table_name)
    end
    |> :mnesia.async_dirty()
    |> Enum.map(&module.load/1)
  end

  defp keep_timestamp(nil), do: System.monotonic_time()
  defp keep_timestamp(time), do: time
  defp put_timestamp(_), do: System.monotonic_time()

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @behaviour unquote(__MODULE__)
      @primary_key {:id, :id, autogenerate: true}
      @timestamps {:created_at, :updated_at}

      def timestamps() do
        @timestamps
      end

      def table, do: [attributes: fields()]

      def record(struct) do
        get = &Map.get(struct, &1)
        attrs = Enum.map(fields(), get)
        List.to_tuple [table_name() |attrs]
      end

      def load(record) do
        [mod |attrs] = Tuple.to_list(record)
        attrs = Enum.zip(mod.fields(), attrs)
        struct(mod, attrs)
      end

      def fields do
        __schema__(:fields)
      end

      def all() do
        Mnesia.Repo.all(__MODULE__)
      end

      def last do
        load(:mnesia.last(table_name()))
      end

      def get(id) do
        read = fn ->
          :mnesia.read(table_name(), id)
        end

        with {:atomic, [record]} <- :mnesia.transaction(read) do
          {:ok, Mnesia.Repo.load(record)}
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

      def get_primary_key(struct) do
        Map.fetch!(struct, primary_key_field())
      end

      defp primary_key_field() do
        {field, _, _} = @primary_key
        field
      end

      defp primary_key_opts() do
        {_, _, opts} = @primary_key
        opts
      end

      def generate_primary_key(%{__struct__: __MODULE__} = struct) do
        Map.put(struct, primary_key_field(), Ecto.UUID.generate())
      end

      def should_generate_primary_key?(%{__struct__: __MODULE__} = struct) do
        get_primary_key(struct) == nil and
        {:ok, true} == Keyword.fetch(primary_key_opts(), :autogenerate)
      end

      defp keep_timestamp(nil), do: System.monotonic_time()
      defp keep_timestamp(time), do: time

      defp put_timestamp(_), do: System.monotonic_time()

      defoverridable [fields: 0]
    end
  end
end
