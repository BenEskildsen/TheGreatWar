require_relative "./component.rb"

=begin
	The TurnComponent is responsible for keeping track of turn information
	for the game. It contains a list of players and keeps track of which
	player's turn it currently is. It also keeps track of entities the
	player has moved, has made attacked, or has made perform a special
	action (such as digging trenches). This ensures that a player can
	not have pieces	act more times than they should be able to.
=end
class TurnComponent < Component

	# Initializes a new TurnComponent object
	#
	# Arguments
	#   player_entities = an array of player entities
	#
	# Postcondtion
	#   The TurnComponent object is properly initialized
	def initialize(player_entities)
		@turn     = 0
		@players  = player_entities
	end

	# Returns the player entity whose turn it currently is
	def current_turn()
		@players[@turn]
	end

	# Ends the turn for the current player and moves to the next player's
	# turn.
	#
	# Postcondtion
	#   The old player's turn is ended and the new player now has a turn.
	#   The moved, attacked, and special hashes are reset for the new player
	def next_turn()
		@turn = (@turn + 1) % @players.size
		self.current_turn
	end

  	# Returns a string representation of the component 
	def to_s
		return "Turn => #{self.current_turn}, Players => #{@players}, "
	end
end

