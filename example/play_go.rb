$LOAD_PATH << File.join(File.dirname(__FILE__), *%w[.. lib])
require "go/gtp"

class IllegalMoveError < RuntimeError; end

COLORS  = %w[black white]
PLAYERS = Hash[COLORS.zip(%w[computer player].sample(2))]
passes  = 0

begin
  Go::GTP.run_gnugo(arguments: ARGV.empty? ? nil : ARGV) do |go|
    COLORS.cycle do |color|
      puts go.showboard
      abort "Error:  failed to show board" unless go.success?
      move = nil
      case PLAYERS[color]
      when "player"
        begin
          print "Move for #{color}?  "
          move = $stdin.gets.to_s.strip
          unless move =~ /\S/ and go.is_legal?(color, move)
            raise IllegalMoveError, "Illegal move"
          end
          go.play?(color, move) or abort "Error:  move failed"
        rescue IllegalMoveError => error
          puts error.message
          retry
        end
      when "computer"
        move = go.genmove(color)
        abort "Error:  failed to generate move" unless go.success?
        puts "Move for #{color}:  #{move}"
      end
      puts
      passes = move =~ /\bpass\b/i ? passes + 1 : 0
      break if move =~ /\bresign\b/i or passes >= 2
    end
    puts "Final score:  #{go.final_score}"
  end
rescue Errno::EPIPE
  abort "Error:  bad arguments"
end
