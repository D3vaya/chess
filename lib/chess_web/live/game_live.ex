defmodule ChessWeb.GameLive do
  use ChessWeb, :live_view

  alias Chess.{Game, Board}

  def mount(_params, _session, socket) do
    {:ok, assign(socket, game: Game.new(), selected_cell: nil, possible_movements: [])}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col w-full bg-gray-200">
      <h1 class="text-2xl text-black">Possible movements</h1>
      <pre class="p-4 text-black text-xl" style="font-family: monospace">
        <%= inspect(@possible_movements, pretty: true) %>
      </pre>
    </div>

    <div class="bg-white text-white rounded-lg p-4">
      <div phx-window-keydown="keystroke">
        <h1 class="text-2xl text-black">Chess</h1>
        <%= render_board(assigns) %>

        <div class="flex w-full bg-gray-200">
          <pre class="p-4 text-black text-lg" style="font-family: monospace">
            <%= inspect(@game, pretty: true) %>
          </pre>
        </div>
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
    <%= for {x, y, piece} <- @game.board.cells do %>
      <% piece_name = if is_nil(piece), do: "", else: piece.shape %>
      <div
        class={"w-10 h-10 flex items-center justify-center cursor-pointer
        #{if rem(x + y, 2) == 0, do: "bg-white text-black", else: "bg-black text-white"}
        #{if @selected_cell == {x, y, piece}, do: "bg-green-400", else: ""}
        #{if {x, y} in @possible_movements, do: "bg-green-300 shadow-2xl border border-black animate-pulse", else: ""}
        hover:bg-green-200 transition-opacity"}
        phx-click="select_cell"
        phx-value-x={x}
        phx-value-y={y}
        phx-value-piece-type={if piece, do: Atom.to_string(piece.__struct__), else: nil}
        phx-value-piece-color={if piece, do: piece.color, else: nil}
        phx-value-piece-location-x={if piece, do: elem(piece.location, 0), else: nil}
        phx-value-piece-location-y={if piece, do: elem(piece.location, 1), else: nil}
        phx-value-piece-shape={if piece, do: piece.shape, else: nil}
      >
        <span class="text-2xl font-bold"><%= piece_name %></span>
      </div>
    <% end %>
    """
  end

  def handle_event(
        "select_cell",
        %{
          "x" => x,
          "y" => y,
          "piece-type" => piece_type,
          "piece-color" => piece_color,
          "piece-location-x" => piece_location_x,
          "piece-location-y" => piece_location_y,
          "piece-shape" => piece_shape
        },
        socket
      ) do
    x = String.to_integer(x)
    y = String.to_integer(y)

    piece =
      if piece_type && piece_color && piece_location_x && piece_location_y && piece_shape do
        struct(
          String.to_existing_atom(piece_type),
          %{
            color: String.to_atom(piece_color),
            location: {String.to_integer(piece_location_x), String.to_integer(piece_location_y)},
            shape: piece_shape
          }
        )
      else
        nil
      end

    cell = {x, y, piece}
    possible_movements = Game.calculate_movement(socket.assigns.game, cell)

    {:noreply,
     assign(
       socket,
       selected_cell: {x, y, piece},
       possible_movements: possible_movements
     )}
  end

  def handle_event("select_cell", %{"x" => x, "y" => y}, socket) do
    x = String.to_integer(x)
    y = String.to_integer(y)
    {:noreply, assign(socket, selected_cell: {x, y, nil})}
  end

  # def handle_info({:select_cell, {x, y}}, socket) do
  #   {:noreply, assign(socket, selected_cell: {x, y})}
  # end
end
