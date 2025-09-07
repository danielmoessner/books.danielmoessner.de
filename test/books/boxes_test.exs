defmodule Books.BoxesTest do
  use Books.DataCase

  alias Books.Boxes

  describe "boxes" do
    alias Books.Boxes.Box

    import Books.BoxesFixtures

    @invalid_attrs %{name: nil}

    test "list_boxes/0 returns all boxes" do
      box = box_fixture()
      assert Boxes.list_boxes() == [box]
    end

    test "get_box!/1 returns the box with given id" do
      box = box_fixture()
      assert Boxes.get_box!(box.id) == box
    end

    test "create_box/1 with valid data creates a box" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Box{} = box} = Boxes.create_box(valid_attrs)
      assert box.name == "some name"
    end

    test "create_box/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Boxes.create_box(@invalid_attrs)
    end

    test "update_box/2 with valid data updates the box" do
      box = box_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Box{} = box} = Boxes.update_box(box, update_attrs)
      assert box.name == "some updated name"
    end

    test "update_box/2 with invalid data returns error changeset" do
      box = box_fixture()
      assert {:error, %Ecto.Changeset{}} = Boxes.update_box(box, @invalid_attrs)
      assert box == Boxes.get_box!(box.id)
    end

    test "delete_box/1 deletes the box" do
      box = box_fixture()
      assert {:ok, %Box{}} = Boxes.delete_box(box)
      assert_raise Ecto.NoResultsError, fn -> Boxes.get_box!(box.id) end
    end

    test "change_box/1 returns a box changeset" do
      box = box_fixture()
      assert %Ecto.Changeset{} = Boxes.change_box(box)
    end
  end
end
