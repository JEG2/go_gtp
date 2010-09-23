$LOAD_PATH << File.join(File.dirname(__FILE__), *%w[.. lib])
require "go/gtp"

abort "USAGE:  #{$PROGRAM_NAME} MOVE" unless ARGV.first =~ /\A[A-Z]\d+\z/i

GAME_FILE = File.join(File.dirname(__FILE__), "game.sgf")

Go::GTP.run_gnugo do |go|
  color = go.loadsgf(GAME_FILE)
  go.play(color, ARGV.first) or abort "Invalid move for #{color}"
  go.printsgf(GAME_FILE)
end
