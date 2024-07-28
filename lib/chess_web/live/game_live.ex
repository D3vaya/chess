defmodule ChessWeb.GameLive do
  use ChessWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, board: Chess.Board.new(), selected_cell: nil)}
  end

  def render(assigns) do
    # IO.inspect(assigns.board)

    ~H"""
    <div class="bg-white text-white rounded-lg p-4">
      <div phx-window-keydown="keystroke">
        <h1 class="text-2xl text-black">Chess</h1>
        <%= render_board(assigns) %>
        <pre class="bg-gray-200 p-4 text-black">

      <%= inspect(@board, pretty: true) %>
      </pre>
      </div>
    </div>
    """
  end

  defp render_board(assigns) do
    ~H"""
    <div class="w-80 h-80 grid grid-cols-8 border border-gray-800">
      <%= render_cells(assigns) %>
    </div>
    """
  end

  defp render_cells(assigns) do
    ~H"""
    <%= for {x, y, piece} <- @board.cells do %>
      <% piece_name = if is_nil(piece), do: "", else: piece.shape %>
      <div
        class={"w-10 h-10 flex items-center justify-center cursor-pointer #{if rem(x + y, 2) == 0, do: "bg-white text-black", else: "bg-black text-white"} hover:bg-lime-300 transition-opacity"}
        phx-click="select_cell"
        phx-value-x={x}
        phx-value-y={y}
      >
        <span class="text-2xl font-bold"><%= piece_name %></span>
      </div>
    <% end %>
    """
  end

  def handle_event("select_cell", %{"x" => x, "y" => y}, socket) do
    x = String.to_integer(x)
    y = String.to_integer(y)
    {:noreply, assign(socket, selected_cell: {x, y})}
  end

  # def handle_info({:select_cell, {x, y}}, socket) do
  #   {:noreply, assign(socket, selected_cell: {x, y})}
  # end
end
