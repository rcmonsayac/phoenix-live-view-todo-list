
defmodule MyAppWeb.FormComponent do
  use MyAppWeb, :live_component

  alias MyApp.Todos

  @impl true
  def update(%{task: task} = assigns, socket) do
    changeset = Todos.change_task(task)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:edit_changeset, changeset)}
  end

  # @impl true
  def handle_event("validate", %{"task" => task_params}, %_{assigns: %{live_action: :edit} } = socket) do
    task = Todos.get_task(socket.assigns.task.id)
    changeset =
      task
      |> Todos.change_task(task_params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, edit_changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"task" => task_params}, socket) do
    task = Todos.get_task(socket.assigns.task.id)
      case Todos.update_task(task, task_params) do
        {:ok, task} ->
          {:ok, task}
          |> Todos.broadcast_change([:task, :updated])
          send_flash(:info, "Successfully updated task!")
          {:noreply,
          socket
          |> push_patch(to: socket.assigns.return_to)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, edit_changeset: changeset)}
      end
  end

  defp send_flash(type, message) do
    Process.send_after(self(), :clear_flash, 0)
    Process.send_after(self(), %{flash_type: type, message: message }, 100)
  end
end
