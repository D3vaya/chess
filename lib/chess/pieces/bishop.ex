defmodule Chess.Pieces.Bishop do
  @moduledoc """
  Represents a Bishop on the board.
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
  def new(color) do
    %__MODULE__{color: color}
  end
end
