module Go
  class GTP
    class Board
      STONES = {"X" => "black", "O" => "white"}
      
      def initialize(board_string)
        @as_string = board_string
        @as_array  = nil
      end
      
      def [](*args)
        if args.size == 2 and args.all? { |n| n.is_a? Integer }
          x, y = args
          as_array[as_array.size - (y + 1)][x]
        elsif args.size == 1 and args.first =~ /\A([A-Z])(\d{1,2})\z/
          self[$1.getbyte(0) - "A".getbyte(0), $2.to_i - 1]
        else
          fail ArgumentError, "must index by coordinates or vertex"
        end
      end
      
      def captures(color)
        @as_string[ /#{Regexp.escape(color)}(?: \([XO])?\) has captured (\d+)/i,
                    1 ].to_i
      end
      
      def to_s
        @as_string
      end
      
      private
      
      def as_array
        @as_array ||=
          @as_string.scan(/^\s*(\d+)((?:.[.+XO])+).\1\b/)
                    .map { |_, row| row.chars
                                       .each_slice(2)
                                       .map { |_, stone| STONES[stone] } }
      end
    end
  end
end
