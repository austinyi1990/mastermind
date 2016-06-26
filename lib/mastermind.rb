require_relative "game_board"
require_relative "human_player"
require_relative "ai"

CHOICES = ["r","g","y","b","m","c"]

class Game
	def initialize
		@game_board = GameBoard.new
		@player = HumanPlayer.new(self)
		@ai = AI.new(self)
		
		@code_breaker = @player
		@code_maker = @ai
		@current_turn = 1
		@number_of_turns = 10
		@code_to_break
	end
	attr_reader :current_turn
	attr_accessor :code_to_break, :game_board

	def play
		get_player_role
		get_number_of_turns
		@code_maker.make_code

		loop do
			@code_breaker.guess_code
			@current_row = @game_board.board[@current_turn]
			@current_row << get_feedback(@current_row, @code_to_break)
			@game_board.print_board
			
			if correct_guess?
			    puts "\n#{@code_breaker.class.name.split('::').last} wins"
			    puts "Answer: #{@code_to_break.join("|")}"
			    replay
			    return
			elsif game_over?
			    puts "\n#{@code_maker.class.name.split('::').last} wins"
			    puts "Answer: #{@code_to_break.join("|")}"
			    replay
			    return
			end
			@current_turn += 1
		end

	end

	def get_player_role
		puts "Do you want to be the Code Breaker or Code Maker? (maker/breaker)"
		answer = gets.chomp.downcase
		until (answer == "breaker" || answer == "maker")
			puts "Invalid input. Please try again."
			answer = gets.chomp.downcase
		end
		if answer == "maker"
			@code_breaker = @ai
			@code_maker = @player
		end
	end

	def get_number_of_turns
		puts "How many turns? (8/10/12)"
		answer = gets.chomp.to_i
		until (answer == 8 || answer == 10 || answer == 12)
			puts "Invalid input. Please try again."
			answer = gets.chomp.to_i
		end
		@number_of_turns = answer
	end

	def get_feedback(position, code)
	    feedback = Array.new

	    num_correct_positions = get_num_correct_positions(position, code)
	    num_correct_colors = get_num_correct_colors(position, code) - num_correct_positions
	    num_empty = 4 - (num_correct_positions + num_correct_colors)
	    
	    num_correct_positions.times do feedback << "!" end
	    num_correct_colors.times do feedback << "*" end
	    num_empty.times do feedback << "" end

	    feedback
	end
	
	private
	def get_num_correct_positions(position, code)
	    count = 0
	    position[0].each_with_index do |char, index|
	        count += 1 if char == code[index]
	    end
	    count
	end
	
	def get_num_correct_colors(position, code)
	    count = 0
	    temp_code = code.clone
	    position[0].each do |char|
	       if  temp_code.include?(char)
	           count += 1
	           temp_code.slice!(temp_code.index(char))
	       end
	    end
	    count
	end
	
	def correct_guess?
        return get_num_correct_positions(@current_row, @code_to_break) == 4
	end

	def game_over?
		return @current_turn == @number_of_turns
	end
	
	def replay
	    puts "Would you like to play again? (y/n)"
		answer = gets.chomp.downcase
		until (answer == "y" || answer == "n")
			puts "Invalid input. Please try again."
			answer = gets.chomp.downcase
		end
		if answer == "y"
			reset_game
			self.play
		else
			puts "Thanks for playing!"
		end
	end
	
	def reset_game
	    @current_turn = 1
        @game_board.reset_board
        @code_breaker = @player
		@code_maker = @ai
	end
end