defmodule Chess.Types do
  alias Chess.Pieces.{Tower, Horse, Pawn, Queen, King, Bishop}

  @moduledoc """
  Common types used across the Chess application.
  """

  @typedoc """
  Represents a location on the chess board.
  It can be either a tuple of {x, y} coordinates or nil when no location is set.
  """
  @type location :: {integer, integer} | nil

  @typedoc """
  Represents the possible colors in the game.
  """
  @type color :: :white | :black

  @typedoc """
  Common movement direction types.
  """
  @type direction :: :horizontal | :vertical | :diagonal

  @typedoc """
  Common shape piece types.
  """
  @type shape :: String.t()

  @typedoc """
  A list of board locations, where each location is a coordinate pair or nil.
  """
  @type locations :: list(location())

  @typedoc """
  Represents any chess piece on the board.
  Can be one of: Tower, Horse, Pawn, Queen, King, Bishop, or nil when empty.
  """
  @type piece :: Tower.t() | Horse.t() | Pawn.t() | Queen.t() | King.t() | Bishop.t() | nil

  @typedoc """
  Represents a cell on the chess board.
  Contains the x and y coordinates and the piece (if any) occupying that cell.

  ## Fields
    - x: The horizontal coordinate (0-7)
    - y: The vertical coordinate (0-7)
    - piece: The chess piece occupying this cell, or nil if empty
  """
  @type cell :: {
          x :: integer(),
          y :: integer(),
          piece :: piece()
        }

  @typedoc """
  A list of board cells representing the current state of multiple board positions.
  """
  @type cells :: list(cell())
end
