require_relative "player"

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