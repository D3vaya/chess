defmodule ChessWeb.GameLive do
  use ChessWeb, :live_view

  alias Chess.{Game, Board}

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        game: Game.new(),
        selected_cell: nil,
        possible_movements: [],
        show_popup: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-white text-white rounded-lg p-4">
      <div phx-window-keydown="keystroke">
        <h1 class="text-2xl text-black">Chess</h1>
        <%= render_board(assigns) %>

        <div class="flex w-full bg-gray-200">
          <pre class="p-4 text-black text-lg" style="font-family: monospace">
            <%= inspect(@game.board.position_king_in_check, pretty: true) %>
            <%= inspect(@possible_movements, pretty: true) %>

          </pre>
        </div>
      </div>
    </div>
    """
  end

  defp render_board(assigns) do
    ~H"""
    <div class="w-80 relative h-80 grid grid-cols-8 border border-gray-800">
      <%= render_cells(assigns) %>
      <%= render_popup(assigns) %>
    </div>
    """
  end

  defp render_popup(assigns) do
    ~H"""
    <%= if @show_popup and @selected_cell do %>
      <div class="absolute right-[-250px]">
        <div class="bg-white border-2 border-black p-4 rounded-lg text-black">
          <h2 class="text-xl font-bold mb-2">Cell Information</h2>
          <p>Position: (<%= elem(@selected_cell, 0) %>, <%= elem(@selected_cell, 1) %>)</p>
          <%= if elem(@selected_cell, 2) do %>
            <p>Piece: <%= elem(@selected_cell, 2).name %></p>
            <p>Shape: <span class="text-2xl"><%= elem(@selected_cell, 2).shape %></span></p>
            <p class="flex justify-start items-center">
              Color:
              <span class={"w-[20px] h-[20px] ml-2 #{if elem(@selected_cell, 2) && elem(@selected_cell, 2).color == :white, do: "bg-white border-black border-2", else: "bg-black"}"}>
              </span>
            </p>
          <% else %>
            <p>Empty cell</p>
          <% end %>
          <%= if length(@possible_movements) > 0 do %>
            <div
              class="flex flex-col mt-4 justify-start text-black text-lg"
              style="font-family: monospace"
            >
              <strong>Possible movements</strong>
              <hr class="mb-4" />
              <%= for item <- @possible_movements do %>
                <div><%= inspect(item, pretty: true) %></div>
              <% end %>
            </div>
          <% end %>
          <button phx-click="close_popup" class="mt-4 px-4 py-2 bg-blue-500 text-white rounded">
            Close
          </button>
        </div>
      </div>
    <% end %>
    """
  end

  defp render_cells(assigns) do
    ~H"""
    <%= for {x, y, piece} <- @game.board.cells do %>
      <% piece_name = if is_nil(piece), do: "", else: piece.shape %>
      <div
        class={"w-10 h-10 flex items-center justify-center cursor-pointer
        #{if rem(x + y, 2) == 0, do: "bg-white text-black", else: "bg-black text-white"}
        #{if @selected_cell == {x, y, piece} and piece != nil, do: "bg-green-300", else: ""}
        #{if {x, y} in @possible_movements, do: "bg-green-300 shadow-2xl  animate-pulse", else: ""}
        #{if @game.board.position_king_in_check == {x, y}, do: "bg-red-300 shadow-2xl  animate-pulse", else: ""}

        hover:bg-green-200 transition-opacity"}
        phx-click="select_cell"
        phx-value-x={x}
        phx-value-y={y}
        phx-value-piece-type={if piece, do: Atom.to_string(piece.__struct__), else: nil}
        phx-value-piece-color={if piece, do: piece.color, else: nil}
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
          "piece-shape" => piece_shape
        },
        %{assigns: %{selected_cell: nil}} = socket
      ) do
    x = String.to_integer(x)
    y = String.to_integer(y)
    IO.inspect("marca movimientos")

    piece =
      if piece_type && piece_color && piece_shape do
        struct(
          String.to_existing_atom(piece_type),
          %{
            color: String.to_atom(piece_color),
            location: {x, y},
            shape: piece_shape
          }
        )
      else
        nil
      end

    cell = {x, y, piece}
    possible_movements = Board.calculate_movement(socket.assigns.game.board, cell)

    {:noreply,
     assign(
       socket,
       selected_cell: {x, y, piece},
       possible_movements: possible_movements,
       show_popup: true
     )}
  end

  def handle_event(
        "select_cell",
        %{
          "x" => x,
          "y" => y
        },
        %{assigns: %{selected_cell: cell, possible_movements: movements}} =
          socket
      ) do
    x = String.to_integer(x)
    y = String.to_integer(y)

    if {x, y} in movements do
      game_updated = Game.move_piece(socket.assigns.game, cell, {x, y})

      {:noreply,
       assign(socket,
         game: game_updated,
         selected_cell: nil,
         possible_movements: []
       )}
    else
      IO.inspect("entro en else")
      {:noreply, assign(socket, selected_cell: cell, possible_movements: movements)}
    end
  end

  def handle_event("select_cell", %{"x" => x, "y" => y}, socket) do
    x = String.to_integer(x)
    y = String.to_integer(y)
    IO.inspect("no hace nada")

    {:noreply,
     assign(socket, selected_cell: {x, y, nil}, possible_movements: [], show_popup: true)}
  end

  def handle_event("close_popup", _unsigned_params, socket) do
    {:noreply, assign(socket, show_popup: false)}
  end

  # def handle_info({:select_cell, {x, y}}, socket) do
  #   {:noreply, assign(socket, selected_cell: {x, y})}
  # end
end
