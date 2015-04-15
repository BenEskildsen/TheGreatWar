module GamasHelper

	def game_pending?(game)
		game.pending
	end

	def game_done?(game)
		game.done
	end

	def assign_game_to_current_user(game)
		user = current_user
		user.game = game.id
		user.save!
	end

	def players_in_game(game)
		@players = User.where(:game => game.id)
		return @players
	end


	# TODO:
	# There is a bug when the host leaves the game while other people are in it
	def leave_game
		user = current_user
		game = Gama.find(user.game)
		user.game = 0
		user.save!

		game.update_attribute(:pending, true)
		game.update_attribute(:host, false)
	end
	
	def is_current_user_host?(game)
		user = current_user
		return user.host && (user.game == game.id)
	end

end
