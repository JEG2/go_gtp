$LOAD_PATH << File.join(File.dirname(__FILE__), *%w[.. lib])
require "go/gtp"

abort "USAGE:  #{$PROGRAM_NAME} BOARD_SIZE_INT" unless ARGV.first =~ /\A\d+\z/

# this script is handy for measuring performance

start  = Time.now
colors = %w[black white].cycle
Go::GTP.run_gnugo do |go|
  go.boardsize(ARGV.first) or abort "Invalid board size"
  go.clear_board
  1.upto(19) do |row|
    ("A".."T").each do |column|
      next if column == "I"
      move = "#{column}#{row}"
      next if move == "T19" # illegal move
      go.play(colors.next, move) or abort "Invalid move #{move}"
    end
  end
  puts go.showboard
end
puts "Total time:  #{Time.now - start} seconds"