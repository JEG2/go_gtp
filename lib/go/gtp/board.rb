require "go/gtp/point"

module Go
  class GTP
    class Board
      STONES = {"X" => "black", "O" => "white"}
      
      def initialize(board_string)
        @string = board_string
        @array  = nil
      end
      
      def [](*args)
        point = if args.size == 1 and args.first.is_a? Point
                  args.first
                elsif args.size == 1 and
                      args.first =~ /\A([A-HJ-T])(\d{1,2})\z/i
                  Point.new(*args, board_size: size)
                else
                  Point.new(*args)
                end
        to_a[point.y][point.x]
      end
      
      def captures(color)
        @string[/#{Regexp.escape(color)}(?: \([XO])?\) has captured (\d+)/i, 1]
        .to_i
      end
      
      def to_s
        @string
      end
      
      def to_a
        @array ||= @string.scan(/^\s*(\d+)((?:.[.+XO])+).\1\b/)
                          .map { |_, row| row.chars
                                             .each_slice(2)
                                             .map { |_, stone| STONES[stone] } }
      end
      
      def size
        to_a.size
      end
    end
  end
end
