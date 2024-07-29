defmodule Chess.Board do
  alias Chess.Pieces.{Tower, Horse, Pawn, Queen, King, Bishop}

  defstruct cells: %{},
            pieces: [],
            castling: [],
            box_on_theway: []

  @type cell :: {
          x :: integer(),
          y :: integer(),
          piece :: Tower.t() | Horse.t() | Pawn.t() | Queen.t() | King.t() | Bishop.t() | nil
        }

  @type cells :: [cell()]
  @type piece :: Tower.t()
  @type location :: {integer(), integer()}

  @type t :: %__MODULE__{
          cells: cells(),
          pieces: list(),
          castling: list(),
          box_on_theway: list()
        }

  @board_range 0..7
  def new() do
    %__MODULE__{
      cells: [],
      pieces: [],
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
  def place_pieces(board) do
    board
    |> place_towers()
    |> place_hourses()
    |> place_bishops()
    |> place_queens()
    |> place_kings()
    |> place_pawns()
  end

  @spec place_towers(t()) :: t()
  defp place_towers(board) do
    board
    |> put_piece({0, 0}, Tower.new(:black))
    |> put_piece({0, 7}, Tower.new(:black))
    |> put_piece({7, 0}, Tower.new(:white))
    |> put_piece({7, 7}, Tower.new(:white))
  end

  @spec place_hourses(t()) :: t()
  defp place_hourses(board) do
    board
    |> put_piece({0, 1}, Horse.new(:black))
    |> put_piece({0, 6}, Horse.new(:black))
    |> put_piece({7, 1}, Horse.new(:white))
    |> put_piece({7, 6}, Horse.new(:white))
    # test horse
    |> put_piece({3, 3}, Horse.new(:white))
  end

  @spec place_bishops(t()) :: t()
  defp place_bishops(board) do
    board
    |> put_piece({0, 2}, Bishop.new(:black))
    |> put_piece({0, 5}, Bishop.new(:black))
    |> put_piece({7, 2}, Bishop.new(:white))
    |> put_piece({7, 5}, Bishop.new(:white))
  end

  @spec place_queens(t()) :: t()
  defp place_queens(board) do
    board
    |> put_piece({0, 3}, Queen.new(:black))
    |> put_piece({7, 3}, Queen.new(:white))
  end

  @spec place_kings(t()) :: t()
  defp place_kings(board) do
    board
    |> put_piece({0, 4}, King.new(:black))
    |> put_piece({7, 4}, King.new(:white))
  end

  @spec place_pawns(t()) :: t()
  defp place_pawns(board) do
    board
    |> put_piece({1, 0}, Pawn.new(:black))
    |> put_piece({1, 1}, Pawn.new(:black))
    |> put_piece({1, 2}, Pawn.new(:black))
    |> put_piece({1, 3}, Pawn.new(:black))
    |> put_piece({1, 4}, Pawn.new(:black))
    |> put_piece({1, 5}, Pawn.new(:black))
    |> put_piece({1, 6}, Pawn.new(:black))
    |> put_piece({1, 7}, Pawn.new(:black))
    |> put_piece({6, 0}, Pawn.new(:white))
    |> put_piece({6, 1}, Pawn.new(:white))
    |> put_piece({6, 2}, Pawn.new(:white))
    |> put_piece({6, 3}, Pawn.new(:white))
    |> put_piece({6, 4}, Pawn.new(:white))
    |> put_piece({6, 5}, Pawn.new(:white))
    |> put_piece({6, 6}, Pawn.new(:white))
    |> put_piece({6, 7}, Pawn.new(:white))
    # test pawn
    |> put_piece({5, 0}, Pawn.new(:white))
    |> put_piece({5, 2}, Pawn.new(:black))
  end

  defp put_piece(board, {row, col}, piece) do
    updated_piece = %{piece | location: {row, col}}

    updated_cells =
      Enum.map(board.cells, fn
        {^row, ^col, _} -> {row, col, updated_piece}
        cell -> cell
      end)

    %{board | cells: updated_cells, pieces: [updated_piece | board.pieces]}
  end

  @spec get_piece(t(), cell()) :: piece() | nil
  def get_piece(board, cell) do
    board.cells
    |> Enum.find(fn c -> c == cell end)
    |> elem(2)
  end

  @doc """
  Checks if the given cell coordinates are within the valid range of the chess board.

  The valid range for the chess board is 0 to 7 for both the row and column coordinates.

  ## Examples

      iex> cell_exists?({0, 0})
      true
      iex> cell_exists?({8, 0})
      false

  ## Parameters

  - `{x, y}`: A tuple representing the row and column coordinates of the cell to check.

  ## Returns

  - `true` if the cell coordinates are within the valid range, `false` otherwise.
  """
  @spec cell_exists?(location()) :: boolean()
  def cell_exists?({x, y}) do
    Enum.member?(@board_range, x) && Enum.member?(@board_range, y)
  end

  @spec the_cell_is_occupied?(t(), list(location()), atom()) :: list(cell())
  def the_cell_is_occupied?(board, movements, color) do
    board.cells
    |> Enum.filter(fn {x, y, piece} ->
      Enum.member?(movements, {x, y}) and (piece == nil or piece.color != color)
    end)
  end
end
