module Go
  class GTP
    class Board
      STONES = {"X" => "black", "O" => "white"}
      
      def initialize(board_string)
        @string = board_string
        @array  = nil
      end
      
      def [](*args)
        if args.size == 2 and args.all? { |n| n.is_a? Integer }
          x, y = args
          to_a[to_a.size - (y + 1)][x]
        elsif args.size == 1 and args.first =~ /\A([A-Z])(\d{1,2})\z/
          self[$1.getbyte(0) - "A".getbyte(0), $2.to_i - 1]
        else
          fail ArgumentError, "must index by coordinates or vertex"
        end
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
    end
  end
end
