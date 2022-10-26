class Player
  HEALTH_BUFFER = 20.freeze

  def play_turn(warrior)
    next_space = warrior.feel

    if warrior.health < HEALTH_BUFFER
      if next_space.empty?
        warrior.rest!
      else
        warrior.attack!
      end
    else
      if next_space.empty?
        warrior.walk!
      else
        warrior.attack!
      end
    end
  end
end
