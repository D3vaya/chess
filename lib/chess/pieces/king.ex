defmodule Chess.Pieces.King do
  @moduledoc """
  Represents a King on the board.
  """
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
  defstruct name: :king, color: nil, location: {0, 0}, shape: ""

  @spec new(color()) :: t()
  def new(color) do
    %__MODULE__{color: color, shape: shape_by_color(color)}
  end

  defp shape_by_color(:white) do
    "♔"
  end

  defp shape_by_color(:black) do
    "♚"
  end
end
