defmodule MyApp.TodosTest do
  use MyApp.DataCase

  alias MyApp.Todos

  describe "tasks" do
    alias MyApp.Todos.Task

    @valid_attrs %{done: true, name: "some name", sort_order: 120.5}
    @update_attrs %{done: false, name: "some updated name", sort_order: 456.7}
    @invalid_attrs %{done: nil, name: nil, sort_order: nil}

    def task_fixture(attrs \\ %{}) do
      {:ok, task} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Todos.create_task()

      task
    end

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Todos.list_tasks() == [task]
    end

    test "get_task/1 returns the task with given id" do
      task = task_fixture()
      assert Todos.get_task(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      assert {:ok, %Task{} = task} = Todos.create_task(@valid_attrs)
      assert task.done == true
      assert task.name == "some name"
      assert task.sort_order == 120.5
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todos.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      assert {:ok, %Task{} = task} = Todos.update_task(task, @update_attrs)
      assert task.done == false
      assert task.name == "some updated name"
      assert task.sort_order == 456.7
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Todos.update_task(task, @invalid_attrs)
      assert task == Todos.get_task(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Todos.delete_task(task)
      assert nil == Todos.get_task(task.id)
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Todos.change_task(task)
    end
  end
end
