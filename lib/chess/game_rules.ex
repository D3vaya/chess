defmodule Chess.GameRules do
  alias Chess.Board

  @type location :: Board.location()
  @type piece :: Board.piece()

  @doc """
  Checks if a move results in a checkmate situation.

  ## Parameters
    - board: The current state of the chess board
    - position: The position {x, y} to check for checkmate

  ## Returns
    Updated board with the position of the king in check (if any)

  ## Examples
      iex> check_for_checkmate(board, {4, 4})
      %Board{position_king_in_check: {0, 0}}
  """
  @spec check_for_checkmate(Board.t(), location()) :: Board.t()
  def check_for_checkmate(board, position = {x, y}) do
    case Board.get_piece_from_board(board, position) do
      {^x, ^y, piece} ->
        updated_piece = %{piece | location: position}
        moves = Board.calculate_movement(board, {x, y, updated_piece})
        king_position = Board.find_checked_king_position(moves, board, updated_piece.color)
        %{board | position_king_in_check: king_position}

      nil ->
        board
    end
  end
end
