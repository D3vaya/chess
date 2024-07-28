defmodule ChessWeb.GameLive do
  use ChessWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, board: Chess.Board.new())}
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
    <svg width="320" height="320" xmlns="http://www.w3.org/2000/svg" stroke="black" stroke-width="2">
      <rect width="320" height="320" style="fill:rgb(0,0,0);" />
      <%= render_cells(assigns) %>
    </svg>
    """
  end

  defp render_cells(assigns) do
    ~H"""
    <%= for {x, y} <- @board.cells do %>
      <rect
        width="40"
        height="40"
        x={x * 40}
        y={y * 40}
        class="chess-cell"
        style={"fill: #{if rem(x + y, 2) == 0, do: "white", else: "black"};"}
        phx-click="select_cell"
        phx-value-x={x}
        phx-value-y={y}
      />
    <% end %>
    """
  end

  def handle_event("select_cell", %{"x" => x, "y" => y}, socket) do
    x = String.to_integer(x)
    y = String.to_integer(y)
    IO.puts("(#{x},#{y})")
    {:noreply, socket}
  end
end
