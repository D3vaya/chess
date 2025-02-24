defmodule ChessWeb.GameLive do
  use ChessWeb, :live_view
  alias Chess.{Game, Board}
  import ChessWeb.CellComponent

  def mount(_params, session, socket) do
    IO.puts("\n====== INICIANDO JUEGO DE AJEDREZ ======")
    IO.inspect(session, label: "Datos de sesión")

    if connected?(socket) do
      IO.puts("✅ Conectado al socket")
      ChessWeb.Endpoint.subscribe("chess:lobby")
    end

    initial_socket =
      assign(socket,
        game: Game.new(),
        selected_cell: nil,
        selected_piece: nil,
        possible_movements: [],
        show_popup: false
      )

    IO.puts("Estado inicial del juego configurado")
    IO.puts("Turno inicial: #{initial_socket.assigns.game.turn}")
    {:ok, initial_socket}
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

  # Primera selección de pieza (cuando no hay pieza seleccionada y no hay jaque)
  def handle_event(
        "select_cell",
        %{
          "x" => x,
          "y" => y,
          "piece-type" => piece_type,
          "piece-color" => piece_color,
          "piece-shape" => piece_shape
        },
        %{assigns: %{selected_cell: nil, game: %{board: %{position_king_in_check: nil}}}} = socket
      ) do
    x = String.to_integer(x)
    y = String.to_integer(y)

    IO.puts("\n====== NUEVA SELECCIÓN DE PIEZA ======")
    IO.puts("Posición seleccionada: (#{x}, #{y})")

    piece =
      if piece_type && piece_color && piece_shape do
        piece =
          struct(
            String.to_existing_atom(piece_type),
            %{
              color: String.to_atom(piece_color),
              location: {x, y},
              shape: piece_shape
            }
          )

        IO.puts("📝 Pieza encontrada:")
        IO.puts("  - Tipo: #{piece_type}")
        IO.puts("  - Color: #{piece_color}")
        IO.puts("  - Forma: #{piece_shape}")
        piece
      else
        IO.puts("⚪ Celda vacía seleccionada")
        nil
      end

    selected_cell = {x, y, piece}

    cond do
      piece != nil and piece.color == socket.assigns.game.turn ->
        IO.puts("\n➡️ CALCULANDO MOVIMIENTOS POSIBLES")
        IO.puts("Turno actual: #{socket.assigns.game.turn}")
        possible_movements = Board.calculate_movement(socket.assigns.game.board, selected_cell)
        IO.puts("Movimientos disponibles: #{inspect(possible_movements)}")

        {:noreply,
         assign(
           socket,
           selected_cell: {x, y, piece},
           possible_movements: possible_movements,
           show_popup: true
         )}

      piece != nil ->
        IO.puts("\n⚠️ MOVIMIENTO INVÁLIDO")
        IO.puts("No es el turno del jugador #{piece.color}")
        {:noreply, socket}

      true ->
        IO.puts("\n⚠️ SELECCIÓN INVÁLIDA")
        IO.puts("No hay pieza para mover")
        {:noreply, socket}
    end
  end

  # Manejo de situación de jaque
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

    IO.puts("\n====== SITUACIÓN DE JAQUE ======")
    IO.puts("⚠️ Rey en jaque: #{inspect(king)}")
    IO.puts("Pieza seleccionada: #{piece_name}")

    if piece == :king do
      IO.puts("✅ Selección válida: El rey debe moverse")
      {:noreply, socket}
    else
      IO.puts("❌ Selección inválida: Solo se puede mover el rey en jaque")
      {:noreply, socket}
    end
  end

  # Manejo de movimiento de pieza
  def handle_event(
        "select_cell",
        %{"x" => x, "y" => y},
        %{assigns: %{selected_cell: cell, possible_movements: movements}} = socket
      ) do
    x = String.to_integer(x)
    y = String.to_integer(y)

    IO.puts("\n====== INTENTO DE MOVIMIENTO ======")
    IO.puts("Desde: #{inspect(cell)}")
    IO.puts("Hacia: (#{x}, #{y})")

    if {x, y} in movements do
      IO.puts("\n✅ MOVIMIENTO VÁLIDO")
      IO.puts("Ejecutando movimiento...")
      game_updated = Game.move_piece(socket.assigns.game, cell, {x, y})
      IO.puts("Movimiento completado")
      IO.puts("Nuevo turno: #{game_updated.turn}")

      {:noreply,
       assign(socket,
         game: game_updated,
         selected_cell: nil,
         possible_movements: []
       )}
    else
      {x, y, piece} = Board.get_piece_from_board(socket.assigns.game.board, {x, y})

      if piece != nil and piece.color == socket.assigns.game.turn do
        IO.puts("\n🔄 CAMBIO DE SELECCIÓN")
        IO.puts("Nueva pieza seleccionada: #{inspect(piece)}")
        possible_movements = Board.calculate_movement(socket.assigns.game.board, {x, y, piece})
        IO.puts("Nuevos movimientos posibles: #{inspect(possible_movements)}")

        {:noreply, assign(socket, possible_movements: possible_movements, selected_cell: cell)}
      else
        IO.puts("\n❌ MOVIMIENTO INVÁLIDO")
        IO.puts("Celda seleccionada no es válida para el turno actual")
        {:noreply, socket}
      end
    end
  end

  # Manejo de selección de celda vacía
  def handle_event("select_cell", %{"x" => x, "y" => y}, socket) do
    x = String.to_integer(x)
    y = String.to_integer(y)

    IO.puts("\n====== SELECCIÓN DE CELDA VACÍA ======")
    IO.puts("Posición: (#{x}, #{y})")
    IO.puts("No hay acción disponible")

    {:noreply,
     assign(socket, selected_cell: {x, y, nil}, possible_movements: [], show_popup: true)}
  end

  def handle_event("close_popup", _unsigned_params, socket) do
    IO.puts("\n====== CERRANDO POPUP ======")
    {:noreply, assign(socket, show_popup: false)}
  end
end
