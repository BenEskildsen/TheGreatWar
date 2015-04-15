#Dir[File.dirname(__FILE__) + '/../component/*.rb'].each {|file| require_relative file }
#Dir[File.dirname(__FILE__) + '/../system/*.rb'].each {|file| require_relative file }
#Dir[File.dirname(__FILE__) + '/./*.rb'].each {|file| require_relative file }
=begin
	The JsonFactory is the one stop shop for all things json. Have some actions
	or entities to send to the frontend? JsonFactory has you covered. It will
	handle both sending newly created entities as well as update actions like
	movement and attack to the frontend.
	
	Note: It is the responsibility of the caller to ensure that the entities
	are well-formed.
=end
class JsonFactory

	# Converts a square entity into a hash object.
	#
	# Arguments
	#   entity_manager = the manager in which the entity is kept.
	#   entity         = the square entity to be jsoned
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.square(entity_manager, entity)
		terrain_comp = entity_manager.get_components(entity, TerrainComponent).first
		return {"id"      => entity,
		        "terrain" => terrain_comp.type.to_s}
	end


	# This converts a square entity into a json-ready hash. In particular,
	# this will be used for requests such as returning the path of a movement
	# which don't need to tell all the information about a square but
	# simply a way to identify it. Both the id and its x and y coordinates
	# are provided.
	#
	# Argumetns
	#   entity_manager = the manager in which the entity is kept.
	#   entity         = the square entity to be jsoned
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.square_path(entity_manager, entity)
		pos_comp = entity_manager.get_components(entity, PositionComponent).first
		return {"y"  => pos_comp.row,
		        "x"  => pos_comp.col}
	end

	# Converts a player entity into a hash object.
	#
	# Argumetns
	#   entity_manager = the manager in which the entity is kept.
	#   entity         = the player entity to be jsoned
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.player(entity_manager, entity)
		name_comp = entity_manager.get_components(entity, NameComponent).first
		user_id_comp = entity_manager.get_components(entity, UserIdComponent).first

		ai_comp = entity_manager.get_components(entity, AIComponent).first
		player_type = "CPU" if ai_comp	

		human_comp = entity_manager.get_components(entity, HumanComponent).first
		player_type = "Human" if human_comp

		return {"id"      => entity,
		        "name"    => name_comp.name,
		        "type"    => player_type, 
		        "userId"  => user_id_comp.id }
	end

	# Converts a turn entity into a hash object.
	#
	# Argumetns
	#   entity_manager = the manager in which the entity is kept.
	#   entity         = the turn entity to be jsoned
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.turn(entity_manager, entity)
		turn_comp = entity_manager.get_components(entity, TurnComponent).first
		return {"playerid" => turn_comp.current_turn}
	end

	# This method is responsible for converting a piece entity into a json-
	# ready hash. In short, a piece is any element that a player can control
	# whether it be an artillery or command_bunker.
	#
	# This method handles all possible pieces (and hence makes it easier to
	# add and delete components from a given piece)
	#
	# Argumetns
	#   entity_manager = the manager in which the entity is kept.
	#   entity         = the piece entity to be jsoned
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.piece(entity_manager, entity)
		piece_hash          = Hash.new
		piece_hash["id"]    = entity
		
		piece_comp = entity_manager.get_components(entity, PieceComponent).first
		piece_hash["type"] = piece_comp.type.to_s

		owned_comp = entity_manager.get_components(entity, OwnedComponent).first
		piece_hash["player"] = owned_comp.owner

		pos_comp = entity_manager.get_components(entity, PositionComponent).first
		piece_hash["y"] = pos_comp.row
		piece_hash["x"] = pos_comp.col


		piece_hash["stats"] = Hash.new

		health_comp = entity_manager.get_components(entity, HealthComponent).first
		piece_hash["stats"]["health"] = {"current" => health_comp.cur_health,
		                                 "max"     => health_comp.max_health}

		energy_comp = entity_manager.get_components(entity, EnergyComponent).first
		if energy_comp
		   piece_hash["stats"]["energy"] = {"current" => energy_comp.cur_energy,
		                                    "max"     => energy_comp.max_energy}
		end

		motion_comp = entity_manager.get_components(entity, MotionComponent).first
		if motion_comp
		   piece_hash["stats"]["motion"] = {"cost" => motion_comp.energy_cost}
		end

		melee_comp = entity_manager.get_components(entity, MeleeAttackComponent).first
		if melee_comp
		   piece_hash["stats"]["melee"] = {"attack" => melee_comp.attack,
		                                   "cost"   => melee_comp.energy_cost}
		end

		range_comp = entity_manager.get_components(entity, RangeAttackComponent).first
		piece_hash["stats"]["range"] = Hash.new
		if range_comp
		   piece_hash["stats"]["range"] = {"attack" => range_comp.attack,
		                                   "min"    => range_comp.min_range,
		                                   "max"    => range_comp.max_range,
		                                   "splash" => range_comp.splash.size,
		                                   "cost"   => range_comp.energy_cost}
		end

		range_immune_comp = entity_manager.get_components(entity, RangeAttackImmunityComponent).first
		piece_hash["stats"]["range"]["immune"] = range_immune_comp != nil
		return piece_hash
	end

	# Converts the board into a json-ready hash. This method is particularly
	# useful for initialization of the frontend and sending the frontend the
	# data for the board.
	#
	# Argumetns
	#   entity_manager = the manager that contains the board
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.board(entity_manager)
		board_array = []
		(0...entity_manager.row).each { |row|
			(0...entity_manager.col).each { |col|
				board_array.push self.square(entity_manager,
					entity_manager.board[row][col][0])				
			}
		}
		return {"width"    => entity_manager.row,
		        "height"   => entity_manager.col,
		        "squares"  => board_array}
	end


	# This method is responsible for sending all relevant game
	# start data to the frontend. Once the frontend receives this, it will
	# be able to completely initialize the browser for a new game.
	#
	# Arguments
	#   entity_manager = the manager of the entities
	#   players        = an array of player entities
	#   turn           = the turn entity denoting whose turn it is.
	#   pieces         = an array of all the pieces in the game
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.game_start(entity_manager, players, turn, pieces)
		player_array = []
		players.each { |player|
			player_array.push self.player(entity_manager, player)
		}
	
		turn_hash = self.turn(entity_manager, turn)
		board     = self.board(entity_manager)
		
		piece_array = []
		pieces.each { |piece|
			piece_array.push self.piece(entity_manager, piece)
		}

          return {
            "action" => "initGame",
            "arguments" => [board, piece_array, turn_hash, player_array]
          }
	end


	# This returns the results of a move command to the frontend. It specifies
	# the entity that moved along with the path it moved upon.
	#
	# Argumetns
	#   entity_manager = the manager that contains the entities
	#   moving_entity  = the entity that moved.
	#   path           = an array of square entities denoting the path of motion.
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.move(entity_manager, moving_entity, path)
		# path_array = []
		# path.each { |square|
		# 	path_array.push self.square_path(entity_manager, square)
		# }
		# return {"action" => "moveUnit",
		#         "arguments" =>[moving_entity, path_array]
		#        }
      
        actions = []
        path[1, path.size].each { |square|
            coordinates = self.square_path(entity_manager, square)
            actions.push({"action" => "moveUnit",
                          "arguments" => [moving_entity, coordinates] })
        }
        return actions
	end

	# This function is used to return a response to a moveable_locations
	# request. In particular, it contains the list of locations that the
	# specified entity can move to.
	#
	# Argumetns
	#   entity_manager = the manager that contains the entities
	#   moving_entity  = the entity that wishes to move.
	#   locations      = an array of square entities denoting the possible
	#                  squares that can be moved to
	#
	# Returns
	#   A hash that is ready to be jsoned	
	def self.moveable_locations(entity_manager,  moving_entity, locations)
		locations_array = []
		locations.each { |square|
			locations_array.push self.square_path(entity_manager, square)
		}
		return {"action"  => "highlightSquares",
		        "arguments" => ["move", locations_array]
		       }
	end

	# Converts a turn entity into a hash object.
	#
	# Argumetns
	#   entity_manager = the manager in which the entity is kept.
	#   entity         = the turn entity to be jsoned
	#
	# Returns
	#   A hash that is ready to be jsoned
	def self.end_turn(entity_manager, entity)
		return {"action"    => "setTurn",
		        "arguments" => [self.turn(entity_manager, entity)]}
	end


	def self.actions(entity_manager, entity, can_move, can_melee, can_range)
	
		actions = []
		
		if can_move
		 actions.push({"name" => "motion",
		               "cost" => entity_manager[entity][MotionComponent].first.energy_cost})
		end
	
		if can_melee
		 actions.push({"name" => "melee",
		               "cost" => entity_manager[entity][MeleeAttackComponent].first.energy_cost})
		end

		if can_range
		 actions.push({"name" => "range",
		               "cost" => entity_manager[entity][RangeAttackComponent].first.energy_cost})
		end

	
		return {"action"    => "showUnitActions",
		        "arguments" => actions}
	end

	# Actions to handle:
	#   Attack
	#   Attackable locations
	#   Turn end
	#   Player finished
	#   Game over
end

#{ response: "board"
#  locations: [{"terrain": "flatland"}, {"terrain": "river"}]
#}

#{ response: "infantry"
#  locations: [{type = "infantry", x => 0, y => 1}]
#}

#{ method: "moveable_locations"
#  args: [entity_wishing_to_move]
#}
#{ response: "moveable_locations"
#  locations: [[0,1], [0,2], [0,3] ...]
#}
#{ method: "move_piece"
#  args: [entity_to_move, x, y]
#}
#{ response: "move_piece"
#  path: [[0,1], [0,2], [0,3] ...]
#}
