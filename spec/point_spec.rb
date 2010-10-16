require "go/gtp/point"

describe Go::GTP::Point do
  it "should initialize from an x, y integer index pair" do
    lambda { Go::GTP::Point.new(0, 2) }.should_not raise_error(ArgumentError)
  end

  it "should initialize from a GNU Go letter and integer pair" do
    lambda { Go::GTP::Point.new("A12") }.should_not raise_error(ArgumentError)
  end

  it "should initialize from an SGF letter pair" do
    lambda { Go::GTP::Point.new("ad") }.should_not raise_error(ArgumentError)
  end
  
  it "should fail with an argmument error with any other arguments" do
    lambda { Go::GTP::Point.new("junk") }.should raise_error(ArgumentError)
  end
  
  context "initialized from any format" do
    before :all do
      @points = [[0, 2], "A17", "ac"].map { |args| Go::GTP::Point.new(*args) }
    end
    
    it "should track its indices" do
      @points.each do |point|
        point.x.should satisfy { |x| x == 0 }
        point.y.should satisfy { |y| y == 2 }
      end
    end
    
    it "should convert to indices" do
      @points.each do |point|
        point.to_indexes.should satisfy { |xy| xy == [0, 2] }
        point.to_indices.should satisfy { |xy| xy == [0, 2] }
      end
    end
    
    it "should convert to SGF letters" do
      @points.each do |point|
        point.to_sgf.should == "ac"
      end
    end
    
    it "should convert to GNU Go letters and numbers" do
      @points.each do |point|
        point.to_gnugo.should satisfy { |ln| ln == "A17" }
        point.to_s.should     satisfy { |ln| ln == "A17" }
      end
    end
  end
  
  context "in the GNU Go format" do
    it "should default to assuming a 19x19 board on creation" do
      Go::GTP::Point.new("A13").to_indices.should == [0, 6]
    end

    it "should allow you to override board size on creation" do
      Go::GTP::Point.new("A13", board_size: 13).to_indices.should == [0, 0]
    end

    it "should default to assuming a 19x19 board on conversion" do
      Go::GTP::Point.new(0, 6).to_gnugo.should == "A13"
    end

    it "should allow you to override board size on conversion" do
      Go::GTP::Point.new(0, 0).to_gnugo(13).should == "A13"
    end
    
    it "should skip over the unused I column" do
      Go::GTP::Point.new("H19").to_indices.should satisfy { |ln| ln == [7, 0] }
      Go::GTP::Point.new("J19").to_indices.should satisfy { |ln| ln == [8, 0] }

      Go::GTP::Point.new("ha").to_gnugo.should satisfy { |ln| ln == "H19" }
      Go::GTP::Point.new("ia").to_gnugo.should satisfy { |ln| ln == "J19" }
    end
  end
end
