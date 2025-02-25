defmodule Chess.Game do
  alias Chess.{Board, Types, GameRules}

  @type t :: %__MODULE__{
          board: Board.t(),
          turn: :white | :black,
          movement_number: integer(),
          movement_history: Types.cells()
        }
  defstruct board: %{},
            turn: nil,
            movement_number: 0,
            movement_history: []

  def new do
    %__MODULE__{
      board: Board.new(),
      turn: :white,
      movement_number: 0,
      movement_history: []
    }
  end

  @doc """
  Evaluates the next player's turn based on the current turn.

  If the current turn is `:white`, this function returns `:black`. If the current turn is `:black`, this function returns `:white`.

  This function is used to update the `turn` field in the `Chess.Game` struct after a move has been made.
  """
  @spec change_shift(t()) :: t()
  def change_shift(game) do
    %{game | turn: evaluate_shift(game.turn)}
  end

  # Evaluates the next player's turn based on the current turn.
  # If the current turn is `:white`, this function returns `:black`. If the current turn is `:black`, this function returns `:white`.
  # This function is used to update the `turn` field in the `Chess.Game` struct after a move has been made.
  @spec evaluate_shift(:white | :black) :: :white | :black
  defp evaluate_shift(turn) do
    case turn do
      :white -> :black
      :black -> :white
    end
  end

  @doc """
  Moves a piece on the game board to a new location.

  This function takes the current game state, the piece to be moved, and the new location for the piece. It updates the game board with the new piece position, increments the movement number, updates the turn, and adds the movement to the movement history.

  Parameters:
    - `game`: the current game state
    - `{x, y, piece}`: the piece to be moved and its current location
    - `{to_x, to_y}`: the new location for the piece

  Returns:
    the updated game state with the piece moved
  """
  @spec move_piece(t(), Types.cell(), Types.location()) :: t()
  def move_piece(game, {x, y, piece}, {to_x, to_y}) do
    updated_board =
      game.board
      |> Board.clean_cell({x, y})
      |> Board.put_piece({to_x, to_y}, piece)
      |> GameRules.check_for_checkmate({to_x, to_y})

    updated_game =
      game
      |> change_shift()
      |> add_movement_number()
      |> add_movement_to_the_history({to_x, to_y, piece})

    %{updated_game | board: updated_board}
  end

  @doc """
  Adds a new movement to the movement history list.

  This function takes the current list of movements and a new movement, and returns a new list with the new movement prepended to the existing list.

  This function is used to update the movement history in the game state after a piece has been moved.

  Parameters:
    - `list_movements`: the current list of movements
    - `movement`: the new movement to add to the history

  Returns:
    the updated list of movements with the new movement added
  """
  @spec add_movement_to_the_history(t(), Types.cell()) :: t()
  def add_movement_to_the_history(game, movement) do
    %{game | movement_history: [movement | game.movement_history]}
  end

  @doc """
  Increments the movement number by 1.

  This function is used to update the movement number in the game state after a piece has been moved.

  Returns the updated movement number.
  """

  @spec add_movement_number(t()) :: t()
  def add_movement_number(game) do
    %{game | movement_number: game.movement_number + 1}
  end
end
