require "go/gtp/board"

module Go
  class GTP
    VERSION = "0.0.4"
    
    def self.run_gnugo(options = { }, &commands)
      directory    = options.fetch(:directory,    nil)
      command      = options.fetch(:command,      "gnugo --mode gtp")
      arguments    = options.fetch(:arguments,    nil)
      redirections = options.fetch(:redirections, "2>&1")
      path         = [ File.join(*[directory, command].compact),
                       arguments,
                       redirections ].compact.join(" ")

      new(IO.popen(path, "r+"), &commands)
    end
    
    def initialize(io)
      @io         = io
      @id         = 0
      @last_error = nil
      
      if block_given?
        begin
          yield self
        ensure
          quit
        end
      end
    end
    
    attr_reader :last_error
    
    def success?
      @last_error.nil?
    end
    
    def quit
      send_command(:quit)
      @io.close
      success?
    end
    alias_method :quit?, :quit
    
    def protocol_version
      send_command(:protocol_version)
    end
    
    def name
      send_command(:name)
    end
    
    def version
      send_command(:version)
    end
    
    def boardsize(boardsize)
      send_command(:boardsize, boardsize)
      success?
    end
    alias_method :boardsize?, :boardsize
    
    def query_boardsize
      send_command(:query_boardsize)
    end
    
    def clear_board
      send_command(:clear_board)
      success?
    end
    alias_method :clear_board?, :clear_board
    
    def orientation(orientation)
      send_command(:orientation, orientation)
      success?
    end
    alias_method :orientation?, :orientation
    
    def query_orientation
      send_command(:query_orientation)
    end
    
    def komi(komi)
      send_command(:komi, komi)
      success?
    end
    alias_method :komi?, :komi
    
    def get_komi
      send_command(:get_komi)
    end
    
    def play(color, vertex)
      send_command(:play, color, vertex)
      success?
    end
    alias_method :play?, :play
    
    def replay(vertices, starting_color = "black")
      colors = %w[black white].cycle
      colors.next unless starting_color == "black"
      vertices.each do |vertex|
        play(colors.next, vertex)
        return success? unless success?
      end
      success?
    end
    alias_method :replay?, :replay
    
    def fixed_handicap(number_of_stones)
      extract_vertices(send_command(:fixed_handicap, number_of_stones))
    end
    
    def place_free_handicap(number_of_stones)
      extract_vertices(send_command(:place_free_handicap, number_of_stones))
    end
    
    def set_free_handicap(*vertices)
      send_command(:set_free_handicap, *vertices)
      success?
    end
    alias_method :set_free_handicap?, :set_free_handicap
    
    def get_handicap
      send_command(:get_handicap)
    end
    
    def loadsgf(path, move_number_or_vertex = nil)
      send_command(:loadsgf, *[path, move_number_or_vertex].compact)
    end
    
    def color(vertex)
      extract_color(send_command(:color, vertex))
    end
    
    def list_stones(color)
      extract_vertices(send_command(:list_stones, color))
    end
    
    def countlib(vertex)
      extract_integer(send_command(:countlib, vertex))
    end
    
    def findlib(vertex)
      extract_vertices(send_command(:findlib, vertex))
    end
    
    def accuratelib(color, vertex)
      extract_vertices(send_command(:accuratelib, color, vertex))
    end
    
    def is_legal(color, vertex)
      extract_boolean(send_command(:is_legal, color, vertex))
    end
    alias_method :is_legal?, :is_legal
    
    def all_legal(color)
      extract_vertices(send_command(:all_legal, color))
    end
    
    def captures(color)
      extract_integer(send_command(:captures, color))
    end
    
    def last_move
      extract_move(send_command(:last_move))
    end
    
    def move_history
      extract_moves(send_command(:move_history))
    end
    
    def over?
      last_two_moves = move_history.first(2)
      Array(last_two_moves.first).last.to_s.upcase         == "RESIGN" or
      last_two_moves.map { |m| Array(m).last.to_s.upcase } == %w[PASS PASS]
    end
    
    def invariant_hash
      send_command(:invariant_hash)
    end
    
    def invariant_hash_for_moves(color)
      extract_moves(send_command(:invariant_hash_for_moves, color))
    end
    
    def trymove(color, vertex)
      send_command(:trymove, color, vertex)
      success?
    end
    alias_method :trymove?, :trymove
    
    def tryko(color, vertex)
      send_command(:tryko, color, vertex)
      success?
    end
    alias_method :tryko?, :tryko
    
    def popgo
      send_command(:popgo)
      success?
    end
    alias_method :popgo?, :popgo
    
    def clear_cache
      send_command(:clear_cache)
      success?
    end
    alias_method :clear_cache?, :clear_cache
    
    # ...
    
    def increase_depths
      send_command(:increase_depths)
      success?
    end
    alias_method :increase_depths?, :increase_depths

    def decrease_depths
      send_command(:decrease_depths)
      success?
    end
    alias_method :decrease_depths?, :decrease_depths
    
    # ...
    
    def unconditional_status(vertex)
      send_command(:unconditional_status, vertex)
    end
    
    # ...
    
    def genmove(color)
      send_command(:genmove, color)
    end
    
    def reg_genmove(color)
      send_command(:reg_genmove, color)
    end
    
    def gg_genmove(color, random_seed = nil)
      send_command(:gg_genmove, *[color, random_seed].compact)
    end
    
    def restricted_genmove(color, *vertices)
      send_command(:restricted_genmove, color, *vertices)
    end
    
    def kgs_genmove_cleanup(color)
      send_command(:kgs_genmove_cleanup, color)
    end
    
    def level(level)
      send_command(:level, level)
      success?
    end
    alias_method :level?, :level
    
    def undo
      send_command(:undo)
      success?
    end
    alias_method :undo?, :undo
    
    def gg_undo(moves = nil)
      send_command(:gg_undo, *[moves].compact)
      success?
    end
    alias_method :gg_undo?, :gg_undo
    
    def time_settings(main_time, byo_yomi_time, byo_yomi_stones)
      send_command(:time_settings, main_time, byo_yomi_time, byo_yomi_stones)
      success?
    end
    alias_method :time_settings?, :time_settings
    
    def time_left(color, time, stones)
      send_command(:time_left, color, time, stones)
      success?
    end
    alias_method :time_left?, :time_left
    
    def final_score(random_seed = nil)
      send_command(:final_score, *[random_seed].compact)
    end
    
    def final_status(vertex, random_seed = nil)
      send_command(:final_status, *[vertex, random_seed].compact)
    end
    
    def final_status_list(status, random_seed = nil)
      extract_vertices( send_command( :final_status_list,
                                      *[status, random_seed].compact ) )
    end
    
    def estimate_score
      send_command(:estimate_score)
    end
    
    def experimental_score(color)
      send_command(:experimental_score, color)
    end
    
    def reset_owl_node_counter
      send_command(:reset_owl_node_counter)
      success?
    end
    alias_method :reset_owl_node_counter?, :reset_owl_node_counter
    
    def get_owl_node_counter
      send_command(:reset_owl_node_counter)
    end
    
    def reset_reading_node_counter
      send_command(:reset_reading_node_counter)
      success?
    end
    alias_method :reset_reading_node_counter?, :reset_reading_node_counter
    
    def get_reading_node_counter
      send_command(:reset_reading_node_counter)
    end
    
    def reset_trymove_node_counter
      send_command(:reset_trymove_node_counter)
      success?
    end
    alias_method :reset_trymove_node_counter?, :reset_trymove_node_counter
    
    def get_trymove_node_counter
      send_command(:reset_trymove_node_counter)
    end
    
    def reset_connection_node_counter
      send_command(:reset_connection_node_counter)
      success?
    end
    alias_method :reset_connection_node_counter?, :reset_connection_node_counter
    
    def get_connection_node_counter
      send_command(:reset_connection_node_counter)
    end
    
    # ...
    
    def cputime
      send_command(:cputime)
    end
    
    def showboard
      Board.new(send_command(:showboard))
    end
    
    # ...
    
    def printsgf(path = nil)
      if path
        send_command(:printsgf, path)
        success?
      else
        send_command(:printsgf)
      end
    end
    alias_method :printsgf?, :printsgf
    
    def tune_move_ordering(*move_ordering_parameters)
      send_command(:tune_move_ordering, *move_ordering_parameters)
    end
    
    def echo(string)
      send_command(:echo, string)
    end
    
    def echo_err(string)
      send_command(:echo_err, string)
    end
    
    def help
      extract_lines(send_command(:help))
    end
    
    def known_command(command)
      extract_boolean(send_command(:known_command, command))
    end
    alias_method :known_command?, :known_command
    
    def report_uncertainty(on_or_off)
      send_command(:report_uncertainty, on_or_off)
    end
    alias_method :report_uncertainty?, :report_uncertainty
    
    def get_random_seed
      send_command(:get_random_seed)
    end
    
    def set_random_seed(random_seed)
      send_command(:set_random_seed, random_seed)
      success?
    end
    alias_method :set_random_seed?, :set_random_seed
    
    def advance_random_seed(games)
      send_command(:advance_random_seed, games)
      success?
    end
    alias_method :advance_random_seed?, :advance_random_seed
    
    # ...
    
    def set_search_diamond(position)
      send_command(:set_search_diamond, position)
      success?
    end
    alias_method :set_search_diamond?, :set_search_diamond
    
    def reset_search_mask
      send_command(:reset_search_mask)
      success?
    end
    alias_method :reset_search_mask?, :reset_search_mask
    
    def limit_search(value)
      send_command(:limit_search, value)
      success?
    end
    alias_method :limit_search?, :limit_search
    
    def set_search_limit(position)
      send_command(:set_search_limit, position)
      success?
    end
    alias_method :set_search_limit?, :set_search_limit
    
    def draw_search_area
      send_command(:draw_search_area)
    end
    
    private
    
    def next_id
      @id += 1
    end
    
    def send_command(command, *arguments)
      @io.puts [next_id, command, *arguments].join(" ")
      result = @io.take_while { |line| line != "\n" }.join
      if result.sub!(/^=#{@id} */, "")
        @last_error = nil
      elsif result.sub!(/^\?#{@id} *(\S.*\S?).*/, "")
        @last_error = $1
      else
        raise "Unexpected response format"
      end
      result.sub(/\A(?: *\n)+/, "").sub(/(?:\n *)+\z/, "")
    end
    
    def extract_vertices(response)
      success? ? response.scan(/[A-Z]\d+/) : [ ]
    end
    
    def extract_color(response)
      !success? || response == "empty" ? nil : response
    end
    
    def extract_move(response)
      success? ? response.split : nil
    end
    
    def extract_moves(response)
      success? ? response.lines.map { |line| line.strip.split } : nil
    end
    
    def extract_boolean(response)
      success? ? response == "1" || response == "true" : nil
    end
    
    def extract_integer(response)
      success? ? response.to_i : nil
    end
    
    def extract_lines(response)
      success? ? response.lines.map { |line| line.strip } : nil
    end
  end
end
