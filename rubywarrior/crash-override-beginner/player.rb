require 'debug'

class Player
  HEALTH_BUFFER = 20.freeze
  ARCHER_BUFFER = 10.freeze
  attr_accessor :warrior

  @prior_health = nil
  @warrior = nil

  def play_turn(warrior)
    @warrior = warrior
    puts "Warrior Health: #{ warrior.health }"

    if taking_damage?
      puts "🤕 TAKING DAMAGE"
      taking_damage_tactic!
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

    @prior_health = warrior.health
  end

  def taking_damage_tactic!
    # i'm taking damage, figure out who I'm taking damage from
    attack_or do
      # it's an archer
      if warrior.health > ARCHER_BUFFER # can I survive?
        warrior.walk!
      else
        # if not, find shelter to rest
        warrior.walk!(:backward)
      end
    end
  end

  def attack_or
    if enemy_in_next_space?
      warrior.attack!(:forward)
    elsif enemy_in_previous_space?
      warrior.attack(:previous)
    elsif enemy_ahead?
      warrior.shoot!(:forward)
    elsif enemy_behind?
      warrior.shoot!(:backward)
    else
      yield
    end
  end

  def explore!
    if next_space.wall?
      warrior.pivot!
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

  def enemy_ahead?
    enemy_nearby?(direction: :forward)
  end

  def enemy_behind?
    enemy_nearby?(direction: :backward)
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
