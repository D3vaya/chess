defmodule Chess.Board do
  alias Chess.Pieces.{Tower}

  defstruct cells: %{},
            pieces: [],
            turn: nil,
            movement_number: 0,
            movement_history: [],
            castling: [],
            box_on_theway: []

  @type cell :: {
          x :: integer(),
          y :: integer(),
          piece :: Tower.t() | nil
        }

  @type cells :: [cell()]
  @type piece :: Tower.t()
  @type location :: {integer(), integer()}

  @type t :: %__MODULE__{
          cells: cells(),
          pieces: list(),
          turn: :white | :black,
          movement_number: integer(),
          movement_history: list(),
          castling: list(),
          box_on_theway: list()
        }

  def new() do
    %__MODULE__{
      cells: [],
      turn: :white,
      pieces: [],
      movement_number: 0,
      movement_history: [],
      castling: [],
      box_on_theway: []
    }
    |> create_cells
    |> place_pieces
  end

  @spec put_piece(t(), location(), piece()) :: t()
  defp create_cells(board) do
    cells = for row <- 0..7, column <- 0..7, do: {row, column, nil}
    %{board | cells: cells}
  end

  @spec place_pieces(t()) :: t()
  defp place_pieces(board) do
    board
    |> place_towers()

    # |> place_hourses()
    # |> place_bishops()
    # |> place_queens()
    # |> place_kings()
    # |> place_pawns()
  end

  defp place_towers(board) do
    board
    |> put_piece({0, 0}, Tower.new(:black))
    |> put_piece({0, 7}, Tower.new(:white))
    |> put_piece({7, 0}, Tower.new(:black))
    |> put_piece({7, 7}, Tower.new(:white))
  end

  defp put_piece(board, {row, col}, piece) do
    updated_piece = %{piece | location: {row, col}}
    IO.inspect(piece)

    updated_cells =
      Enum.map(board.cells, fn
        {^row, ^col, _} -> {row, col, updated_piece}
        cell -> cell
      end)

    %{board | cells: updated_cells, pieces: [updated_piece | board.pieces]}
  end

  # defp place_hourses(board) do
  # end

  # defp place_bishops(board) do
  # end

  # defp place_queens(board) do
  # end

  # defp place_kings(board) do
  # end

  # defp place_pawns(board) do
  # end
end
