defmodule Mnesia.RepoTest.DummyStruct do
  use Mnesia.Repo
  defstruct [:id, :x, :y]

  def fields, do: [:id, :x, :y]
  def table_name, do: __MODULE__
end

defmodule Mnesia.RepoTest do
  alias __MODULE__.DummyStruct
  use BattleSnake.Case, async: false

  @struct struct(DummyStruct, id: 0, x: 1, y: 2)
  @record {DummyStruct, 0, 1, 2}

  setup [:create_table]

  describe "Mnesia.Repo.save/1" do
    test "saves the record" do
      Mnesia.Repo.save(%DummyStruct{})
    end
  end

  describe "Mnesia.Repo.fields/0" do
    test "returns fields defined as a module attribute" do
      assert DummyStruct.fields == [
        :id,
        :x,
        :y]
    end

    test "returns the column names" do
      assert DummyStruct.fields == [
        :id,
        :x,
        :y]
    end
  end

  describe "Mnesia.Repo.table/0" do
    test "returns the decleration for mnesia" do
      assert DummyStruct.table == [
        attributes: [
          :id,
          :x,
          :y]]
    end
  end

  describe "Mnesia.Repo.record/1" do
    test "converts the struct to a record" do
      assert DummyStruct.record(@struct) == @record
    end
  end

  describe "Mnesia.Repo.load/1" do
    test "converts the struct to a record" do
      assert Mnesia.Repo.load(@record) == @struct
    end
  end

  describe "Mnesia.Repo.save/1" do
    setup [:create_table, :delete_table]

    test "writes the record to mnesia" do
      assert @struct == Mnesia.Repo.save(@struct)
      assert 1 == :mnesia.table_info(DummyStruct, :size)
    end
  end

  describe "Mnesia.Repo.get/1" do
    setup [:create_table, :delete_table, :create_dummy]

    test "returns the record", %{dummy: dummy} do
      assert {:ok, @struct} == DummyStruct.get(dummy.id)
    end

    test "returns an error when the record doesn't exist" do
      assert {:error, %Mnesia.RecordNotFoundError{table: DummyStruct, id: "fake-record"}} ==
        DummyStruct.get("fake-record")
    end
  end

  describe "Mnesia.Repo.create_table/0" do
    test "creates the mnesia table" do
      :mnesia.delete_table DummyStruct
      assert {:atomic, :ok} == DummyStruct.create_table()
      assert DummyStruct == :mnesia.table_info(DummyStruct, :record_name)
    end
  end

  describe "Mnesia.Repo.all/1" do
    test "returns all records for the table" do
      :mnesia.activity :transaction, fn ->
        :mnesia.write @record
        assert [_] = Mnesia.Repo.all(DummyStruct)
      end
    end
  end

  def create_dummy(context \\ %{}) do
    dummy = Mnesia.Repo.save(@struct)
    Map.put(context, :dummy, dummy)
  end

  def create_table(_) do
    :mnesia.create_table DummyStruct, attributes: DummyStruct.fields()
    :ok
  end

  def delete_table(context \\ %{}) do
    on_exit fn ->
      {:atomic, _} = :mnesia.delete_table(DummyStruct)
    end
    context
  end
end
