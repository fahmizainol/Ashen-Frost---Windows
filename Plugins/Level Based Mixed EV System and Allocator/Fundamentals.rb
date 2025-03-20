

module Enumerable  
  def max_nth(n)
    inject([]) do |acc, x|
      (acc + [x]).sort[[acc.size-(n-1), 0].max..-1]
    end.first
  end  
end

class Pokemon
  attr_accessor :trainerevs
  # Max total EVs
  EV_LIMIT      = 0  # DemICE edit
  # Max EVs that a single stat can have
  EV_STAT_LIMIT = 0  # DemICE edit

    # Duplicated method to be used in battle factory
  def calc_stats_old
    base_stats = self.baseStats
    this_level = self.level
    this_IV    = self.calcIV
    # Format stat multipliers due to nature
    nature_mod = {}
    GameData::Stat.each_main { |s| nature_mod[s.id] = 100 }
    this_nature = self.nature_for_stats
    if this_nature
      this_nature.stat_changes.each { |change| nature_mod[change[0]] += change[1] }
    end
    # Calculate stats
    stats = {}
    GameData::Stat.each_main do |s|
      if s.id == :HP
        stats[s.id] = calcHP(base_stats[s.id], this_level, this_IV[s.id], @ev[s.id])
      else
        stats[s.id] = calcStat(base_stats[s.id], this_level, this_IV[s.id], @ev[s.id], nature_mod[s.id])
      end
    end
    hp_difference = stats[:HP] - @totalhp
    @totalhp = stats[:HP]
    self.hp = [@hp + hp_difference, 1].max if @hp > 0 || hp_difference > 0
    @attack  = stats[:ATTACK]
    @defense = stats[:DEFENSE]
    @spatk   = stats[:SPECIAL_ATTACK]
    @spdef   = stats[:SPECIAL_DEFENSE]
    @speed   = stats[:SPEED]
  end  

  
  # Recalculates this Pokémon's stats.
  alias mixed_ev_alloc_calc_stats calc_stats
  def calc_stats(trainercreate=false)
    #DemICE failsafe for the new EV system
      GameData::Stat.each_main do |s|
        evcap=40+self.level*4
        if @ev[s.id] >evcap
          @ev[s.id]=evcap
        end 
      # else
      #   limit=80+pkmn_data[:level]*8
      #   pkmn.ev[s.id] = [pkmn_data[:level] * 3 / 2, limit / 6].min
    end  
    evpool=80+self.level*8
    evpool=(evpool.div(4))*4      
    evpool=512 if evpool>512 
    evsum=@ev[:HP]+@ev[:ATTACK]+@ev[:DEFENSE]+@ev[:SPECIAL_DEFENSE]+@ev[:SPEED]
    evsum+=@ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE
    #if !trainercreate
      GameData::Stat.each_main do |s|
        if evsum>evpool
          @ev[s.id]=0  
        end  
      end 
    # else
    # end  
    if !Settings::PURIST_MODE 
      @ev[:SPECIAL_ATTACK]=@ev[:ATTACK]
    end  
    mixed_ev_alloc_calc_stats
  end

end  

 