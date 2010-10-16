module Go
  class GTP
    # 
    # This utility class manages points on a Go board using any one of three
    # formats:
    # 
    # * X and Y Array indices counting from the upper left hand corner
    # * SGF letter pairs ("ac") counting from the upper left hand corner
    # * GNU Go letter and number pairs ("A13") counting from the lower left hand
    #   corner
    # 
    # There are two gotchas to stay aware of with these systems.  First, the GNU
    # Go format skips over I in columns, but the SGF format does not.  Second,
    # the GNU Go format relies on knowing the board size.  A 19x19 size is
    # assumed, but you can override this when creating from or converting to
    # this format.
    # 
    # Point instances can be initialized from any format and converted to any
    # format.
    # 
    class Point
      BIG_A    = "A".getbyte(0)
      LITTLE_A = "a".getbyte(0)
      
      def initialize(*args)
        if args.size == 2 and args.all? { |n| n.is_a? Integer }
          @x, @y = args
        elsif (args.size == 1 or (args.size == 2 and args.last.is_a?(Hash))) and
              args.first =~ /\A([A-HJ-T])(\d{1,2})\z/i
          options = args.last.is_a?(Hash) ? args.pop : { }
          letter  = $1.upcase
          @x      = letter.getbyte(0) - BIG_A - (letter > "I" ? 1 : 0)
          @y      = options.fetch(:board_size, 19) - $2.to_i
        elsif args.size == 1 and args.first =~ /\A([a-s])([a-s])\z/i
          @x, @y = $~.captures.map { |l| l.downcase.getbyte(0) - LITTLE_A }
        else
          fail ArgumentError, "unrecognized point format"
        end
      end
      
      attr_reader :x, :y
      
      def to_indexes
        [@x, @y]
      end
      alias_method :to_indices, :to_indexes
      
      def to_sgf
        [@x, @y].map { |n| (LITTLE_A + n).chr }.join
      end
      
      def to_gnugo(board_size = 19)
        "#{(BIG_A + @x + (@x >= 8 ? 1 : 0)).chr}#{board_size - @y}"
      end
      alias_method :to_s, :to_gnugo
    end
  end
end
