defmodule Chess.Pieces.Tower do
  @moduledoc """
  Represents a Tower on the board.
  """
  @type color :: :white | :black
  @type location :: {integer, integer}
  @type t :: %__MODULE__{
          color: color(),
          location: location()
        }

  @enforce_keys [:color]
  defstruct color: nil, location: {0, 0}

  @valid_colors [:white, :black]

  @spec new(color()) :: t()
  def new(color) when color in @valid_colors do
    %__MODULE__{color: color}
    |> default_location
  end

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
  @spec default_location(t()) :: t()
  defp default_location(tower) do
    %{tower | location: default_location_for(tower.color)}
  end

  defp default_location_for(:black) do
    {0, 0}
  end

  defp default_location_for(:white) do
    {0, 7}
  end
end
