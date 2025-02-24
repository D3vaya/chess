defmodule ChessWeb.CellComponent do
  use Phoenix.Component

  attr :x, :integer, required: true
  attr :y, :integer, required: true
  attr :piece, :any, default: nil
  attr :selected_cell, :any, default: nil
  attr :possible_movements, :list, default: []
  attr :position_king_in_check, :any, default: nil

  def cell(assigns) do
    ~H"""
    <div
      class={[
        "w-10 h-10 flex items-center justify-center cursor-pointer",
        if(rem(@x + @y, 2) == 0, do: "bg-white text-black", else: "bg-black text-white"),
        if(@selected_cell == {@x, @y, @piece} and @piece != nil, do: "!bg-lime-300", else: ""),
        if({@x, @y} in @possible_movements and @position_king_in_check == nil,
          do: "!bg-green-300 border shadow-2xl animate-pulse",
          else: ""
        ),
        if(@position_king_in_check == {@x, @y}, do: "!bg-red-300 shadow-2xl animate-pulse", else: ""),
        "hover:bg-green-200 transition-opacity"
      ]}
      phx-click="select_cell"
      cell="cell"
      phx-value-x={@x}
      phx-value-y={@y}
      phx-value-piece-type={if @piece, do: Atom.to_string(@piece.__struct__), else: nil}
      phx-value-piece-color={if @piece, do: @piece.color, else: nil}
      phx-value-piece-shape={if @piece, do: @piece.shape, else: nil}
      phx-value-piece-name={if @piece, do: @piece.name, else: nil}
    >
      <span class="text-2xl font-bold"><%= if @piece, do: @piece.shape, else: "" %></span>
    </div>
    """
  end
end
