require 'debug'

class Player
  HEALTH_BUFFER = 20.freeze
  ENEMY_BUFFER = 10.freeze
  DIRECTIONS = [:forward, :right, :backward, :left].freeze # clockwise
  attr_accessor :warrior

  @prior_health = nil
  @warrior = nil


  def play_turn(warrior)
    @warrior = warrior

    puts "Warrior Health: #{ warrior.health }"
    puts "Immediate Enemies: #{ immediate_enemies.inspect }"

    if taking_damage?
      puts "🤕 TAKING DAMAGE"
      taking_damage_tactic!
    else
      if immediate_enemies.count > 0
        # attack first
        attack_or do
          warrior.walk!(warrior.direction_of_stairs)
        end
      else
        if unhealthy?
          puts "💊 UNHEALTHY"
          if next_space.stairs?
            warrior.walk!(:forward) # just go down the stairs instead of resting
          else
            attack_or do
              warrior.rest!
            end
          end
        else
          puts "🏔️ EXPLORING"
          explore!
        end
      end
    end

    @prior_health = warrior.health
  end

  def taking_damage_tactic!
    # i'm taking damage, figure out who I'm taking damage from
    attack_or do
      # it's an archer or wizard
      if warrior.health > ENEMY_BUFFER # can I survive?
        warrior.walk!(:forward)
      else
        # if not, find shelter to rest
        warrior.walk!(:backward)
      end
    end
  end

  def attack_or
    if immediate_enemies.count > 0
      warrior.attack!(immediate_enemies.first)
      # DIRECTIONS.map do |direction|
      #   if enemy_in_nearby?(direction: direction)
      #     warrior.shoot!(direction)
      #   end
      # end
    else
      yield
    end
  end

  def explore!
    attack_or do
      if next_space.captive?
        warrior.rescue!(:forward)
      else
        warrior.walk!(warrior.direction_of_stairs)
      end
    end
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

  def immediate_enemies
    DIRECTIONS.select do |direction|
      enemy_in_direction?(direction: direction)
    end
  end

  def enemy_nearby?(direction:)
    warrior.look(direction).any? do |space|
      space.enemy?
    end
  end

  def next_space
    warrior.feel
  end
  
  def previous_space
    warrior.feel(:backward)
  end

  def enemy_in_direction?(direction:)
    warrior.feel(direction).enemy?
  end
end
