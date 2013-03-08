require 'game'
require 'turn'


class Adventure
  def initialize(path)
    @game = Game.new(path)
    @turns = []
  end
  
  def do_command(command)
    turn = Turn.new(@game)
    actions = turn.get_command_actions(command)
    
    p actions
    
  end
  
  def increment_turn
    @turn += 1
  end
end