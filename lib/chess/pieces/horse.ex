defmodule Chess.Pieces.Horse do
  @moduledoc """
  Represents a Horse on the board.
  """
  alias Chess.Board

  @type name :: Atom.t()
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

  @spec calculate_horse_movement(Board.cell()) :: Board.cell()
  def calculate_horse_movement(cell) do
    movements =
      cell
      |> allowed_movements()

    IO.inspect(movements, label: "ALLOWED MOVES")
  end

  @spec allowed_movements(Board.cell()) :: list(Board.location())
  def allowed_movements({x, y, _piece}) do
    {x, y}
    |> possible_movements()

    # |> is_there_an_enemy?()
  end

  @spec is_there_an_enemy?(location()) :: location()
  def is_there_an_enemy?(location) do
    IO.inspect(location, label: "is_there_an_enemy?")
  end

  def possible_movements({x, y}) do
    [
      {x - 2, y - 1},
      {x - 2, y + 1},
      {x + 2, y - 1},
      {x + 2, y + 1}
    ]
    |> Enum.filter(fn {x, y} -> Board.cell_exists?({x, y}) end)
  end
end

#   0  1  2  3  4  5  6  7
# 0[ ][ ][ ][ ][ ][ ][ ][ ]0
# 1[ ][ ][x][ ][x][ ][ ][ ]1
# 2[ ][ ][ ][ ][ ][ ][ ][ ]2
# 3[ ][ ][ ][♞][ ][ ][ ][ ]3
# 4[ ][ ][ ][ ][ ][ ][ ][ ]4
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
