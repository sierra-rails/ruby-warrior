class Player
  def play_turn(warrior)
    # add your code here
    @health ||= 20

    # if no one ahead, not taking damage, and wounded, HEAL
    if warrior.feel.empty? && !(@health > warrior.health) && warrior.health < 20
      warrior.rest!

    # if enemy in range, ATTACK
    elsif !warrior.feel.empty?
      warrior.attack!

    # else WALK
    else
      warrior.walk!
    end

    @health = warrior.health
    puts "warrior health: #{warrior.health}"
    puts "@health: #{@health}"
  end

  # def enemy_in_range?
  #   !warrior.feel.empty?
  # end

  # def enemy_out_of_range?
  #   warrior.feel.empty?
  # end

  # def taking_damage?
  #   @health <= warrior.health
  # end

  # def not_taking_damage?
  #   @health < warrior.health
  # end

  # def wounded?
  #   warrior.health < 20
  # end

  # def at_full_health?
  #   warrior.health == 20
  # end
end
