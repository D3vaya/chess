defmodule Chess.Pieces.Bishop do
  @moduledoc """
  Represents a Bishop on the board.
  """
  @type shape :: String.t()
  @type color :: :white | :black
  @type location :: {integer, integer}
  @type t :: %__MODULE__{
          shape: shape(),
          color: color(),
          location: location()
        }

  @enforce_keys [:color]
  defstruct color: nil, location: {0, 0}, shape: ""

  @spec new(color()) :: t()
  def new(color) do
    %__MODULE__{color: color, shape: shape_by_color(color)}
  end

  def shape_by_color(:white) do
    "♗"
  end

  def shape_by_color(:black) do
    "♝"
  end
end
