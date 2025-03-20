

alias mixed_ev_alloc_pbChangeLevel pbChangeLevel
def pbChangeLevel(pkmn, new_level, scene)
  if new_level > pkmn.level
    # DemICE edit
    evpool=80+pkmn.level*8
    evpool=(evpool.div(4))*4      
    evpool=512 if evpool>512    
    evcap=40+pkmn.level*4
    evcap=(evcap.div(4))*4
    evcap=252 if evcap>252
    increment=4*(new_level-pkmn.level)
    evsum=pkmn.ev[:HP]+pkmn.ev[:ATTACK]+pkmn.ev[:DEFENSE]+pkmn.ev[:SPECIAL_DEFENSE]+pkmn.ev[:SPEED]   
    evsum+=pkmn.ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE
    evarray=[]
    GameData::Stat.each_main do |s|
      evarray.push(pkmn.ev[s.id])
    end
    if evsum>0 && evpool>evsum && evarray.max<evcap && evarray.max_nth(2)<evcap
      GameData::Stat.each_main do |s|
        if pkmn.ev[s.id]==evarray.max
          pkmn.ev[s.id]+=increment
          pkmn.calc_stats
          pkmn.ev[s.id]+=increment if pkmn.ev[s.id]<evcap
          pkmn.ev[s.id]=evcap if pkmn.ev[s.id]>evcap
          pkmn.calc_stats
        end
      end  
      evsum=pkmn.ev[:HP]+pkmn.ev[:ATTACK]+pkmn.ev[:DEFENSE]+pkmn.ev[:SPECIAL_DEFENSE]+pkmn.ev[:SPEED] 
      evsum+=pkmn.ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE
      evarray=[]
      GameData::Stat.each_main do |s|
        evarray.push(pkmn.ev[s.id])
      end
      if evpool>evsum
        GameData::Stat.each_main do |s|
          if pkmn.ev[s.id]==evarray.max_nth(2)
            pkmn.ev[s.id]+=increment
            pkmn.ev[s.id]=evcap if pkmn.ev[s.id]>evcap
            pkmn.calc_stats
          end
        end  
      end                            
    end        
    # DemICE end
  elsif new_level < pkmn.level
    GameData::Stat.each_main do |s|
      if pkmn.ev[s.id]=0
        pkmn.calc_stats
      end
    end      
  end
  mixed_ev_alloc_pbChangeLevel(pkmn, new_level, scene)
end

class Battle

  alias mixed_ev_alloc_pbGainExpOne pbGainExpOne
  def pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages = true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining Exp from defeatedBattler
    current_level = pkmn.level

    mixed_ev_alloc_pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages)
    
    if pkmn.level > current_level
      # DemICE edit
      evpool=80+pkmn.level*8
      evpool=(evpool.div(4))*4      
      evpool=512 if evpool>512    
      evcap=40+pkmn.level*4
      evcap=(evcap.div(4))*4
      evcap=252 if evcap>252
      evsum=pkmn.ev[:HP]+pkmn.ev[:ATTACK]+pkmn.ev[:DEFENSE]+pkmn.ev[:SPECIAL_DEFENSE]+pkmn.ev[:SPEED]   
      evsum+=pkmn.ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE
        evarray=[]
        GameData::Stat.each_main do |s|
        evarray.push(pkmn.ev[s.id])
        end
      if evsum>0 && evpool>evsum && evarray.max<evcap && evarray.max_nth(2)<evcap
        GameData::Stat.each_main do |s|
          if pkmn.ev[s.id]==evarray.max
            pkmn.ev[s.id]+=4
            pkmn.calc_stats
            pkmn.ev[s.id]+=4 if pkmn.ev[s.id]<evcap
            pkmn.ev[s.id]=evcap if pkmn.ev[s.id]>evcap
            pkmn.calc_stats
          end
        end  
        evsum=pkmn.ev[:HP]+pkmn.ev[:ATTACK]+pkmn.ev[:DEFENSE]+pkmn.ev[:SPECIAL_DEFENSE]+pkmn.ev[:SPEED] 
        evsum+=pkmn.ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE
        evarray=[]
        GameData::Stat.each_main do |s|
          evarray.push(pkmn.ev[s.id])
        end
        if evpool>evsum
          GameData::Stat.each_main do |s|
            if pkmn.ev[s.id]==evarray.max_nth(2)
              pkmn.ev[s.id]+=4
              pkmn.ev[s.id]=evcap if pkmn.ev[s.id]>evcap
              pkmn.calc_stats
            end
          end  
        end                            
      end  
      pkmn.calc_stats
      # DemICE end
    elsif pkmn.level < current_level
      GameData::Stat.each_main do |s|
        if pkmn.ev[s.id]=0
          pkmn.calc_stats
        end
      end         
    end  
  end

  def pbGainEVsOne(idxParty, defeatedBattler)
    return
  end

end  

module Battle::CatchAndStoreMixin

  alias evalloc_pbStorePokemon pbStorePokemon
  def pbStorePokemon(pkmn)
    if $game_map.map_id != 48
      offense = [pkmn.baseStats[:ATTACK], pkmn.baseStats[:SPECIAL_ATTACK]].max
      statarray = [pkmn.baseStats[:HP], offense, pkmn.baseStats[:DEFENSE], pkmn.baseStats[:SPEED], pkmn.baseStats[:SPECIAL_DEFENSE]]
      evcap=40+pkmn.level*4
      evcap=252 if evcap>252
      stat1 = statarray.index(statarray.max)
      stat2 = statarray.index(statarray.max_nth(2))
      stat2 += 1 if stat1 == stat2
      case stat1
      when 0
        pkmn.ev[:HP] = evcap
      when 1
        pkmn.ev[:ATTACK] = evcap
      when 2
        pkmn.ev[:DEFENSE] = evcap
      when 3
        pkmn.ev[:SPEED] = evcap
      when 4
        pkmn.ev[:SPECIAL_DEFENSE] = evcap
      end
      case stat2
      when 0
        pkmn.ev[:HP] = evcap
      when 1
        pkmn.ev[:ATTACK] = evcap
      when 2
        pkmn.ev[:DEFENSE] = evcap
      when 3
        pkmn.ev[:SPEED] = evcap
      when 4
        pkmn.ev[:SPECIAL_DEFENSE] = evcap
      end
    end
    evalloc_pbStorePokemon(pkmn)
  end

end

alias evalloc_pbNicknameAndStore pbNicknameAndStore
def pbNicknameAndStore(pkmn)
  if $game_map.map_id != 48
    offense = [pkmn.baseStats[:ATTACK], pkmn.baseStats[:SPECIAL_ATTACK]].max
    statarray = [pkmn.baseStats[:HP], offense, pkmn.baseStats[:DEFENSE], pkmn.baseStats[:SPEED], pkmn.baseStats[:SPECIAL_DEFENSE]]
    evcap=40+pkmn.level*4
    evcap=252 if evcap>252
    stat1 = statarray.index(statarray.max)
    stat2 = statarray.index(statarray.max_nth(2))
    stat2 += 1 if stat1 == stat2
    case stat1
    when 0
      pkmn.ev[:HP] = evcap
    when 1
      pkmn.ev[:ATTACK] = evcap
    when 2
      pkmn.ev[:DEFENSE] = evcap
    when 3
      pkmn.ev[:SPEED] = evcap
    when 4
      pkmn.ev[:SPECIAL_DEFENSE] = evcap
    end
    case stat2
    when 0
      pkmn.ev[:HP] = evcap
    when 1
      pkmn.ev[:ATTACK] = evcap
    when 2
      pkmn.ev[:DEFENSE] = evcap
    when 3
      pkmn.ev[:SPEED] = evcap
    when 4
      pkmn.ev[:SPECIAL_DEFENSE] = evcap
    end
  end
  evalloc_pbNicknameAndStore(pkmn)
end

class PokemonEggHatch_Scene

  alias evalloc_pbMain pbMain
  def pbMain
    if $game_map.map_id != 48
      offense = [@pokemon.baseStats[:ATTACK], @pokemon.baseStats[:SPECIAL_ATTACK]].max
      statarray = [@pokemon.baseStats[:HP], offense, @pokemon.baseStats[:DEFENSE], @pokemon.baseStats[:SPEED], @pokemon.baseStats[:SPECIAL_DEFENSE]]
      evcap=40+@pokemon.level*4
      evcap=252 if evcap>252
      stat1 = statarray.index(statarray.max)
      stat2 = statarray.index(statarray.max_nth(2))
      stat2 += 1 if stat1 == stat2
      case stat1
      when 0
        @pokemon.ev[:HP] = evcap
      when 1
        @pokemon.ev[:ATTACK] = evcap
      when 2
        @pokemon.ev[:DEFENSE] = evcap
      when 3
        @pokemon.ev[:SPEED] = evcap
      when 4
        @pokemon.ev[:SPECIAL_DEFENSE] = evcap
      end
      case stat2
      when 0
        @pokemon.ev[:HP] = evcap
      when 1
        @pokemon.ev[:ATTACK] = evcap
      when 2
        @pokemon.ev[:DEFENSE] = evcap
      when 3
        @pokemon.ev[:SPEED] = evcap
      when 4
        @pokemon.ev[:SPECIAL_DEFENSE] = evcap
      end
    end
    evalloc_pbMain
  end

end