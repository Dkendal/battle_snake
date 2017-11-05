defmodule Bs.ChangesetError do
  defexception([:changeset])

  def exception(changeset) do
    %__MODULE__{changeset: changeset}
  end

  def message(_error) do
    "validation error"
  end
end
