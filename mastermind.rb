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

class Player
	def initialize(game)
		@game = game
	end
end

class HumanPlayer < Player
    def guess_code
		puts "\nInput your guess. (r)ed, (g)reen, (y)ellow, (b)lue, (m)agenta, and (c)yan"
		answer = gets.chomp.downcase

		until answer.length == 4
			puts "Invalid input. Please try again."
			answer = gets.chomp.downcase
		end
		
		@game.game_board.update_board(@game.current_turn, answer)
	end

	def make_code
		puts "What's the code? Select 4 combinations of the following: (r)ed, (g)reen, (y)ellow, (b)lue, (m)agenta, and (c)yan"
		answer = gets.chomp.downcase
		
		until answer.length == 4
			puts "Invalid input. Please try again."
			answer = gets.chomp.downcase
		end
	    
		@game.code_to_break = answer.split("")
	end
end

class AI < Player
    def guess_code
        if @game.current_turn == 1
            create_set_of_all
            initial_guess = "rrbb"
            @game.game_board.update_board(@game.current_turn, initial_guess)
        else
            puts "\nAI is thinking.."
            sleep 1.5
            calculated_guess = calculate_next_choice.join("")
            @game.game_board.update_board(@game.current_turn, calculated_guess)
        end
    end
    
    def make_code
        @game.code_to_break = CHOICES.sample(4)
    end
    
    #Basic implementation of Knuth's algorithm
    def calculate_next_choice
        previous_turn = @game.current_turn - 1
        previous_row = @game.game_board.board[previous_turn]
        previous_feedback = previous_row[1]
        #If the number of ! and * is different from the user feedback, discard that possibility since it cannot possibly be the answer.
        @all_choices.delete_if {|possible_choice| @game.get_feedback(previous_row, possible_choice) != previous_feedback}
        return @all_choices[0]
    end
    
    def create_set_of_all
        @all_choices = Array.new
	    (0..5).each do |index1|
		    (0..5).each do |index2|
		        (0..5).each do |index3|
		          	(0..5).each do |index4|
		            @all_choices << [CHOICES[index1],CHOICES[index2],CHOICES[index3],CHOICES[index4]]
		          	end
		        end
		    end
	    end
    end
end

game = Game.new.play