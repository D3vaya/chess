defmodule Chess.Game do
  alias Chess.Pieces.Horse
  alias Chess.Pieces.Pawn
  alias Chess.Board

  @type t :: %__MODULE__{
          board: Board.t(),
          turn: :white | :black,
          movement_number: integer(),
          movement_history: list(Board.t())
        }
  defstruct board: %{}, turn: nil, movement_number: 0, movement_history: []

  def new do
    %__MODULE__{
      board: Board.new(),
      turn: :white,
      movement_number: 0,
      movement_history: []
    }
  end

  @spec calculate_movement(t(), Board.cell()) :: list(Board.location())
  def calculate_movement(game, cell) do
    piece = Board.get_piece(game.board, cell)

    movements =
      case piece do
        %Chess.Pieces.Horse{} -> Horse.calculate_horse_movement(cell)
        %Chess.Pieces.Pawn{} -> Pawn.calculate_pawn_movement(game, cell)
        %Chess.Pieces.Tower{} -> []
        nil -> []
      end

    # IO.inspect(game.turn, label: "GAME")
    # IO.inspect(cell, label: "CELL")

    movements
  end

  @spec change_shift(t()) :: t()
  def change_shift(game) do
    %{game | turn: evaluate_shift(game.turn)}
  end

  @spec evaluate_shift(:white | :black) :: :white | :black
  defp evaluate_shift(turn) do
    case turn do
      :white -> :black
      :black -> :white
    end
  end
end
