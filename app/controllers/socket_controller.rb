require_relative '../models/ecs/Game'

class SocketController < WebsocketRails::BaseController
  def init_game
    manager, start_json = Game.init_game
    send_message :rpc, start_json

=begin    
     {
      sequence: [
    # entity_manager, start_json = Game.init_game
    send_message :rpc, {
      sequence: [ 
                 {
                   action: "revealUnit",
                   arguments: [
                               {
                                 id: 1,
                                 x: 3,
                                 y: 3,
                                 type: "infantry",
                                 player: "not"
                               }
                              ]
                 },
                 {
                   action: "revealUnit",
                   arguments: [
                               {
                                 id: 2,
                                 x: 5,
                                 y: 5,
                                 type: "infantry",
                                 player: "test"
                               }
                              ]
                 },
            		 {
            		   action: "revealFog",
            		   arguments: [[
              			{x: 4, y: 4},
              			{x: 5, y: 4}
              			]]
            		 },
            		 {
            		   action: "highlightSquares",
            		   arguments: [[
            			{x: 6, y: 6},
            			{x: 7, y: 6}
            			], 'blue']
            		 },
                 {
                    action: "showUnitActions",
                    arguments: [
                      {
                        id: 2
                      } 
                    ]
                 },
            		 {
                   action: "killUnit",
                   arguments: [1]
                 }	
                ]
    }
<<<<<<< HEAD
=end
 end
end
