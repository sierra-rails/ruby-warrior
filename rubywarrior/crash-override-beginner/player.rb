class Player
  HEALTH_BUFFER = 20.freeze
  attr_accessor :warrior

  @prior_health = nil
  @warrior = nil

  def play_turn(warrior)
    @warrior = warrior

    if should_rest?
      puts "Resting"
      warrior.rest!
    else
      if should_walk?
        puts "Walking"
        warrior.walk!
      else
        if next_space.empty?
          puts "Walking"
          warrior.walk!
        elsif next_space.captive?
          puts "Rescuing!"
          warrior.rescue!
        else
          puts "Attacking"
          warrior.attack!
        end
      end
    end

    @prior_health = warrior.health
  end

  def should_rest?
    if taking_damage?
      false # never rest when taking damage
    else
      if next_space.empty?
        if warrior.health < HEALTH_BUFFER
          true # empty space ahead, low health, recharge!
        else
          false # plenty of health, don't rest
        end
      else
        if next_space.captive?
          false # dont rest when there is a captive to rescue
        else
          false # next space is an enemy, don't rest
        end
      end
    end
  end

  def should_walk?
    next_space.empty?
  end

  def taking_damage?
    if @prior_health.nil?
      false # haven't started yet
    else
      warrior.health < @prior_health # current health is less than prior health
    end
  end

  def next_space
    warrior.feel
  end
end
