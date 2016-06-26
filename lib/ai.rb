require_relative "player"

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