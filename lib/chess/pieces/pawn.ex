defmodule Chess.Pieces.Pawn do
  @moduledoc """
  Represents a Pawn on the board.
  """

  alias Chess.{Game, Board}

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

  @valid_colors [:white, :black]
  @enforce_keys [:color]
  defstruct name: :pawn, color: nil, location: {0, 0}, shape: ""

  def new(color) when color in @valid_colors do
    %__MODULE__{color: color, shape: shape_by_color(color)}
  end

  defp shape_by_color(:white) do
    "♙"
  end

  defp shape_by_color(:black) do
    "♟"
  end

  @spec calculate_pawn_movement(Game.t(), Board.cell()) :: Board.cells()
  def calculate_pawn_movement(game, {x, y, _piece}) do
    IO.inspect({x, y}, label: "CELL")
  end

  @spec allowed_movements(location()) :: Board.cells()
  def allowed_movements(location) do
    location
    |> is_there_an_enemy?()
  end

  #   0  1  2  3  4  5  6  7
  # 0[ ][ ][ ][ ][ ][ ][ ][ ]0
  # 1[♙][♙][♙][♙][♙][♙][♙][♙]1
  # 2[ ][ ][ ][ ][ ][ ][ ][ ]2
  # 3[ ][ ][ ][ ][ ][ ][ ][ ]3
  # 4[ ][ ][ ][ ][ ][ ][ ][ ]4
  # 5[ ][ ][ ][ ][ ][ ][ ][ ]5
  # 6[♙][♙][♙][♙][♙][♙][♙][♙]6
  # 7[ ][ ][ ][ ][ ][  ][ ][ ]7
  #   0  1  2  3  4  5  6  7

  @spec move(location()) :: location()
  defp move({x, y}) do
    {x + 1, y}
  end

  def is_there_an_enemy?(position) do
  end
end
