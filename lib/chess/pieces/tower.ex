defmodule Chess.Pieces.Tower do
  @moduledoc """
  Represents a Tower on the board.
  """
  @type shape :: String.t()
  @type color :: :white | :black
  @type location :: {integer, integer} | nil
  @type t :: %__MODULE__{
          shape: shape(),
          color: color(),
          location: location()
        }

  @enforce_keys [:color]
  defstruct color: nil, location: nil, shape: ""

  @valid_colors [:white, :black]

  @spec new(color()) :: t()
  def new(color) when color in @valid_colors do
    %__MODULE__{color: color, shape: shape_by_color(color)}
  end

  def shape_by_color(:white) do
    "♖"
  end

  def shape_by_color(:black) do
    "♜"
  end

  # ♔ ♕ ♖ ♗ ♘ ♙ ♚ ♛ ♜ ♝ ♞ ♟

  #   0   1   2   3   4   5   6   7
  # 7[📍][  ][  ][  ][  ][  ][  ][📍]7
  # 6[  ][  ][  ][  ][  ][  ][  ][  ]6
  # 5[  ][  ][  ][  ][  ][  ][  ][  ]5
  # 4[  ][  ][  ][  ][  ][  ][  ][  ]4
  # 3[  ][  ][  ][  ][  ][  ][  ][  ]3
  # 2[  ][  ][  ][  ][  ][  ][  ][  ]2
  # 1[  ][  ][  ][  ][  ][  ][  ][  ]1
  # 0[📍][  ][  ][  ][  ][  ][  ][📍]0
  #   0   1   2   3   4   5   6   7
end
