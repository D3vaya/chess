defmodule Chess.Board do
  alias Chess.Pieces.{Tower, Horse, Pawn, Queen, King, Bishop}

  @type cells :: [cell()]
  @type piece :: Tower.t() | Horse.t() | Pawn.t() | Queen.t() | King.t() | Bishop.t() | nil
  @type location :: {integer(), integer()}

  @type cell :: {
          x :: integer(),
          y :: integer(),
          piece :: piece()
        }

  @type t :: %__MODULE__{
          cells: cells(),
          pieces: list(),
          castling: list(),
          box_on_theway: list(),
          position_king_in_check: location()
        }
  defstruct cells: %{},
            pieces: [],
            castling: [],
            box_on_theway: [],
            position_king_in_check: {}

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

    # test
    |> put_piece({3, 7}, King.new(:black))
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
  end

  ######################################################################
  ######################################################################

  @doc """
  Calculates the possible movements for a piece on the chess board.

  ## Parameters

  - `board`: The current state of the chess board.
  - `cell`: The cell containing the piece for which to calculate the possible movements.

  ## Returns

  A list of locations representing the possible movements for the piece.
  """
  @spec calculate_movement(t(), cell()) :: list(location())
  def calculate_movement(board, cell) do
    selected_piece = get_piece_struct(board, cell)

    movements =
      case selected_piece do
        %Chess.Pieces.Horse{} -> Horse.calculate_horse_movement(board, cell)
        nil -> []
      end

    # IO.inspect(game.turn, label: "GAME")
    # IO.inspect(cell, label: "CELL")

    movements
  end

  @doc """
  Places a piece on the chess board at the given row and column coordinates.

  ## Parameters

  - `board`: The current state of the chess board.
  - `{row, col}`: A tuple representing the row and column coordinates where the piece should be placed.
  - `piece`: The piece to be placed on the board.

  ## Returns

  The updated chess board with the piece placed at the specified location.
  """
  @spec put_piece(t(), location(), piece()) :: t()
  def put_piece(board, {row, col}, piece) do
    updated_piece = %{piece | location: {row, col}}

    updated_cells =
      Enum.map(board.cells, fn
        {^row, ^col, _} -> {row, col, updated_piece}
        cell -> cell
      end)

    %{board | cells: updated_cells, pieces: [updated_piece | board.pieces]}
  end

  @doc """
  Removes the piece from the specified cell on the chess board.

  ## Parameters

  - `board`: The current state of the chess board.
  - `{x, y}`: A tuple representing the row and column coordinates of the cell to be cleared.

  ## Returns

  The updated chess board with the piece removed from the specified cell.
  """
  @spec clean_cell(t(), location()) :: t()
  def clean_cell(board, {x, y}) do
    updated_cells =
      Enum.map(board.cells, fn
        {^x, ^y, _} -> {x, y, nil}
        cell -> cell
      end)

    %{board | cells: updated_cells}
  end

  @doc """
  Returns the piece struct for the given cell on the chess board.

  ## Parameters

  - `board`: The current state of the chess board.
  - `cell`: A tuple representing the row and column coordinates of the cell.

  ## Returns

  The piece struct for the given cell, or `nil` if the cell is empty.
  """
  @spec get_piece_struct(t(), cell()) :: piece() | nil
  def get_piece_struct(board, cell) do
    board.cells
    |> Enum.find(fn c -> c == cell end)
    |> case do
      nil -> nil
      found_cell -> elem(found_cell, 2)
    end
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

  @doc """
  Checks if any of the given cell coordinates in the `movements` list are occupied by a piece of the opposite color on the given `board`.

  ## Parameters

  - `board`: The current state of the chess board.
  - `movements`: A list of cell coordinates to check for occupancy.
  - `color`: The color of the piece that is checking the occupancy.

  ## Returns

  A list of the cell coordinates that are occupied by a piece of the opposite color.
  """
  @spec the_cell_is_occupied?(t(), list(location()), atom()) :: list(cell())
  def the_cell_is_occupied?(board, movements, color) do
    board.cells
    |> Enum.filter(fn {x, y, piece} ->
      Enum.member?(movements, {x, y}) and (piece == nil or piece.color != color)
    end)
  end

  @spec check_for_checkmate(t(), location()) :: t()
  def check_for_checkmate(board, {x, y}) do
    {_x, _y, piece} =
      board.cells
      |> Enum.find(fn {cell_x, cell_y, _piec} -> {cell_x, cell_y} == {x, y} end)

    updated_piece = %{piece | location: {x, y}}

    position_king_chake =
      calculate_movement(board, {x, y, updated_piece})
      |> find_checked_king_position(board, updated_piece.color)

    %{board | position_king_in_check: position_king_chake}
  end

  @doc """
  Encuentra la posición del rey en jaque, si existe.

  ## Parámetros

    - movements: Lista de movimientos posibles.
    - board: El tablero actual.
    - color: El color de la pieza que está realizando el movimiento.

  ## Retorna

    La posición del rey en jaque como una tupla {x, y}, o nil si no hay rey en jaque.
  """
  @spec find_checked_king_position(list(location()), t(), atom()) :: location() | nil
  def find_checked_king_position(movements, board, color) do
    case Enum.find(board.cells, fn {x, y, piece} ->
           {x, y} in movements and piece != nil and piece.color != color and piece.name == :king
         end) do
      {x, y, _piece} -> {x, y}
      nil -> nil
    end
  end
end
