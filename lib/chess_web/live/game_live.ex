defmodule ChessWeb.GameLive do
  use ChessWeb, :live_view
  # <alias Phoenix.Socket.Broadcast>
  alias Chess.{Game, Board}
  import ChessWeb.CellComponent

  def mount(_params, session, socket) do
    IO.inspect(session, label: "session")
    if connected?(socket), do: ChessWeb.Endpoint.subscribe("chess:lobby")

    socket =
      assign(socket,
        game: Game.new(),
        selected_cell: nil,
        selected_piece: nil,
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

        <div class="justify-start w-full bg-gray-200">
          <pre class="p-4 text-black text-lg" style="font-family: monospace">
            <span>turn: </span><%= inspect(@game.turn, pretty: true) %>
            <span>position_king_in_check: </span><%= inspect(@game.board.position_king_in_check, pretty: true) %>
            <span>possible_movements: </span><%= inspect(@possible_movements, pretty: true) %>
            <span>selected_cell: </span><%= inspect(@selected_cell, pretty: true) %>
            <span>selected_piece: </span><%= inspect(@selected_piece, pretty: true) %>
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
      <.cell
        x={x}
        y={y}
        piece={piece}
        selected_cell={@selected_cell}
        possible_movements={@possible_movements}
        position_king_in_check={@game.board.position_king_in_check}
      />
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
        %{assigns: %{selected_cell: nil, game: %{board: %{position_king_in_check: nil}}}} =
          socket
      ) do
    x = String.to_integer(x)
    y = String.to_integer(y)

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

    IO.inspect(piece, label: "PIEZA SELECCIONADA: ")
    cell = {x, y, piece}

    if piece != nil and piece.color == socket.assigns.game.turn do
      possible_movements = Board.calculate_movement(socket.assigns.game.board, cell)
      IO.inspect(possible_movements, label: "POSIBLES MOVIMIENTOS")
      IO.inspect("=================================================")

      {:noreply,
       assign(
         socket,
         selected_cell: {x, y, piece},
         possible_movements: possible_movements,
         show_popup: true
       )}
    else
      IO.inspect("LA PIEZA SELECCIONADA NO PERTENECE AL JUGADOR")
      IO.inspect("=================================================")
      {:noreply, socket}
    end
  end

  # evento para cuando el Rey esta en jaque
  def handle_event(
        "select_cell",
        %{
          "x" => x,
          "y" => y,
          "piece-type" => piece_type,
          "piece-color" => piece_color,
          "piece-shape" => piece_shape,
          "piece-name" => piece_name
        },
        %{assigns: %{selected_cell: nil, game: %{board: %{position_king_in_check: king}}}} =
          socket
      ) do
    piece = String.to_atom(piece_name)

    if piece == :king do
      IO.inspect({piece_name, king}, label: "REY EN JAQUE")
      IO.inspect("=================================================")
      {:noreply, socket}
    else
      IO.inspect("REY EN JAQUE, DEBE MOVER EL REY")
      IO.inspect("=================================================")
      {:noreply, socket}
    end
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
      IO.inspect({x, y}, label: "MOVIMIENTO DE PIEZA A")
      IO.inspect("=================================================")
      game_updated = Game.move_piece(socket.assigns.game, cell, {x, y})

      {:noreply,
       assign(socket,
         game: game_updated,
         selected_cell: nil,
         possible_movements: []
       )}
    else
      {x, y, piece} = Board.get_piece_from_board(socket.assigns.game.board, {x, y})

      if piece != nil and piece.color == socket.assigns.game.turn do
        IO.inspect(cell, label: "PIEZA SELECCIONADA: ")
        possible_movements = Board.calculate_movement(socket.assigns.game.board, {x, y, piece})
        IO.inspect(possible_movements, label: "POSIBLES MOVIMIENTOS")
        IO.inspect("=================================================")
        {:noreply, assign(socket, possible_movements: possible_movements, selected_cell: cell)}
      else
        IO.inspect("CELDA VACIA O NO PERTENECE AL JUGADOR")
        {:noreply, socket}
      end
    end
  end

  def handle_event("select_cell", %{"x" => x, "y" => y}, socket) do
    x = String.to_integer(x)
    y = String.to_integer(y)
    IO.inspect("no hace nada")
    IO.inspect("=================================================")

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
