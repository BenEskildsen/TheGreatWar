require_relative '../models/ecs/Game'

class SocketController < WebsocketRails::BaseController
  def init_game
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
                                 player: "test"
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
                                 player: "not"
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
                   action: "killUnit",
                   arguments: [1]
                 }	
                ]
    }
 end
end
