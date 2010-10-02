require "go/gtp/board"

describe Go::GTP::Board do
  before :all do
    @string = <<-END_BOARD.gsub(/^ {4}/, "")
       A B C D E F G H J
     9 . . . . . . . . . 9
     8 . . . . . . . . . 8
     7 . . X . . . + . . 7
     6 . . . . . . . . . 6
     5 . . . . + . . . . 5
     4 . . . . . . . . . 4
     3 . . + . . O + . . 3
     2 . . . . . . . . . 2     WHITE (O) has captured 10 stones
     1 . . . . . . . . . 1     BLACK (X) has captured 11 stones
       A B C D E F G H J
    END_BOARD
    @board = Go::GTP::Board.new(@string)
  end
  
  it "should stringify to what it was created from" do
    @board.to_s.should == @string
  end
  
  it "should be possible to get the board as an array of arrays" do
    @board.to_a.should == [
      [nil, nil, nil,     nil, nil, nil,     nil, nil, nil],
      [nil, nil, nil,     nil, nil, nil,     nil, nil, nil],
      [nil, nil, "black", nil, nil, nil,     nil, nil, nil],
      [nil, nil, nil,     nil, nil, nil,     nil, nil, nil],
      [nil, nil, nil,     nil, nil, nil,     nil, nil, nil],
      [nil, nil, nil,     nil, nil, nil,     nil, nil, nil],
      [nil, nil, nil,     nil, nil, "white", nil, nil, nil],
      [nil, nil, nil,     nil, nil, nil,     nil, nil, nil],
      [nil, nil, nil,     nil, nil, nil,     nil, nil, nil]
    ]
  end
  
  it "should support indexing by coordinates" do
    @board[0, 0].should be_nil
    @board[2, 2].should satisfy { |color| color == "black" }
    @board[5, 6].should satisfy { |color| color == "white" }
  end
  
  it "should support indexing by vertices" do
    @board["A1"].should be_nil
    @board["C7"].should satisfy { |color| color == "black" }
    @board["F3"].should satisfy { |color| color == "white" }
  end
  
  it "should fail to index for any other combination" do
    lambda { @board["A", "1"] }.should raise_error(ArgumentError)
  end
  
  it "should be able to count captures by color name" do
    @board.captures("white").should satisfy { |stones| stones == 10 }
    @board.captures("WHITE").should satisfy { |stones| stones == 10 }
    @board.captures("black").should satisfy { |stones| stones == 11 }
    @board.captures("BLACK").should satisfy { |stones| stones == 11 }
  end
  
  it "should be able to count captures by stone type" do
    @board.captures("o").should satisfy { |stones| stones == 10 }
    @board.captures("O").should satisfy { |stones| stones == 10 }
    @board.captures("x").should satisfy { |stones| stones == 11 }
    @board.captures("X").should satisfy { |stones| stones == 11 }
  end
end
