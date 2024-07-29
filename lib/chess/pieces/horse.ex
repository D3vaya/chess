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

  @valid_colors [:white, :black]
  @enforce_keys [:color]
  defstruct name: :horse, color: nil, location: {0, 0}, shape: ""

  @spec new(color()) :: t()
  def new(color) do
    %__MODULE__{color: color, shape: shape_by_color(color)}
  end

  @doc """
  Returns the shape of a white horse piece on the chess board.

  This function is an implementation detail and is not part of the public API.

  Args:
    color (:white): The color of the horse piece.

  Returns:
    String.t(): The shape of the white horse piece.
  """
  def shape_by_color(color) when color in @valid_colors do
    if color == :white do
      "♘"
    else
      "♞"
    end
  end

  def shape_by_color(_), do: raise("Invalid color")

  @doc """
  Calculates the allowed movements for a horse piece on the chess board.

  This function is an implementation detail and is not part of the public API.

  Args:
    board (Board.t()): The game board.
    cell (Board.cell()): The current location of the horse piece.

  Returns:
    list(Board.location()): The list of allowed movements for the horse piece.
  """
  @spec calculate_horse_movement(Board.t(), Board.cell()) :: list(Board.location())
  def calculate_horse_movement(board, cell) do
    board
    |> allowed_movements(cell)
  end

  @doc """
  Calculates the allowed movements for a horse piece on the chess board.

  This function is an implementation detail and is not part of the public API.

  Args:
    board (Board.t()): The game board.
    {x, y, piece} (Board.cell()): The current location of the horse piece.

  Returns:
    list(Board.location()): The list of allowed movements for the horse piece.
  """
  @spec allowed_movements(Board.t(), Board.cell()) :: list(location())
  def allowed_movements(board, {x, y, piece}) do
    {x, y}
    |> possible_movements()
    |> is_there_an_friend?(board, piece.color)
    |> Enum.map(fn {x, y, _} -> {x, y} end)
  end

  @doc """
  Calculates the possible movements for a horse piece on the chess board.

  This function is an implementation detail and is not part of the public API.

  Args:
    {x, y} (Board.location()): The current location of the horse piece.

  Returns:
    list(Board.location()): The list of possible movements for the horse piece.
  """
  @spec possible_movements(location()) :: list(location())
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

  @doc """
  Checks if there are any friendly pieces on the given movements.

  This function is an implementation detail and is not part of the public API.

  Args:
    movements (list(Board.location())): The list of movements to check for friendly pieces.
    board (Board.t()): The game board.
    color (atom()): The color of the current player.

  Returns:
    list(Board.cell()): The list of cells that contain friendly pieces.
  """
  @spec is_there_an_friend?(list(location()), Board.t(), atom()) :: list(Board.cell())
  def is_there_an_friend?(movements, board, color) do
    board
    |> Board.the_cell_is_occupied?(movements, color)
  end

  @doc """
  Checks if there are any enemy pieces on the given cells.

  This function is an implementation detail and is not part of the public API.

  Args:
    cells (Board.cells()): The list of cells to check for enemy pieces.

  Returns:
    Board.cells(): The list of cells that contain enemy pieces.
  """
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
