defmodule Mnesia.RepoTest.DummyStruct do
  use Mnesia.Repo
  defstruct [:id, :x, :y]

  def fields, do: [:id, :x, :y]

  def table_name do
    "mnesia_repo_test_dummy_struct"
  end
end

defmodule Mnesia.RepoTest.DummyModel do
  use Mnesia.Repo

  schema "dummy" do
    field :x, :integer, default: 0
    field :y, :integer, default: 0
  end
end

defmodule Mnesia.RepoTest do
  alias __MODULE__.DummyModel
  alias __MODULE__.DummyStruct
  use BattleSnake.Case, async: false

  @described_module DummyModel
  @model struct(@described_module, id: 0, x: 1, y: 2)
  @record {@described_module, 0, 1, 2}

  describe "Mnesia.Repo.save/1" do
    test "sets the id" do
      result = Mnesia.Repo.save(%DummyModel{id: nil, x: 1, y: 2})
      assert result.id =~ ~r/(\w+-?)+/
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
      assert @described_module.fields == [
        :id,
        :x,
        :y]
    end
  end

  describe "Mnesia.Repo.table/0" do
    test "returns the decleration for mnesia" do
      assert @described_module.table == [
        attributes: [
          :id,
          :x,
          :y]]
    end
  end

  describe "Mnesia.Repo.record/1" do
    test "converts the struct to a record" do
      assert @described_module.record(@model) == @record
    end
  end

  describe "Mnesia.Repo.load/1" do
    test "converts the struct to a record" do
      assert @described_module.load(@record) == @model
    end
  end

  describe "Mnesia.Repo.save/1" do
    setup [:create_table, :delete_table]

    test "writes the record to mnesia" do
      assert @model == Mnesia.Repo.save(@model)
      assert 1 == :mnesia.table_info(@described_module, :size)
    end

    test "adds an id if the @primary_key is nil" do
      id = Mnesia.Repo.save(%{@model| id: nil}).id
      assert id != nil
    end
  end

  describe "Mnesia.Repo.reload/1" do
    setup [:create_table, :delete_table, :reload]

    def reload _ do
      record = %DummyModel{id: 1, x: "old"}
      record = Mnesia.Repo.save(record)
      Mnesia.Repo.save(%{record| x: "new"})
      record = Mnesia.Repo.reload(record)
      [record: record]
    end

    test "returns an updated version of the record", %{record: record} do
      assert {:ok, record} = record
      assert record.id == 1
      assert record.x == "new"
    end
  end

  describe "Mnesia.Repo.get/1" do
    setup [:create_table, :delete_table, :create_dummy]

    test "returns the record", %{dummy: dummy} do
      assert {:ok, @model} == @described_module.get(dummy.id)
    end

    test "returns an error when the record doesn't exist" do
      assert {:error, %Mnesia.RecordNotFoundError{table: @described_module, id: "fake-record"}} ==
        @described_module.get("fake-record")
    end
  end

  describe "Mnesia.Repo.create_table/0" do
    setup [:delete_table]

    test "creates the mnesia table" do
      assert {:atomic, :ok} == @described_module.create_table()
      assert @described_module == :mnesia.table_info(@described_module, :record_name)
    end
  end

  def create_dummy(context \\ %{}) do
    dummy = Mnesia.Repo.save(@model)
    Map.put(context, :dummy, dummy)
  end

  def create_table(context \\ %{}) do
    {:atomic, :ok} = @described_module.create_table()
    context
  end

  def delete_table(context \\ %{}) do
    on_exit fn ->
      {:atomic, :ok} = @described_module.delete_table()
    end
    context
  end
end
