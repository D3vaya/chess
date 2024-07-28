defmodule Chess.Board do
  defstruct cells: %{}

  def new() do
    cells = for row <- 0..8, column <- 0..8, do: {row, column}
    IO.puts("Nro de Celdas #{length(cells)}")
    %__MODULE__{cells: cells}
  end
end
