defmodule MyAppWeb.TodoLive do
  use MyAppWeb, :live_view

  alias MyApp.Todos
  alias MyApp.Todos.Task

  def mount(_params, _session, socket) do
    if connected?(socket), do: Todos.subscribe()

    {:ok,
    socket
    |> assign(add_changeset: Todos.change_task(%Task{}))
    |> fetch_list }

  end

  def handle_event("add", %{"task" => task_params}, socket) do
    attrs =
      task_params
      |> Map.put_new("sort_order", Todos.get_last_position())

    case Todos.create_task(attrs) do
      {:ok, task} ->
        Todos.broadcast_change({:ok, task}, [:task, :created])
        send_flash(:info, "Task created!")
        {:noreply, assign(socket, add_changeset: Todos.change_task(%Task{}))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, add_changeset: changeset)}
    end

  end

  def handle_event("edit_task", %{"id" => id}, socket) do
    task =  Todos.get_task(id)
    {:noreply, assign(socket, live_action: :edit, task: task)}
  end

  def handle_event("validate", %{"task" => task}, %_{assigns: %{live_action: :index} } = socket) do
    changeset =
      %Task{}
      |> Todos.change_task(task)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, add_changeset: changeset)}
  end

  def handle_event("toggle_done", %{"id" => id}, socket) do
    task = Todos.get_task(id)

    case Todos.update_task(task, %{done: !task.done}) do
      {:ok, task} ->
        Todos.broadcast_change({:ok, task}, [:task, :updated])
        {:noreply, socket}
      {:error, _} ->
        send_flash(:error, "Unable to update task!")
        {:noreply, socket }
    end
  end

  def handle_event("sort", %{"id" => id, "before_pos" => before_pos, "after_pos" => after_pos}, socket) do
    task = Todos.get_task(id)

    case Todos.update_task(task, set_sort_order(before_pos, after_pos)) do
      {:ok, task} ->
        Todos.broadcast_change({:ok, task}, [:task, :updated])
        send_flash(:info, "Succesfully sorted task!")
        {:noreply, socket }

      {:error, _} ->
        send_flash(:error, "Unable to sort task!")
        {:noreply, socket }
    end

  end

  def handle_event("delete_task", %{"id" => id}, socket) do
    task = Todos.get_task(id)

    case Todos.delete_task(task) do
      {:ok, task} ->
        Todos.broadcast_change({:ok, task}, [:task, :deleted])
        send_flash(:error, "Succesfully deleted task!")
        {:noreply,  socket}

      {:error, _} ->
        send_flash(:error, "Unable to delete task!")
        {:noreply, socket}
    end
  end

  def handle_info({Todos, [:task | _], _}, socket) do
    {:noreply, fetch_list(socket)}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_info(%{flash_type: type, message: message}, socket) do
    {:noreply, put_flash(socket, type, message)}
  end

  def handle_params(_params, _url,  %_{assigns: %{live_action: :index} } = socket) do
    {:noreply, socket}
  end

  defp set_sort_order(before_pos, after_pos) do
    case after_pos do
      0 -> pos =
        before_pos
        |> ceil
        |> Kernel.+(10)
        %{sort_order: pos }
      _ ->
        %{sort_order: (before_pos + after_pos)/2 }
    end
  end

  defp fetch_list(socket) do

    tasks =
    Todos.list_tasks()
    |> Enum.sort_by(fn(t) -> t.sort_order end, &</2)

    assign(socket, tasks: tasks)

  end

  defp send_flash(type, message) do
    Process.send_after(self(), :clear_flash, 0)
    Process.send_after(self(), %{flash_type: type, message: message }, 100)
  end

end
