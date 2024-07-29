defmodule Chess.Pieces.Horse do
  @moduledoc """
  Represents a Horse on the board.
  """
  alias Chess.Board

  @type name :: atom()
  @type shape :: String.t()
  @type color :: :white | :black
  @type location :: {integer, integer}
  @type t :: %__MODULE__{
          name: name(),
          shape: shape(),
          color: color(),
          location: location()
        }

  @enforce_keys [:color]
  defstruct name: :horse, color: nil, location: {0, 0}, shape: ""

  @spec new(color()) :: t()
  def new(color) do
    %__MODULE__{color: color, shape: shape_by_color(color)}
  end

  def shape_by_color(:white) do
    "♘"
  end

  def shape_by_color(:black) do
    "♞"
  end

  @spec calculate_horse_movement(Board.t(), Board.cell()) :: list(Board.location())
  def calculate_horse_movement(board, cell) do
    board
    |> allowed_movements(cell)
  end

  @spec allowed_movements(Board.t(), Board.cell()) :: list(Board.location())
  def allowed_movements(board, {x, y, piece}) do
    movements =
      {x, y}
      |> possible_movements()

    movements_filter =
      is_there_an_friend?(board, movements, piece.color)
      |> Enum.map(fn {x, y, _} -> {x, y} end)

    # board_cells
    # |> is_there_an_enemy?()

    movements_filter
  end

  @spec possible_movements(location()) :: list(location())
  #   0  1  2  3  4  5  6  7
  # 0[ ][ ][ ][ ][ ][ ][ ][ ]0
  # 1[ ][ ][x][ ][x][ ][ ][ ]1
  # 2[ ][x][ ][ ][ ][x][ ][ ]2
  # 3[ ][ ][ ][♞][ ][ ][ ][ ]3
  # 4[ ][x][ ][ ][ ][x][ ][ ]4
  # 5[ ][ ][x][ ][x][ ][ ][ ]5
  # 6[ ][ ][ ][ ][ ][ ][ ][ ]6
  # 7[ ][ ][ ][ ][ ][ ][ ][ ]7
  #   0  1  2  3  4  5  6  7
  # ---------------------------
  def possible_movements({x, y}) do
    [
      {x - 2, y - 1},
      {x - 2, y + 1},
      {x + 2, y - 1},
      {x + 2, y + 1},
      {x - 1, y - 2},
      {x - 1, y + 2},
      {x + 1, y - 2},
      {x + 1, y + 2}
    ]
    |> Enum.filter(fn {x, y} -> Board.cell_exists?({x, y}) end)
  end

  @spec is_there_an_friend?(Board.t(), list(location()), atom()) :: list(Board.cell())
  def is_there_an_friend?(board, movements, color) do
    board
    |> Board.the_cell_is_occupied?(movements, color)
  end

  @spec is_there_an_enemy?(Board.cells()) :: Board.cells()
  def is_there_an_enemy?(cells) do
    IO.inspect(cells, label: "is_there_an_enemy?")
  end
end

#   0  1  2  3  4  5  6  7
# 0[ ][ ][ ][ ][ ][ ][ ][ ]0
# 1[ ][ ][x][ ][x][ ][ ][ ]1
# 2[ ][x][ ][ ][ ][x][ ][ ]2
# 3[ ][ ][ ][♞][ ][ ][ ][ ]3
# 4[ ][x][ ][ ][ ][x][ ][ ]4
# 5[ ][ ][x][ ][x][ ][ ][ ]5
# 6[ ][ ][ ][ ][ ][ ][ ][ ]6
# 7[ ][ ][ ][ ][ ][ ][ ][ ]7
#   0  1  2  3  4  5  6  7
# ---------------------------
# ---------------------------
#   0  1  2  3  4  5  6  7
# 0[ ][ ][ ][ ][ ][ ][ ][ ]0
# 1[ ][ ][ ][ ][ ][ ][ ][ ]1
# 2[ ][ ][ ][ ][ ][ ][ ][ ]2
# 3[ ][ ][ ][ ][ ][ ][ ][ ]3
# 4[ ][ ][ ][ ][ ][ ][ ][ ]4
# 5[x][ ][x][ ][ ][ ][ ][ ]5
# 6[ ][ ][ ][ ][ ][ ][ ][ ]6
# 7[ ][♞][ ][ ][ ][ ][ ][ ]7
#   0  1  2  3  4  5  6  7
