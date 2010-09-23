require "stringio"

require "go/gtp"

class MockPipe
  def initialize(input)
    @input  = StringIO.new(input)
    @output = StringIO.new
    @closed = false
  end
  
  attr_reader :input, :output
  
  def puts(*args)
    @output.puts(*args)
  end
  
  def close
    @closed = true
  end
  
  def closed?
    @closed
  end
  
  def method_missing(meth, *args, &blk)
    @input.send(meth, *args, &blk)
  end
end

describe Go::GTP do
  def gtp(input = "=1", &commands)
    @pipe = MockPipe.new(input)
    return [Go::GTP.new(@pipe, &commands), @pipe.input, @pipe.output]
  end
  
  it "should send quit after running a provided block" do
    ran          = false
    _, _, output = gtp do
      ran        = true
    end
    ran.should be(true)
    output.string.should match(/\A\d+\s+quit\Z/)
  end
  
  context "when connected" do
    before :each do
      @go, @input, @output = gtp
    end
    
    def add_input(input)
      @input << input
      @input.rewind
    end
    
    it "should return an instance without sending commands without a block" do
      @output.string.should be_empty
    end

    it "should report the success of the last command" do
      @go.clear_board
      @go.should be_success
    end

    it "should not report success if the last command failed" do
      add_input("?1 error message")
      @go.clear_board
      @go.should_not be_success
    end

    it "should not have an error after a successful command" do
      @go.clear_board.should be(true)
      @go.last_error.should be_nil
    end

    it "should have an error after an unsuccessful command" do
      add_input("?1 error message")
      @go.clear_board.should be(false)
      @go.last_error.should == "error message"
    end
    
    it "should close the IO on quit" do
      @pipe.should_not be_closed
      @go.quit
      @pipe.should be_closed
    end
    
    it "should return output from commands that return data" do
      add_input("=1 2.0")
      @go.protocol_version.should == "2.0"
    end
    
    it "should return the success or failure of boolean operations" do
      @go.boardsize(9).should == @go.success?
    end
    
    it "should support the query interface for boolean operations" do
      @go.boardsize?(9).should == @go.success?
    end
    
    it "should return lists of vertices in an array" do
      add_input("=1 A1 B2")
      @go.fixed_handicap(2) == %w[A1 B1]
    end
    
    it "should return boolean results as true and false" do
      add_input("=1 1\n\n=2 0")
      @go.is_legal?("black", "A1").should be(true)
      @go.is_legal?("black", "B1").should be(false)
    end
    
    it "should return board diagrams wrapped in an appropriate object" do
      add_input("=1 board")
      @go.showboard.should be_an_instance_of(Go::GTP::Board)
    end
    
    it "should support a dual interface for methods that can return data" do
      add_input("=1 board\n\n=2")
      @go.printsgf.should be_an_instance_of(Go::GTP::Board)
      @go.printsgf?("/path/to/file").should be(true)
    end
  end
end
