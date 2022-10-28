class Player
  def play_turn(warrior)
    @health = warrior.health unless @health

    if warrior.feel.empty?
      if warrior.health < 20 && warrior.health >= @health
        if warrior.feel(:backward).captive?
          warrior.rescue!(:backward)
        elsif warrior.feel(:backward).wall?
          warrior.rest!
        else
          warrior.walk!(:backward)
        end
      else
        warrior.walk!
      end
    else
      warrior.attack!
    end

    @health = warrior.health
  end
end