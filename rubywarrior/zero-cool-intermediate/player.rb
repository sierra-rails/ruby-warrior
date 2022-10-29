require 'debug'

class Player
  attr_reader :warrior

  def play_turn(warrior)
    @warrior = warrior

    warrior.walk!(stair_direction)
  end

  def stair_direction
    warrior.direction_of_stairs
  end
end
