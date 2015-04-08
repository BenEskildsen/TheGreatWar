require_relative "./entity/entity_factory.rb"
require_relative "./entity/json_factory.rb"

class Game

    def manager
    	@@manager
    end

    def self.init_game(rows=30, cols=30, player_names=["Player 1", "Player 2"])
        @@manager = EntityManager.new(rows, cols)
        players, turn, pieces = EntityFactory.create_game_basic(@@manager, player_names)
        start_json = JsonFactory.game_start(@@manager, players, turn, pieces)
        return @@manager, start_json
    end

    def self.each_coord(req_id, em)
        (0..em.row).each { |row| 
            (0..em.col).each { |col| 
                yield row, col
            }
        }
    end

    def self.verify(req_id, em, entity)
        entity_requester = nil
        em.each_entity(UserIdComponent) { |e|
            if em[e][UserIdComponent][0].id == req_id
                entity_requester = e
                break
            end
        }
        entity_owner = em[entity][OwnedComponent][0].owner;
        return entity_requester == entity_owner 
    end

    def self.get_full_info(req_id, em, row, col)
    	return { "tile" => self.get_tile_info(req_id, em, row, col),
                 "unit" => self.get_unit_info(req_id, em, row, col) }
    end

    def self.get_tile_info(req_id, em, row, col)        
        return JsonFactory.square(em, em.board[row][col][0])
    end

    def self.get_unit_info(req_id, em, row, col)
        entity = em.board[row][col][1].first
        return JsonFactory.piece(em, entity)
    end

    def self.get_player_info(req_id, em, name=nil)
        em.each_entity(NameComponent) { |entity| 
            nameComp = em[entity][NameComponent].first
            return JsonFactory.player(em, entity) if name == nameComp.name
        }
        return {}
    end


    def self.get_all_full_info(req_id, em)
        all_info = []
        self.each_coord(req_id, em).each { |row, col|
            all_info << self.get_full_info(req_id, em, row, col)
        }
        return all_info
    end

    def self.get_all_tile_info(req_id, em)
        all_info = []
        self.each_coord(req_id, em).each { |row, col|
            all_info << self.get_tile_info(req_id, em, row, col)
        }
        return all_info
    end

    def self.get_all_unit_info(req_id, em)
        all_info = []
        self.each_coord(req_id, em).each { |row, col|
            all_info << self.get_unit_info(req_id, em, row, col)
        }
        return all_info
    end

    def self.get_all_player_info(req_id, em)
        all_info = []
        em.each_entity(NameComponent) { |entity| 
            nameComp = em[entity][NameComponent].first
            all_info << JsonFactory.player(em, entity)
        }
        return all_info
    end


    def self.get_unit_actions(req_id, em, entity)
        can_move = !MotionSystem.moveable_locations(em, entity).empty?
        can_melee = !MeleeSystem.attackable_locations(em, entity).empty?
        can_range = !RangeSystem.attackable_locations(em, entity).empty?

        return JsonFactory.actions(em, entity, can_move, can_melee, can_range)
    end

    def self.get_unit_moves(req_id, em, entity)
    	locations = MotionSystem.moveable_locations(em, entity)
    	return JsonFactory.moveable_locations(em, entity, locations)
    end

    def self.get_unit_melee_attacks(req_id, em, entity)
        attacks = MeleeSystem.attackable_locations(em, entity)
        return JsonFactory.melee_attacks(em, e, attacks) # UNIMPLEMENTED
    end

    def self.get_unit_range_attacks(req_id, em, entity)
        attacks = RangeSystem.attackable_locations(em, entity)
        return JsonFactory.range_attacks(em, e, attacks) # UNIMPLEMENTED
    end


    def self.move_unit(req_id, em, enitity, row, col)
        location = em.board[row][col][0]
        path = MotionSystem.make_move(em, entity, location)
        return JsonFactory.move(em, entity, path)
    end

    def self.melee_attack(req_id, em, entity, row, col)
        target = em.board[row][col][1].first
        result = MeleeSystem.update(em, entity, target)
        return JsonFactory.attack_result(result) # UNIMPLEMENTED
    end

    def self.ranged_attack(req_id, em, entity, row, col)
        target = em.board[row][col][1].first
        result = RangeSystem.update(em, entity, target)
        return JsonFactory.attack_result(result) # UNIMPLEMENTED
    end

    # End the turn for the current player.
    def self.end_turn(req_id, em)
        if em[TurnSystem.current_turn(em)][UserIdComponent][0].id != req_id
            return {}
        end

        TurnSystem.update(em)
        turn = em.get_entities_with_components(TurnComponent).first
        return JsonFactory.end_turn(em, turn)
    end

end

g = Game.new

#puts g.entity_manager6412322
