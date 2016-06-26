class GameBoard
	def initialize
		@board = Hash.new{|hash,key| hash[key] = [] } 
	end
	attr_accessor :board

	def print_board
	    @board.each do |key, array|
	        code = array[0].join("|")
	        feedback = array[1].join("")
	        puts "#{key}: #{code}     #{feedback}"
	    end
	end
	
	def update_board(current_turn, row)
        @board[current_turn] << row.split("")
	end
	
	def reset_board
	    @board = Hash.new{|hash,key| hash[key] = [] } 
	end
end