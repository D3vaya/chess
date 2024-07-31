defmodule ChessWeb.ChessChannel do
  use Phoenix.Channel

  def join("chess:lobby", _message, socket) do
    {:ok, socket}
  end

  def handle_in("move", %{"from" => from, "to" => to}, socket) do
    broadcast!(socket, "move", %{"from" => from, "to" => to})
    {:noreply, socket}
  end
end
