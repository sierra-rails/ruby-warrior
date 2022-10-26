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
        puts "Attacking"
        warrior.attack!
      end
    end

    @prior_health = warrior.health
  end

  def should_rest?
    if taking_damage?
      false
    else
      next_space.empty? && warrior.health < HEALTH_BUFFER
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
