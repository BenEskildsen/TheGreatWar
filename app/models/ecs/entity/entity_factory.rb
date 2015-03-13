#require "enumerable/standard_deviation"
#require "rubystats"

require_relative "./entity.rb"
require_relative "./entity_manager.rb"
Dir[File.dirname(__FILE__) + '/../component/*.rb'].each {|file| require_relative file }

=begin
	The EntityFactory is a heavy-lifter along with the EntityManager. It
	is responsible for creating standard entities. Certain entities such
	as squares on the board are rather forumlaic in how they are made.
	Rather than having to add the appropriate components manually each time,
	the EntityFactory handles this logic. The factory also provides methods
	to determine whether an entity is of a given type (like a Square or
	Player).
=end
class EntityFactory

private
	# The default creator of new entities. It creates a new entity adding
	# the desired components to it.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   components     = the list of components to add
	#
	# Returns
	#   the newly created Entity 
	def self.create_entity(entity_manager, components)
		# The first uses production entities, the second debugging ones.
		#entity = Entity.new
		entity = Entity.debug_entity
		components.each do |component|
			entity_manager.add_component(entity, component)
		end
		return entity
	end

public

	# This function creates a new flatland square for boards. Flatlands are
	# the standard squares that can both be traversed by troops and
	# occupied by them.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#
	# Returns
	#   the newly created Square Entity 
	def self.flatland_square(entity_manager)
		return self.create_entity(entity_manager,
					  [TerrainComponent.flatland,
					   OccupiableComponent.new])
	end

	# This function creates a new mountain square for boards. Mountains are
	# rugged squares that are unoccupiable and impassable. They primarly
	# serve as protective boarders.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#
	# Returns
	#   the newly created Square Entity	
	def self.mountain_square(entity_manager)
		return self.create_entity(entity_manager,
					  [TerrainComponent.mountain,
					   ImpassableComponent.new])
	end

	# This function creates a new hill square for boards. Hills are the
	# passable and occupiable version of mountians.
	#
	# TODO In future versions of the game, hills will provide some defense
	#      boosts.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#
	# Returns
	#   the newly created Square Entity	
	def self.hill_square(entity_manager)
		return self.create_entity(entity_manager,
					  [TerrainComponent.hill,
					   OccupiableComponent.new])
	end

	# This function creates a new trench square for boards. Trenches are
	# dug from the terrain by units and are both passable and occupiable.
	#
	# TODO In future versions of the game, hills will provide some defense
	#      boosts.
	# TODO Consider adding an immalleable component to determine if a square
	#      can be turned into a trench
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#
	# Returns
	#   the newly created Square Entity
	def self.trench_square(entity_manager)
		return self.create_entity(entity_manager,
					  [TerrainComponent.trench,
					   OccupiableComponent.new])
	end

	# This function creates a new river square for boards. Rivers are
	# protective barriers similar to mountains. Like mountains they can not
	# be occupied by troops. Unlike mountains, they can be traversed.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#
	# Returns
	#   the newly created Square Entity
	def self.river_square(entity_manager)
		return self.create_entity(entity_manager,
					  [TerrainComponent.river])
	end

	# This function populates the board in the most basic way possible. It
	# fills each row and column with a flatland square.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#
	# Postcondition
	#   the board is properly created
	def self.create_board_basic(entity_manager)
		entity_manager.board.each_with_index { |ele, row|
			ele.each_with_index { |_, col|
				square = self.flatland_square(entity_manager)
				entity_manager.add_component(square,
					PositionComponent.new(row, col))
				entity_manager.board[row][col] = square
			}
		}
	end

	# This function creates a new human player entity. These entities
	# represent the human players of the game.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   name           = the in game name of the player
	#
	# Returns
	#   the newly created Human Player Entity
	def self.human_player(entity_manager, name)
		return self.create_entity(entity_manager,
					  [NameComponent.new(name),
					   HumanComponent.new])
	end

	# This function creates a new AI player etity. These entities
	# represent the players that are controlled by artifical intelligence
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#
	# Returns
	#   the newly created AI Player Entity
	def self.ai_player(entity_manager)
		return self.create_entity(entity_manager,
					  [AIComponent.new])
	end

	# This function creates a new AI player etity. These entities
	# represent the players that are controlled by artifical intelligence
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   owner          = the player entity this piece belongs to
	#
	# Returns
	#   the newly created AI Player Entity
	def self.infantry(entity_manager, owner)
		return self.create_entity(entity_manager,
					  [PieceComponent.infantry,
					   HealthComponent.new(10),
					   MotionComponent.new(5),
					   MeleeAttackComponent.new(10),
					   RangeAttackComponent.new(10, 1, 4),
					   OwnedComponent.new(owner)])
	end

	# This function creates a new AI player etity. These entities
	# represent the players that are controlled by artifical intelligence
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   owner          = the player entity this piece belongs to
	#
	# Returns
	#   the newly created AI Player Entity
	def self.machine_gun(entity_manager, owner)
		return self.create_entity(entity_manager,
					  [PieceComponent.machine_gun,
					   HealthComponent.new(20),
					   MotionComponent.new(3),
					   MeleeAttackComponent.new(10),
					   RangeAttackComponent.new(10, 3, 7),
					   OwnedComponent.new(owner)])
	end

	# This function creates a new AI player etity. These entities
	# represent the players that are controlled by artifical intelligence
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   owner          = the player entity this piece belongs to
	#
	# Returns
	#   the newly created AI Player Entity
	def self.artillery(entity_manager, owner)
		return self.create_entity(entity_manager,
					  [PieceComponent.artillery,
					   HealthComponent.new(10),
					   MotionComponent.new(1),
					   MeleeAttackComponent.new(0),
					   RangeAttackComponent.new(20, 5, 15),
					   OwnedComponent.new(owner)])
	end

	# This function creates a new command bunker entity. These entities
	# represent the command base of a player. A player will lose if the
	# opposing army is able to capture the command bunker.
	#
	# Arguments
	#   entity_manager = the entity manager to add the new entity to
	#   owner          = the player entity this piece belongs to
	#
	# Returns
	#   the newly created Command Bunker Entity
	def self.command_bunker(entity_manager, owner)
		return self.create_entity(entity_manager,
					  [PieceComponent.command_bunker,
					   HealthComponent.new(30),
					   RangeAttackImmunityComponent.new,
					   OwnedComponent.new(owner)])
	end

=begin
	// TODO Talk with Vance and David about code so we can write tests for it
	
	def self.board1(entity_manager, clutter=0.25)	
		0.upto(n-1).each {|i|
			0.upto(n-1).each {|j|
				entity_manager.board[i][j] = self.tile_flatland(entity_manager)
			}
		}

		r = Random.new
		# We define probability 0 to be "no clutter", vs. n to be
		# "completely cluttered"
		n = max(entity_manager.rows, entity_manager.columns)
		gen = Rubystats::BinomialDistribution.new(n, clutter)
		gen.times {
			# Now we populate the board with random numbers
			randomi = r.rand(entity_manager.rows)
			randomj = r.rand(entity_manager.columns)

			random_Component = get_random()

			entity_manager.board[randomi][randomj].type = random_Component
		}

	end

	def get_random()
		case rand(100) + 1
		    when  1..50   then TerrainComponent.mountain
			when 50..100   then TerrainComponent.river
		end
	end
=end

end

