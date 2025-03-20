#Defensive Role modifiers
PBAI::SwitchHandler.add do |score,ai,battler,proj,target|
  roles = []
    for i in proj.pokemon.roles
      roles.push(i)
    end
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  battler.opposing_side.battlers.each do |target|
    next if target.nil?
    if target.is_physical_attacker? && [:PHYSICALWALL].include?(roles)
      score += 3
      PBAI.log_switch(proj.pokemon.name,"+ 3")
    end
    if target.is_special_attacker? && [:SPECIALWALL].include?(roles)
      score += 3
      PBAI.log_switch(proj.pokemon.name,"+ 3")
    end
    if mon.defensive? && ![:PHYSICALWALL,:SPECIALWALL].include?(roles)
      if [:DEFENSIVEPIVOT,:CLERIC,:TOXICSTALLER,:LEAD,:TANK].include?(roles)
        score += 2
        PBAI.log_switch(proj.pokemon.name,"+ 2")
      else
        score += 1
        PBAI.log_switch(proj.pokemon.name,"+ 1")
      end
    end
  end
  next score
end

#Setup Prevention
PBAI::SwitchHandler.add do |score,ai,battler,proj,target|
  setup = 0
  add = 0
  target_moves = target.moves
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  if target_moves != nil
    for i in target_moves
      if PBAI::AI_Move.setup_move?(i)
        setup += 1
      end
    end
  end
  if setup >= 1
    add = setup
    score += add
    PBAI.log_switch(proj.pokemon.name,"+ #{add} to prevent setup")
    $learned_flags[:has_setup].push(target)
  end
  next score
end

#Identifying Setup Fodder
PBAI::SwitchHandler.add do |score,ai,battler,proj,target|
  next score if $switch_flags[:setup_fodder].nil?
  pkmn = ai.pbMakeFakeBattler(proj.pokemon)
  if $switch_flags[:setup_fodder].include?(target)
    party = ai.battle.pbParty(battler.index)
    setup_mons = party.find_all {|mon| mon.has_role?([:SETUPSWEEPER,:WINCON]) && mon.moves.any? {|move| PBAI::AI_Move.setup_move?(move)}}
    strong_moves = target.moves.find_all {|targ_move| proj.get_calc(target,targ_move) >= pkmn.hp/2}
    setup_mons.each do |pk|
      next if pk != pkmn
      score += 1 if pk.faster_than?(target)
      score += 1 if target.bad_against?(pk)
      score -= 2 if pk.bad_against?(target)
      score -= 1 if strong_moves.length > 0
      score += 1 if PBAI.threat_score(pk,target) <= 0
    end
  end
  next score
end

#Health Related
PBAI::SwitchHandler.add do |score,ai,battler,proj,target|
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  if mon.hp <= mon.totalhp/4
    score -= 10
    PBAI.log_switch(proj.pokemon.name,"- 10")
  end
  if ai.battle.positions[battler.index].effects[PBEffects::Wish] > 0 && mon.hp <= mon.totalhp/3
    score += 4
    PBAI.log_switch(proj.pokemon.name,"+ 4")
    score += 2 if mon.setup?
    PBAI.log_switch(proj.pokemon.name,"+ 2") if mon.setup?
  end
  if $switch_flags[:need_cleric] && mon.has_role?(:CLERIC)
    score += 4
    PBAI.log_switch(proj.pokemon.name,"+ 4")
  end
  next score
end

#Don't switch if you will die to hazards
PBAI::SwitchHandler.add do |score,ai,battler,proj,target|
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  next if !mon.takesIndirectDamage?
  hazard_score = 0
  rocks = proj.own_side.effects[PBEffects::StealthRock] ? 1 : 0
  webs = proj.own_side.effects[PBEffects::StickyWeb] ? 1 : 0
  spikes = proj.own_side.effects[PBEffects::Spikes] > 0 ? proj.own_side.effects[PBEffects::Spikes] : 0
  tspikes = proj.own_side.effects[PBEffects::ToxicSpikes] > 0 ? proj.own_side.effects[PBEffects::ToxicSpikes] : 0
  hazard_score = (rocks) + (spikes) + (tspikes)
  if hazard_score > 0
    score -= hazard_score
    PBAI.log_switch(proj.pokemon.name,"- #{hazard_score}")
  end

  #Switch in to absorb hazards
  if tspikes > 0 && (mon.pbHasType?(:POISON) && !mon.airborne? && mon.item != :HEAVYDUTYBOOTS)
    score += 4
    PBAI.log_switch(proj.pokemon.name,"+ 4")
  end
  next score
end

# Tag Battles say hisssss
PBAI::SwitchHandler.add do |score,ai,battler,proj,target|
  next if !ai.battle.doublebattle
  if proj.pokemon.owner.id != battler.pokemon.owner.id
    score -= 100
    PBAI.log_switch(proj.pokemon.name,"- 100 because it's not yours")
  end
  next score
end

PBAI::SwitchHandler.add do |score,ai,battler,proj,target|
  next score if !ai.battle.doublebattle
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  ally = battler.side.battlers.find {|pm| pm && pm != battler && !pm.fainted?}
  next score if ally.nil?
  for move in ally.moves
    if ally.target_is_immune?(move,battler) && [:AllNearOthers,:AllBattlers,:BothSides].include?(move.pbTarget(mon))
      score += 2
      PBAI.log_switch(proj.pokemon.name,"+ 2")
    end
  end
  next score
end

PBAI::SwitchHandler.add do |score,ai,battler,proj,target|
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  if $spam_block_triggered && $spam_block_flags[:choice].is_a?(PokeBattle_Move)
    nextMove = $spam_block_flags[:choice]
    nextDmg = battler.get_calc(target,nextMove)
    damage = 0
    if nextDmg >= mon.hp
      score -= 10
      PBAI.log_switch(proj.pokemon.name,"- 10 because the battler will faint switching in")
    else
      if proj.faster_than?(target)
        for move in proj.moves
          damage += 1 if proj.get_calc_self(target,move) >= (target.hp || target.totalhp/2)
        end
        if damage > 0
          score += 2
          PBAI.log_switch(proj.pokemon.name,"+ 2 because battler can kill or do significant damage before being killed")
        else
          score -= 3
          PBAI.log_switch(proj.pokemon.name,"- 3 because battler will be killed before it can kill")
        end
      end
    end
  end
  next score
end

PBAI::SwitchHandler.add do |score,ai,battler,proj,target|
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  if mon.has_role?(:FEAR)
    score -= 4
    PBAI.log_switch(proj.pokemon.name,"- 4 to encourage the AI to not switch this in hard")
  end
  next score
end

#========================
# Type-base Switch Scoring
#========================
PBAI::SwitchHandler.add_type(:FIRE) do |score,ai,battler,proj,target|
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  if $switch_flags[:fire] == true
    if mon.hasActiveAbility?([:FLASHFIRE,:STEAMENGINE,:WELLBAKEDBODY])
      score += 2
      PBAI.log_switch(proj.pokemon.name,"+ 2 for Fire immunity")
    else
      eff = Effectiveness.super_effective_type?(:FIRE,mon.types[0],mon.types[1],mon.effects[PBEffects::Type3])
      if eff
        add = score
        score = 0
        PBAI.log_switch(proj.pokemon.name,"-#{score} to prevent switching into a super effective move")
      end
    end
    if mon.hasActiveAbility?(:THERMALEXCHANGE) 
      score += 1
      PBAI.log_switch(proj.pokemon.name,"+ 1 to gain a boost from Fire moves")
    end
  end
  next score
end

PBAI::SwitchHandler.add_type(:WATER) do |score,ai,battler,proj,target|
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  if $switch_flags[:water] == true
    if mon.hasActiveAbility?([:WATERABSORB,:DRYSKIN,:STORMDRAIN,:STEAMENGINE,:WATERCOMPACTION])
      score += 2
      PBAI.log_switch(proj.pokemon.name,"+ 2 for Water immunity")
    else
      eff = Effectiveness.super_effective_type?(:WATER,mon.types[0],mon.types[1],mon.effects[PBEffects::Type3])
      if eff
        add = score
        score = 0
        PBAI.log_switch(proj.pokemon.name,"-#{score} to prevent switching into a super effective move")
      end
    end
  end
  next score
end

PBAI::SwitchHandler.add_type(:GRASS) do |score,ai,battler,proj,target|
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  if $switch_flags[:grass] == true
    if mon.hasActiveAbility?(:SAPSIPPER)
      score += 2
      PBAI.log_switch(proj.pokemon.name,"+ 2 for Grass immunity")
    else
      eff = Effectiveness.super_effective_type?(:GRASS,mon.types[0],mon.types[1],mon.effects[PBEffects::Type3])
      if eff
        add = score
        score = 0
        PBAI.log_switch(proj.pokemon.name,"-#{score} to prevent switching into a super effective move")
      end
    end
  end
  next score
end

PBAI::SwitchHandler.add_type(:ELECTRIC) do |score,ai,battler,proj,target|
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  if $switch_flags[:electric] == true
    if mon.hasActiveAbility?([:VOLTABSORB,:LIGHTNINGROD,:MOTORDRIVE])
      score += 2
      PBAI.log_switch(proj.pokemon.name,"+ 2 for Electric immunity")
    else
      eff = Effectiveness.super_effective_type?(:ELECTRIC,mon.types[0],mon.types[1],mon.effects[PBEffects::Type3])
      if eff
        add = score
        score = 0
        PBAI.log_switch(proj.pokemon.name,"-#{score} to prevent switching into a super effective move")
      end
    end
  end
  next score
end

PBAI::SwitchHandler.add_type(:GROUND) do |score,ai,battler,proj,target|
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  if $switch_flags[:ground] == true
    if mon.hasActiveAbility?(:EARTHEATER) || mon.airborne?
      score += 2
      PBAI.log_switch(proj.pokemon.name,"+ 2 for Ground immunity")
    else
      eff = Effectiveness.super_effective_type?(:GROUND,mon.types[0],mon.types[1],mon.effects[PBEffects::Type3])
      if eff
        add = score
        score = 0
        PBAI.log_switch(proj.pokemon.name,"-#{score} to prevent switching into a super effective move")
      end
    end
    for i in target.moves
      if proj.calculate_move_matchup(i.id) < 1 && i.function == "TwoTurnAttackInvulnerableUnderground"
        dig = true
      end
      if proj.calculate_move_matchup(i.id) > 1 && i.function == "TwoTurnAttackInvulnerableUnderground"
        no_dig = true
      end
    end
    if dig == true && $switch_flags[:digging] == true
      score += 1
      PBAI.log_switch(proj.pokemon.name,"+ 1 to be immune to Dig")
    end
    if no_dig == true && $switch_flags[:digging] == true
      score -= 10
      PBAI.log_switch(proj.pokemon.name,"- 10")
    end
  end
  next score
end

PBAI::SwitchHandler.add_type(:DARK) do |score,ai,battler,proj,target|
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  pos = ai.battle.positions[battler.index]
  party = ai.battle.pbParty(battler.index)
  if $switch_flags[:dark] == true
    if mon.hasActiveAbility?(:UNTAINTED)
      score += 2
      PBAI.log_switch(proj.pokemon.name,"+ 2 for Dark immunity")
    elsif mon.hasActiveAbility?(:JUSTIFIED)
      score += 1
      PBAI.log_switch(proj.pokemon.name,"+ 1 to gain a boost from Dark moves")
    else
      eff = Effectiveness.super_effective_type?(:DARK,mon.types[0],mon.types[1],mon.effects[PBEffects::Type3])
      if eff
        add = score
        score = 0
        PBAI.log_switch(proj.pokemon.name,"-#{score} to prevent switching into a super effective move")
      end
    end
  end
  next score
end

PBAI::SwitchHandler.add_type(:POISON) do |score,ai,battler,proj,target|
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  if $switch_flags[:poison] == true
    if mon.hasActiveAbility?(:PASTELVEIL)
      score += 2
      PBAI.log_switch(proj.pokemon.name,"+ 2 for Poison immunity")
    else
      eff = Effectiveness.super_effective_type?(:POISON,mon.types[0],mon.types[1],mon.effects[PBEffects::Type3])
      if eff
        add = score
        score = 0
        PBAI.log_switch(proj.pokemon.name,"-#{score} to prevent switching into a super effective move")
      end
    end
  end
  next score
end

PBAI::SwitchHandler.add_type(:ROCK) do |score,ai,battler,proj,target|
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  if $switch_flags[:rock] == true
    if mon.hasActiveAbility?(:SCALER)
      score += 2
      PBAI.log_switch(proj.pokemon.name,"+ 2 for Rock immunity")
    else
      eff = Effectiveness.super_effective_type?(:ROCK,mon.types[0],mon.types[1],mon.effects[PBEffects::Type3])
      if eff
        add = score
        score = 0
        PBAI.log_switch(proj.pokemon.name,"-#{score} to prevent switching into a super effective move")
      end
    end
  end
  next score
end

PBAI::SwitchHandler.add_type(:DRAGON) do |score,ai,battler,proj,target|
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  if $switch_flags[:dragon] == true
    if mon.hasActiveAbility?(:LEGENDARMOR)
      score += 2
      PBAI.log_switch(proj.pokemon.name,"+ 2 for Dragon immunity")
    else
      eff = Effectiveness.super_effective_type?(:DRAGON,mon.types[0],mon.types[1],mon.effects[PBEffects::Type3])
      if eff
        add = score
        score = 0
        PBAI.log_switch(proj.pokemon.name,"-#{score} to prevent switching into a super effective move")
      end
    end
  end
  next score
end

PBAI::SwitchHandler.add do |score,ai,battler,proj,target|
  mon = ai.pbMakeFakeBattler(proj.pokemon)
  party = ai.battle.pbParty(battler.index)
  able_party = party.find_all {|pkmn| pkmn && !pkmn.fainted? && !pkmn.egg?}
  if mon.hasActiveAbility?(:SUPREMEOVERLORD) && able_party.length != 1
    nope = able_party.length
    score -= nope
    PBAI.log_switch(proj.pokemon.name,"-#{nope} for attempting to use Supreme Overlord effectively")
  end
  next score
end

PBAI::SwitchHandler.add do |score,ai,battler,proj,target|
  if (target.lastMoveUsed != nil) || ($spam_block_triggered && $spam_block_flags[:choice].is_a?(Battle::Move))
   lastMove = $spam_block_triggered && $spam_block_flags[:choice].is_a?(Battle::Move) ? $spam_block_flags[:choice] : GameData::Move.get(target.lastMoveUsed)
   matchup = proj.calculate_move_matchup(lastMove.id)
   type_matchup = proj.calculate_type_matchup(target)/8
   immune = 0
   if matchup < 2.0
     immune = matchup + type_matchup
   elsif matchup >= 2.0
     immune = -4
   end
   if matchup == 0.0
     immune += 5
   end
   if $switch_flags[:has_se_move].include?(proj.pokemon)
     immune = -10
   end
   $switch_flags[:immunity] = proj if matchup == 0.0
   if !immune.is_a?(Float) || !immune.is_a?(Integer)
     immune = 0
   end
   score += immune
   PBAI.log_switch(proj.pokemon.name,"+ #{immune} for the matchup score")
   end
  next score
end

#Don't switch if weak to pursuit
PBAI::SwitchHandler.add do |score,ai,battler,proj,target|
  next unless target.pokemon.hasMove?(:PURSUIT)
  matchup = battler.calculate_move_matchup(:PURSUIT)
  bad = false
  if matchup >= 2.0
    bad = true
  end
  if bad
    score -= 10
    PBAI.log_switch(proj.pokemon.name,"- 10 because we are weak to Pursuit")
  end
  next score
end

PBAI::SwitchHandler.add do |score,ai,battler,proj,target|
  next score if $spam_block_triggered
  next score if PBAI.threat_score(battler,target) != 50
  score -= 10
  PBAI.log_switch(proj.pokemon.name,"- 10 because the target gets fast OHKO on the entire party")
  next score
end