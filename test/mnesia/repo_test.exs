defmodule Mnesia.RepoTest.Dummy do
  use Mnesia.Repo

  schema "dummy" do
    field :x, :integer, default: 0
    field :y, :integer, default: 0
  end
end

defmodule Mnesia.RepoTest do
  alias __MODULE__.Dummy
  use ExUnit.Case, async: false

  @struct %Dummy{id: 0, x: 1, y: 2}
  @record {Dummy, 0, 1, 2}

  describe "Mnesia.Repo.fields/0" do
    test "returns the column names" do
      assert Dummy.fields == [
        :id,
        :x,
        :y]
    end
  end

  describe "Mnesia.Repo.table/0" do
    test "returns the decleration for mnesia" do
      assert Dummy.table == [
        attributes: [
          :id,
          :x,
          :y]]
    end
  end

  describe "Mnesia.Repo.record/1" do
    test "converts the struct to a record" do
      assert Dummy.record(@struct) == @record
    end
  end

  describe "Mnesia.Repo.load/1" do
    test "converts the struct to a record" do
      assert Dummy.load(@record) == @struct
    end
  end

  describe "Mnesia.Repo.save/1" do
    setup [:create_table, :delete_table]

    test "writes the record to mnesia" do
      assert @struct == Dummy.save(@struct)
      assert 1 == :mnesia.table_info(Dummy, :size)
    end
  end

  describe "Mnesia.Repo.get/1" do
    setup [:create_table, :delete_table, :create_dummy]

    test "returns the record", %{dummy: dummy} do
      assert {:ok, @struct} == Dummy.get(dummy.id)
    end

    test "returns an error when the record doesn't exist" do
      assert {:error, %Mnesia.RecordNotFoundError{table: Dummy, id: "fake-record"}} ==
        Dummy.get("fake-record")
    end
  end

  describe "Mnesia.Repo.create_table/0" do
    setup [:delete_table]

    test "creates the mnesia table" do
      assert {:atomic, :ok} == Dummy.create_table()
      assert Dummy == :mnesia.table_info(Dummy, :record_name)
    end
  end

  def create_dummy(context \\ %{}) do
    dummy = Dummy.save(@struct)
    Map.put(context, :dummy, dummy)
  end

  def create_table(context \\ %{}) do
    {:atomic, :ok} = Dummy.create_table()
    context
  end

  def delete_table(context \\ %{}) do
    on_exit fn ->
      {:atomic, :ok} = Dummy.delete_table()
    end
    context
  end
end
