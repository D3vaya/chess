defmodule Chess.Pieces.Tower do
  alias Chess.Board
  alias Chess.Types

  @moduledoc """
  Represents a Tower on the board.
  """
  @type t :: %__MODULE__{
          name: atom(),
          shape: Types.shape(),
          color: Types.color(),
          location: Types.location()
        }

  @enforce_keys [:color]
  defstruct name: :tower, color: nil, location: nil, shape: ""

  @board_range 0..7
  @valid_colors [:white, :black]

  @spec new(Types.color()) :: t()
  def new(color) when color in @valid_colors do
    %__MODULE__{color: color, shape: shape_by_color(color)}
  end

  @spec calculate_tower_movement(Board.t(), Types.cell()) :: Types.locations()
  def calculate_tower_movement(board, cell) do
    board
    |> allowed_movements(cell)
  end

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

  # Obtiene movimientos válidos en una dirección específica
  defp get_moves_in_direction(board, {start_x, start_y}, {dx, dy}, piece_color) do
    @board_range
    |> Enum.reduce_while([], fn i, acc ->
      new_x = start_x + dx * i
      new_y = start_y + dy * i

      cond do
        # Fuera del tablero
        not Board.cell_exists?({new_x, new_y}) ->
          {:halt, acc}

        true ->
          current_piece = Board.get_piece_struct(board, {new_x, new_y, nil})

          case current_piece do
            nil ->
              # Casilla vacía, continuar acumulando
              {:cont, acc ++ [{new_x, new_y}]}

            %{color: ^piece_color} ->
              # Pieza del mismo color, detener sin incluir
              {:halt, acc}

            %{color: _other_color} ->
              # Pieza enemiga, incluir y detener
              {:halt, acc ++ [{new_x, new_y}]}
          end
      end
    end)
  end

  # @spec is_there_an_friend?(Types.locations(), Board.t(), atom()) :: Types.cells()
  # defp is_there_an_friend?(movements, board, color) do
  #   board
  #   |> Board.the_cell_is_occupied?(movements, color)
  # end

  #   0  1  2  3  4  5  6  7
  # 7[♜][ ][ ][ ][ ][ ][ ][♜]7
  # 6[ ][ ][ ][ ][ ][ ][ ][ ]6
  # 5[ ][ ][ ][ ][ ][ ][ ][ ]5
  # 4[ ][ ][ ][ ][ ][ ][ ][ ]4
  # 3[ ][ ][ ][ ][ ][ ][ ][ ]3
  # 2[ ][ ][ ][ ][ ][ ][ ][ ]2
  # 1[ ][ ][ ][ ][ ][ ][ ][ ]1
  # 0[♖][ ][ ][ ][ ][ ][ ][♖]0
  #   0  1  2  3  4  5  6  7

  defp shape_by_color(:white), do: "♖"
  defp shape_by_color(:black), do: "♜"
  defp sign(x) when x < 0, do: -1
  defp sign(x) when x > 0, do: 1
  defp sign(0), do: 0
end
