defmodule Chess.Pieces.Tower do
  alias Chess.{Board, Types}

  @moduledoc """
  Represents a Tower on the board.

  Recordemos que la torre se mueve en 4 direcciones:
  1. Vertical hacia arriba:   {0, -1}
  2. Vertical hacia abajo:    {0, 1}
  3. Horizontal derecha:      {1, 0}
  4. Horizontal izquierda:    {-1, 0}

  """
  @type t :: %__MODULE__{
          name: atom(),
          shape: Types.shape(),
          color: Types.color(),
          location: Types.location()
        }

  @enforce_keys [:color]
  defstruct name: :tower, color: nil, location: nil, shape: ""

  @valid_colors [:white, :black]

  @spec new(Types.color()) :: t()
  def new(color) when color in @valid_colors do
    %__MODULE__{color: color, shape: shape_by_color(color)}
  end

  @spec calculate_tower_movement(Board.t(), Types.cell()) :: Types.locations()
  def calculate_tower_movement(board, selected_cell) do
    board
    |> allowed_movements(selected_cell)
  end

  # GameRules.check_for_checkmate()

  @spec allowed_movements(Board.t(), Types.cell()) :: Types.locations()
  def allowed_movements(board, {position_x, position_y, piece}) do
    # Separamos los movimientos en las cuatro direcciones posibles
    [
      # Arriba
      get_moves_in_direction(board, {position_x, position_y}, {0, 1}, piece.color),
      # Abajo
      get_moves_in_direction(board, {position_x, position_y}, {0, -1}, piece.color),
      # Derecha
      get_moves_in_direction(board, {position_x, position_y}, {1, 0}, piece.color),
      # Izquierda
      get_moves_in_direction(board, {position_x, position_y}, {-1, 0}, piece.color)
    ]
    |> List.flatten()
  end

  # Calcula los movimientos válidos de la torre en una dirección específica.
  # Ejemplo de posiciones de torre:
  #   0  1  2  3  4  5  6  7
  # 7[♜][ ][ ][ ][ ][ ][ ][♜]7  <- Torre en esquina (7,0) y (7,7)
  # 6[ ][ ][ ][ ][ ][ ][ ][ ]6
  # 5[ ][ ][ ][♜][ ][ ][ ][ ]5  <- Torre en centro (5,3)
  # 4[ ][ ][ ][ ][ ][ ][ ][ ]4
  # 3[ ][ ][ ][ ][ ][ ][ ][ ]3
  # 2[ ][ ][ ][ ][ ][ ][ ][ ]2
  # 1[ ][ ][ ][ ][ ][ ][ ][ ]1
  # 0[♖][ ][ ][ ][ ][ ][ ][♖]0  <- Torre en esquina (0,0) y (0,7)
  #   0  1  2  3  4  5  6  7
  @spec get_moves_in_direction(
          board :: Board.t(),
          start_position :: Types.location(),
          direction :: Types.location(),
          piece_color :: atom()
        ) :: Types.locations()
  defp get_moves_in_direction(
         board,
         _start_position = {start_x, start_y},
         _direction = {delta_x, delta_y},
         current_piece_color
       ) do
    IO.puts("\n=== Evaluando movimientos de Torre ===")
    IO.puts("Posición inicial: (#{start_x},#{start_y})")
    IO.puts("Dirección de movimiento: horizontal=#{delta_x}, vertical=#{delta_y}")
    IO.puts("Color de la torre: #{current_piece_color}")

    max_steps = calculate_max_steps(start_x, start_y, delta_x, delta_y)
    possible_steps = 1..max_steps

    possible_steps
    |> Enum.reduce_while([], fn steps_taken, valid_moves ->
      # Calcula la siguiente posición basada en la dirección y los pasos
      target_x = start_x + delta_x * steps_taken
      target_y = start_y + delta_y * steps_taken
      target_position = {target_x, target_y}

      IO.puts("\nEvaluando paso #{steps_taken}:")
      IO.puts("Analizando posición: (#{target_x},#{target_y})")

      cond do
        not Board.cell_exists?(target_position) ->
          IO.puts("❌ Posición fuera del tablero - Deteniendo búsqueda")
          IO.puts("Movimientos válidos acumulados: #{inspect(valid_moves)}")
          {:halt, valid_moves}

        true ->
          target_cell = Board.get_piece_from_board(board, target_position)
          IO.puts("Estado de la celda objetivo: #{inspect(target_cell)}")

          case target_cell do
            {_, _, nil} ->
              # Celda vacía - continuar búsqueda
              updated_moves = valid_moves ++ [target_position]
              IO.puts("✅ Celda libre - Añadiendo a movimientos válidos")
              IO.puts("Movimientos actualizados: #{inspect(updated_moves)}")
              {:cont, updated_moves}

            {_, _, %{color: piece_color}} when piece_color == current_piece_color ->
              # Pieza del mismo color - bloquea el camino
              IO.puts("🚫 Pieza aliada encontrada - Deteniendo búsqueda")
              IO.puts("Movimientos finales: #{inspect(valid_moves)}")
              {:halt, valid_moves}

            {_, _, %{color: blocking_piece_color}} ->
              # Pieza enemiga - permite captura y detiene búsqueda
              final_moves = valid_moves ++ [target_position]
              IO.puts("⚔️ Pieza enemiga (#{blocking_piece_color}) - Añadiendo última posición")
              IO.puts("Movimientos finales con captura: #{inspect(final_moves)}")
              {:halt, final_moves}

            nil ->
              # Caso de seguridad para celdas no encontradas
              updated_moves = valid_moves ++ [target_position]
              IO.puts("✅ Posición válida - Continuando búsqueda")
              {:cont, updated_moves}
          end
      end
    end)
  end

  # Calcula el número máximo de pasos posibles en una dirección
  defp calculate_max_steps(start_x, start_y, delta_x, delta_y) do
    cond do
      # Movimiento vertical hacia arriba
      delta_y < 0 -> start_y
      # Movimiento vertical hacia abajo
      delta_y > 0 -> 7 - start_y
      # Movimiento horizontal hacia la izquierda
      delta_x < 0 -> start_x
      # Movimiento horizontal hacia la derecha
      delta_x > 0 -> 7 - start_x
      true -> 7
    end
  end

  defp shape_by_color(:white), do: "♖"
  defp shape_by_color(:black), do: "♜"
end
