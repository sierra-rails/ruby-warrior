require 'debug'

class Player
  HEALTH_BUFFER = 20.freeze
  ARCHER_BUFFER = 10.freeze
  attr_accessor :warrior

  @prior_health = nil
  @warrior = nil
  @wall_reached = false

  def play_turn(warrior)
    @warrior = warrior
    puts "Warrior Health: #{ warrior.health }"
    # debugger

    if taking_damage?
      # i'm taking damage, figure out who I'm taking damage from
      if enemy_in_next_space?
        warrior.attack!(:forward)
      elsif enemy_in_previous_space?
        warrior.attack(:previous)
      else
        # it's an archer
        if warrior.health > ARCHER_BUFFER # can I survive?
          warrior.walk!
        else
          # if not, find shelter to rest
          warrior.walk!(:backward)
        end
      end
    else
      if unhealthy?
        warrior.rest!
      else
        if previous_space.wall?
          @wall_reached = true
          warrior.walk!(:forward)
        else
          if !@wall_reached
            if previous_space.empty?
              warrior.walk!(:backward)
            elsif previous_space.captive?
              warrior.rescue!(:backward)
            elsif previous_space.enemy?
              warrior.attack!(:backward)
            end
          else
            if next_space.empty?
              warrior.walk!(:forward)
            elsif next_space.captive?
              warrior.rescue!(:forward)
            elsif next_space.enemy?
              warrior.attack!
            else
              warrior.walk(:foward)
            end
          end
        end
      end
    end

    @prior_health = warrior.health
  end

  def unhealthy?
    warrior.health < HEALTH_BUFFER
  end

  def health_diff
    @prior_health - warrior.health
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
  
  def previous_space
    warrior.feel(:backward)
  end

  def enemy_in_next_space?
    detect_enemy(direction: :forward)
  end

  def enemy_in_previous_space?
    detect_enemy(direction: :backward)
  end

  def detect_enemy(direction:)
    if warrior.feel(direction).empty?
      false
    else
      if warrior.feel(direction).captive?
        false
      else
        true
      end
    end
  end
end
