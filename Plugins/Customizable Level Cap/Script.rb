## New Level Cap System - Notes for Josie

# To change the level cap, simply create an event that runs the script:
# $player.level_cap = <new value>
# To change the exp reduction rate, simply create an event that runs the script:
# $player_system.exp_reduction_rate = <new value>


# NOTE: Any previous saves will not have their level caps defined,
# due to this metric now depending on player creation.
# This is also so that it plays better with the multiple protags script
class Player < Trainer
  attr_accessor :level_cap
  attr_accessor :exp_reduction_rate

  def level_cap
    return @level_cap
  end
  
  def initialize(name, trainer_type)
    super
    @character_ID          = 0
    @outfit                = 0
    @badges                = [false] * 8
    @money                 = GameData::Metadata.get.start_money
    @coins                 = 0
    @battle_points         = 0
    @soot                  = 0
    @pokedex               = Pokedex.new
    @has_pokedex           = false
    @has_pokegear          = false
    @has_running_shoes     = true
    @has_box_link          = false
    @seen_storage_creator  = false
    @has_exp_all           = true
    @mystery_gift_unlocked = false
    @mystery_gifts         = []
    @level_cap             = 20
    @exp_reduction_rate    = 5
  end
end

class Battle
  def pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages = true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining Exp from defeatedBattler
    growth_rate = pkmn.growth_rate
    # Don't bother calculating if gainer is already at max Exp
    if pkmn.exp >= growth_rate.maximum_exp
      pkmn.calc_stats   # To ensure new EVs still have an effect
      return
    end
    isPartic    = defeatedBattler.participants.include?(idxParty)
    hasExpShare = expShare.include?(idxParty)
    level = defeatedBattler.level
    level_cap = $player.level_cap
    level_cap_gap = growth_rate.exp_values[level_cap] - pkmn.exp
    exp_reduction_rate = $player.exp_reduction_rate
    #Console.echo_h1 _INTL("\n\n[LEVEL CAP] lvl_cap: %d , reduction_rate: %d" % [level_cap, exp_reduction_rate])
    # Main Exp calculation
    exp = 0
    a = level * defeatedBattler.pokemon.base_exp
    if expShare.length > 0 && (isPartic || hasExpShare)
      if numPartic == 0   # No participants, all Exp goes to Exp Share holders
        exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? expShare.length : 1)
      elsif Settings::SPLIT_EXP_BETWEEN_GAINERS   # Gain from participating and/or Exp Share
        exp = a / (2 * numPartic) if isPartic
        exp += a / (2 * expShare.length) if hasExpShare
      else   # Gain from participating and/or Exp Share (Exp not split)
        exp = (isPartic) ? a : a / 2
      end
    elsif isPartic   # Participated in battle, no Exp Shares held by anyone
      exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? numPartic : 1)
    elsif expAll   # Didn't participate in battle, gaining Exp due to Exp All
      # NOTE: Exp All works like the Exp Share from Gen 6+, not like the Exp All
      #       from Gen 1, i.e. Exp isn't split between all Pokémon gaining it.
      exp = a / 2
    end
    return if exp <= 0
    # Pokémon gain more Exp from trainer battles
    exp = (exp * 1.5).floor if trainerBattle?
    # Scale the gained Exp based on the gainer's level (or not)
    reduced_gain = 0 # 0 = exp gain was not reduced, 1 = exp gain was fully reduced, 2 = exp gain was partially reduced, 3 = pkmn just reached level cap so only overflow exp was reduced
    if Settings::SCALED_EXP_FORMULA
      exp /= 5
      levelAdjust = ((2 * level) + 10.0) / (pkmn.level + level + 10.0)
      levelAdjust = levelAdjust**5
      levelAdjust = Math.sqrt(levelAdjust)
      exp *= levelAdjust
      exp = exp.floor
      exp += 1 if isPartic || hasExpShare
    else # If you are not playing on gen 7+ settings...
      if a <= level_cap_gap
        exp = a
      else
        exp /= 7
      end
    end
    # Foreign Pokémon gain more Exp
    isOutsider = (pkmn.owner.id != pbPlayer.id ||
                 (pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language))
    if isOutsider 
      if pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language
        exp = (exp * 1.7).floor
      else
        exp = (exp * 1.5).floor
      end
    end
    # Exp. Charm increases Exp gained
    exp = exp * 3 / 2 if $bag.has?(:EXPCHARM) 
    # Modify Exp gain based on pkmn's held item
    i = Battle::ItemEffects.triggerExpGainModifier(pkmn.item, pkmn, exp)
    if i < 0
      i = Battle::ItemEffects.triggerExpGainModifier(@initialItems[0][idxParty], pkmn, exp)
    end
    exp = i if i >= 0
    # Boost Exp gained with high affection
    if Settings::AFFECTION_EFFECTS && @internalBattle && pkmn.affection_level >= 4 && !pkmn.mega?
      exp = exp * 6 / 5
      isOutsider = true   # To show the "boosted Exp" message
    end
    # Level Cap calculations
    #Console.echo _INTL("\n[EXP scale formula] Original EXP earned before lvl_cap check: %d" % [exp])
    if pkmn.level >= level_cap - 2 && $PokemonGlobal.levelcap == 0 # If you are at least within 2 levels of the level cap, do the following:
      if pkmn.level >= level_cap # If you are over the level cap, receive reduced exp
        exp /= exp_reduction_rate
        reduced_gain = 1
        #Console.echo _INTL("\n[EXP scale formula] When pkmn.lvl >= lvl_cap: Reduce by %d --> New Exp: %d" % [exp_reduction_rate, exp])
      else
        exp /= (exp_reduction_rate / 2) # If you are within 2 levels of the level cap, receive only partially reduced exp
        reduced_gain = 2
        #Console.echo _INTL("\n[EXP scale formula] When pkmn.lvl >= lvl_cap -2: Reduce by %d --> New Exp: %d" % [(exp_reduction_rate / 2), exp])
      end
    end
    if pkmn.level < level_cap && exp >= level_cap_gap # If your exp winnings make you reach the level cap, reduce the excess
      excess_exp = (exp - level_cap_gap)
      exp = $PokemonGlobal.levelcap == 0 ? level_cap_gap + excess_exp / exp_reduction_rate : level_cap_gap
      reduced_gain = 3
      #Console.echo _INTL("\n[EXP scale formula] When exp >= level_cap_gap :: Lvl_Cap_Gap: %d , Excess Exp to reduce: %d --> New Exp: %d" % [level_cap_gap, excess_exp, exp])
    end
    # Make sure Exp doesn't exceed the maximum
    expFinal = growth_rate.add_exp(pkmn.exp, exp)
    expGained = expFinal - pkmn.exp
    # Add check for hard cap
    expGained = 0 if $PokemonGlobal.levelcap == 1 && pkmn.level >= level_cap
    #Console.echo_h1 _INTL("\n[EXP GAINED] %d" % [expGained])
    return if expGained <= 0
    # "Exp gained" message
    if showMessages
      msg_reduction = "got" # Normal xp gain message
      if reduced_gain != 0 # 0 = exp gain was not reduced, 1 = exp gain was fully reduced, 2 = exp gain was partially reduced, 3 = pkmn just reached level cap so only overflow exp was reduced
        msg_reduction = "has little left to learn here and only got" # XP gain message when exp was reduced.
      end
      if isOutsider
        pbDisplayPaused(_INTL("{1} {2} a boosted {3} Exp. Points!", pkmn.name, msg_reduction, expGained))
      else
        pbDisplayPaused(_INTL("{1} {2} {3} Exp. Points!", pkmn.name, msg_reduction, expGained))
      end
    end
    curLevel = pkmn.level
    newLevel = growth_rate.level_from_exp(expFinal)
    if newLevel < curLevel
      debugInfo = "Levels: #{curLevel}->#{newLevel} | Exp: #{pkmn.exp}->#{expFinal} | gain: #{expGained}"
      raise _INTL("{1}'s new level is less than its\r\ncurrent level, which shouldn't happen.\r\n[Debug: {2}]",
                  pkmn.name, debugInfo)
    end
    # Give Exp
    if pkmn.shadowPokemon?
      if pkmn.heartStage <= 3
        pkmn.exp += expGained
        $stats.total_exp_gained += expGained
      end
      return
    end
    $stats.total_exp_gained += expGained
    tempExp1 = pkmn.exp
    battler = pbFindBattler(idxParty)
    loop do   # For each level gained in turn...
      # EXP Bar animation
      levelMinExp = growth_rate.minimum_exp_for_level(curLevel)
      levelMaxExp = growth_rate.minimum_exp_for_level(curLevel + 1)
      tempExp2 = (levelMaxExp < expFinal) ? levelMaxExp : expFinal
      pkmn.exp = tempExp2
      @scene.pbEXPBar(battler, levelMinExp, levelMaxExp, tempExp1, tempExp2)
      tempExp1 = tempExp2
      curLevel += 1
      if curLevel > newLevel
        # Gained all the Exp now, end the animation
        pkmn.calc_stats
        battler&.pbUpdate(false)
        @scene.pbRefreshOne(battler.index) if battler
        break
      end
      # Levelled up
      pbCommonAnimation("LevelUp", battler) if battler
      oldTotalHP = pkmn.totalhp
      oldAttack  = pkmn.attack
      oldDefense = pkmn.defense
      oldSpAtk   = pkmn.spatk
      oldSpDef   = pkmn.spdef
      oldSpeed   = pkmn.speed
      if battler&.pokemon
        battler.pokemon.changeHappiness("levelup")
      end
      pkmn.calc_stats
      battler&.pbUpdate(false)
      @scene.pbRefreshOne(battler.index) if battler
      pbDisplayPaused(_INTL("{1} grew to Lv. {2}!", pkmn.name, curLevel))
      @scene.pbLevelUp(pkmn, battler, oldTotalHP, oldAttack, oldDefense,
                       oldSpAtk, oldSpDef, oldSpeed)
      # Learn all moves learned at this level
      moveList = pkmn.getMoveList
      moveList.each { |m| pbLearnMove(idxParty, m[1]) if m[0] == curLevel }
    end
  end
end