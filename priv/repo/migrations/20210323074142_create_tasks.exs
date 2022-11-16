defmodule MyApp.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :name, :string
      add :sort_order, :float
      add :done, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:tasks, [:name])
    create unique_index(:tasks, [:sort_order])
  end
end
