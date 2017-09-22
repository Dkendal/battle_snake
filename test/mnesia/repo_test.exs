defmodule Dummy do
  use Mnesia.Repo
  defstruct [:id, :x, :y]
  def fields, do: [:id, :x, :y]
end

defmodule Mnesia.UtilTest do
  use Bs.Case, async: false

  describe "Mnesia.Util.record/1" do
    test "converts the struct to a record" do
      dummy = %Dummy{id: 1, x: 2, y: 3}
      assert Mnesia.Util.record(dummy) == {Dummy, 1, 2, 3}
    end
  end

  describe "Mnesia.Util.record/2" do
    test "converts the struct to a record" do
      dummy = %Dummy{id: 1, x: 2, y: 3}
      assert Mnesia.Util.record(dummy, [:id]) == {Dummy, 1}
    end
  end

  describe "Mnesia.Util.record/3" do
    test "converts the struct to a record" do
      dummy = %Dummy{id: 1, x: 2, y: 3}
      assert Mnesia.Util.record(dummy, [:id], :table) == {:table, 1}
    end
  end
end

defmodule Mnesia.RepoTest do
  use Bs.Case, async: false

  @struct struct(Dummy, id: 0, x: 1, y: 2)
  @record {Dummy, 0, 1, 2}

  setup [:create_table]

  describe "Mnesia.Repo.fields/0" do
    test "returns fields defined as a module attribute" do
      assert Dummy.fields == [
        :id,
        :x,
        :y]
    end

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

  describe "Mnesia.Repo.load/1" do
    test "converts the struct to a record" do
      assert Mnesia.Repo.load(@record) == @struct
    end
  end

  describe "Mnesia.Repo.save/1" do
    setup [:create_table, :delete_table]

    test "writes the record to mnesia" do
      assert @struct == Mnesia.Repo.save(@struct)
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
    test "creates the mnesia table" do
      :mnesia.delete_table Dummy
      assert {:atomic, :ok} == Dummy.create_table()
      assert Dummy == :mnesia.table_info(Dummy, :record_name)
    end
  end

  describe "Mnesia.Repo.all/1" do
    test "returns all records for the table" do
      :mnesia.activity :transaction, fn ->
        :mnesia.write @record
        assert [_] = Mnesia.Repo.all(Dummy)
      end
    end
  end

  def create_dummy(context \\ %{}) do
    dummy = Mnesia.Repo.save(@struct)
    Map.put(context, :dummy, dummy)
  end

  def create_table(_) do
    :mnesia.create_table Dummy, attributes: Dummy.fields()
    :ok
  end

  def delete_table(context \\ %{}) do
    on_exit fn ->
      {:atomic, _} = :mnesia.delete_table(Dummy)
    end
    context
  end
end
