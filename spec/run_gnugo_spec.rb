require "go/gtp"

describe Go::GTP, "when connecting to GNU Go" do
  before :all do
    Go::GTP::IO = mock
  end
  
  it "should return a connected instance" do
    Go::GTP::IO.should_receive(:popen)
    Go::GTP.run_gnugo.should be_an_instance_of(Go::GTP)
  end
  
  it "should open the connection in reading and writing mode" do
    Go::GTP::IO.should_receive(:popen) do |_, mode|
      mode.should match(/\A[rw]\+\z/)
    end
    Go::GTP.run_gnugo
  end
  
  it "should default to using no directory" do
    Go::GTP::IO.should_receive(:popen) do |path, _|
      path.should match(/\Agnugo\b/)
    end
    Go::GTP.run_gnugo
  end
  
  it "should allow the directory to be overriden" do
    Go::GTP::IO.should_receive(:popen) do |path, _|
      path.should match(%r{\A/usr/local/bin/gnugo\b})
    end
    Go::GTP.run_gnugo(:directory => "/usr/local/bin")
  end
  
  it "should default to using gnugo in GTP mode" do
    Go::GTP::IO.should_receive(:popen) do |path, _|
      path.should match(/\Agnugo\b.*--mode\s+gtp\b/)
    end
    Go::GTP.run_gnugo
  end
  
  it "should allow the command to be overriden" do
    Go::GTP::IO.should_receive(:popen) do |path, _|
      path.should match(/\Amy_go\b/)
    end
    Go::GTP.run_gnugo(:command => "my_go")
  end
  
  it "should default to using no arguments" do
    Go::GTP::IO.should_receive(:popen) do |path, _|
      path.should_not match(/--(?!mode\b)\w+/)
    end
    Go::GTP.run_gnugo
  end
  
  it "should allow the arguments to be overriden" do
    Go::GTP::IO.should_receive(:popen) do |path, _|
      path.should match(/--boardsize\s+9\b/)
    end
    Go::GTP.run_gnugo(:arguments => "--boardsize 9")
  end
  
  it "should default to redirecting STDERR to STDOUT" do
    Go::GTP::IO.should_receive(:popen) do |path, _|
      path.should match(/2>&1\z/)
    end
    Go::GTP.run_gnugo
  end
  
  it "should allow the redirections to be overriden" do
    Go::GTP::IO.should_receive(:popen) do |path, _|
      path.should match(%r{2>/dev/null\z})
    end
    Go::GTP.run_gnugo(:redirections => "2>/dev/null")
  end
end
