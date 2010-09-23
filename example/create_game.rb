$LOAD_PATH << File.join(File.dirname(__FILE__), *%w[.. lib])
require "go/gtp"

abort "USAGE:  #{$PROGRAM_NAME} BOARD_SIZE_INT" unless ARGV.first =~ /\A\d+\z/

Go::GTP.run_gnugo do |go|
  go.boardsize(ARGV.first) or abort "Invalid board size"
  go.clear_board
  go.printsgf(File.join(File.dirname(__FILE__), "game.sgf"))
end
