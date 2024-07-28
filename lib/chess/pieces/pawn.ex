defmodule Chess.Pieces.Pawn do
  @moduledoc """
  Represents a Pawn on the board.
  """

  @enforce_keys [:color]
  defstruct color: nil, location: {0, 0}

  @type color :: :white | :black
  @type location :: {integer, integer}
  @type t :: %__MODULE__{
          color: color(),
          location: location()
        }

  @valid_colors [:white, :black]

  def new(color) when color in @valid_colors do
    %__MODULE__{color: color}
  end

  #                                                X
  #   0   1   2   3   4   5   6   7                |
  # 0[  ][  ][  ][  ][  ][  ][  ][  ]0             |
  # 1[📍][📍][📍][📍][📍][📍][📍][📍]1             |
  # 2[  ][  ][  ][  ][  ][  ][  ][  ]2             |
  # 3[  ][  ][  ][  ][  ][  ][  ][  ]3 Y________________________Y
  # 4[  ][  ][  ][  ][  ][  ][  ][  ]4             |
  # 5[  ][  ][  ][  ][  ][  ][  ][  ]5             |
  # 6[📍][📍][📍][📍][📍][📍][📍][📍]6             |
  # 7[  ][  ][  ][  ][  ][  ][  ][  ]7             |
  #   0   1   2   3   4   5   6   7                X

  def position_pawn(pawn, %{row: row, column: column}) do
    %{pawn | location: {row, column + 1}}
  end

  @spec move(location()) :: location()
  def move({x, y}) do
    {x + 1, y}
  end

  
end
