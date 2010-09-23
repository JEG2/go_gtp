$LOAD_PATH << File.join(File.dirname(__FILE__), *%w[.. lib])
require "go/gtp"

Go::GTP.run_gnugo do |go|
  go.loadsgf(File.join(File.dirname(__FILE__), "game.sgf"))
  puts go.showboard
end
