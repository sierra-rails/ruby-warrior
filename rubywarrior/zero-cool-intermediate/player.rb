require 'debug'

# - Rescue immediate ticking captives (if any)
# - Bind immediate enemies (if any)
# - Attack enemies immediately between me and ticking captives (if any)
# - Move towards distant captives, prioritizing ticking ones
# - Attack immediate enemies (if any)
# - if under attack, move towards nearest enemy
# - otherwise rest
# - Rescue immediate captives (if any)
# - Move towards distant non-ticking captives
# - Move towards distant enemies
# - Move towards the stairs

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
    puts "Immediate Captives: #{ immediate_captives.inspect }"
    puts "Immediate Stairs: #{ immediate_stairs.inspect }"
    puts "Distant captives: #{ distant_captives.inspect }"
    puts "Distant ticking captives: #{ distant_captives(ticking: true).inspect }"
    puts "Immediate enemies between me and ticking captives: #{ immediate_enemies_between.inspect }"

  
    if immediate_captives(ticking: true).count > 0
      warrior.rescue!(immediate_captives(ticking: true).first)
    else
      if immediate_enemies.count > 0
        enemy_to_bind = immediate_enemies.reject {|enemy_direction| immediate_enemies_between.any? {|ieb| ieb == enemy_direction } }.first
        
        if distant_captives(ticking: true).count > 0 && !enemy_to_bind.nil?
          warrior.bind!(enemy_to_bind)
        else
          if immediate_enemies.count == 1
            warrior.attack!(immediate_enemies.first)
          else
            warrior.bind!(immediate_enemies.first)
          end
        end
      else
        if immediate_enemies_between.count > 0
          warrior.attack!(immediate_enemies_between.first)
        else

          if distant_captives(ticking: true).count > 0
            move(direction: distant_captives(ticking: true).first)
          else

            if taking_damage?

              if warrior.health > ENEMY_BUFFER # can I survive?
                # TODO move TOWARDS the enemy or shoot him if he's within range
                warrior.walk!(warrior.direction_of_stairs)
              else
                # if not, find shelter to rest
                warrior.walk!(:backward)
              end

            else
            
              if unhealthy?
                warrior.rest!
              else

                if immediate_captives.count > 0
                  warrior.rescue!(immediate_captives.first)
                else
                  if distant_captives.count > 0
                    move(direction: distant_captives.first)
                  else
                    if distant_enemies.count > 0
                      move(direction: distant_enemies.first)
                    else
                      warrior.walk!(warrior.direction_of_stairs)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    @prior_health = warrior.health
  end

  def move(direction:)
    if warrior.feel(direction).stairs?
      # choose a different direction
      new_direction = if warrior.feel(left_of(direction: direction)).wall?
        if warrior.feel(left_of(direction: left_of(direction: direction))).wall?
          if warrior.feel(left_of(direction: left_of(direction: left_of(direction: direction)))).wall?
            raise 'This will probably never happen'
          else
            left_of(directon: left_of(direction: left_of(direction: direction)))
          end
        else
          left_of(directon: left_of(direction: direction))
        end
      else
        left_of(direction: direction)
      end

      # sidestep
      warrior.walk!(new_direction)
    else
      warrior.walk!(direction)
    end
  end

  def left_of(direction:)
    {
      forward: :left,
      left: :backward,
      backward: :right,
      right: :forward
    }[direction]
  end

  def unhealthy?
    warrior.health < HEALTH_BUFFER
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

  def immediate_enemies_between
    immediate_enemies.select do |enemy_direction|
      distant_captives(ticking: true).any? { |direction| direction == enemy_direction }
    end
  end

  def immediate_captives(ticking: false)
    DIRECTIONS.select do |direction|
      captive_in_direction?(direction: direction, ticking: ticking)
    end
  end

  def immediate_stairs
    DIRECTIONS.select do |direction|
      stairs_in_direction?(direction: direction)
    end
  end

  def distant_captives(ticking: false)
    warrior.listen.select do |space|
      space.captive? && space.ticking? == ticking
    end.map do |space|
      warrior.direction_of(space)
    end
  end

  def distant_enemies
    warrior.listen.select do |space|
      space.enemy?
    end.map do |space|
      warrior.direction_of(space)
    end
  end

  def enemy_nearby?(direction:)
    warrior.look(direction).any? do |space|
      space.enemy?
    end
  end

  def enemy_in_direction?(direction:)
    warrior.feel(direction).enemy?
  end

  def captive_in_direction?(direction:, ticking:)
    warrior.feel(direction).captive? && warrior.feel(direction).ticking? == ticking
  end

  def stairs_in_direction?(direction:)
    warrior.feel(direction).stairs?
  end
end
