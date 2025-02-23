defmodule Chess.Pieces.Bishop do
  alias Chess.Types

  @moduledoc """
  Represents a Bishop on the board.
  """
  @type name :: atom()
  @type color :: Types.color()
  @type location :: Types.location()
  @type t :: %__MODULE__{
          name: name(),
          shape: Types.shape(),
          color: color(),
          location: location()
        }

  @enforce_keys [:color]
  defstruct name: :bishop, color: nil, location: {0, 0}, shape: ""

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
