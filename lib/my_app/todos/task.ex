defmodule MyApp.Todos.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :done, :boolean, default: false
    field :name, :string
    field :sort_order, :float

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :sort_order, :done])
    |> validate_required([:name, :done])
    |> unique_constraint(:name)
    |> unique_constraint(:sort_order)
  end
end
