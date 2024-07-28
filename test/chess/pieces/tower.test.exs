defmodule Chess.Pieces.Tower do
  use ExUnit
  alias Chess.{Pieces.Tower}

  describe "Creación de la pieza Torre" do
    setup do
      white_tower = Tower.new(:white)
      black_tower = Tower.new(:black)

      %{white_tower: white_tower, black_tower: black_tower}
    end

    test "Creación de la pieza Torre de color blanco", %{white_tower: tower} do
      assert tower.color == :white
      assert tower.location == {0, 1}
    end

    test "Creación de la pieza Torre de color negro", %{black_tower: tower} do
      assert tower.color == :black
      assert tower.location == {7, 1}
    end
  end
end
