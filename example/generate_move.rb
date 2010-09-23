$LOAD_PATH << File.join(File.dirname(__FILE__), *%w[.. lib])
require "go/gtp"

GAME_FILE = File.join(File.dirname(__FILE__), "game.sgf")

Go::GTP.run_gnugo do |go|
  color = go.loadsgf(GAME_FILE)
  puts go.genmove(color)
  go.printsgf(GAME_FILE)
end
