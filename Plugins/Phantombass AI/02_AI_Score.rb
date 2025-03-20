class PBAI
  def self.log_score(msg)
    $score_msg += "\n" + msg
  end

  def self.display_score_messages
    echoln $score_msg
    $score_msg = ""
  end

  class ScoreHandler
    @@GeneralCode = []
    @@MoveCode = {}
    @@StatusCode = []
    @@DamagingCode = []
    @@FinalCode = []

    def self.add_status(&code)
      @@StatusCode << code
    end

    def self.add_final(&code)
      @@FinalCode << code
    end

    def self.add_damaging(&code)
      @@DamagingCode << code
    end

    def self.add(*moves, &code)
      if moves.size == 0
        @@GeneralCode << code
      else
        moves.each do |move|
          if move.is_a?(Symbol) # Specific move
            id = getConst(Battle::Move, move)
            raise "Invalid move #{move}" if id.nil? || id == 0
            @@MoveCode[id] = code
          elsif move.is_a?(String) # Function code
            @@MoveCode[move] = code
          end
        end
      end
    end

    def self.trigger(list, score, ai, user, target, move)
      return score if list.nil?
      list = [list] if !list.is_a?(Array)
      $test_trigger = true
      list.each do |code|
        next if code.nil?
        newscore = code.call(score, ai, user, target, move)
        score = newscore if newscore.is_a?(Numeric)
      end
      $test_trigger = false
      return score
    end

    def self.trigger_general(score, ai, user, target, move)
      return self.trigger(@@GeneralCode, score, ai, user, target, move)
    end

    def self.trigger_status_moves(score, ai, user, target, move)
      return self.trigger(@@StatusCode, score, ai, user, target, move)
    end

    def self.trigger_damaging_moves(score, ai, user, target, move)
      return self.trigger(@@DamagingCode, score, ai, user, target, move)
    end

    def self.trigger_final(score, ai, user, target, move)
      return self.trigger(@@FinalCode, score, ai, user, target, move)
    end

    def self.trigger_move(move, score, ai, user, target)
      id = move.id
      id = move.function if !@@MoveCode[id]
      return self.trigger(@@MoveCode[id], score, ai, user, target, move)
    end
  end
end


#=============================================================================#
#                                                                             #
# All Moves                                                                   #
#                                                                             #
#=============================================================================#

#Prefer sound moves if a substitute is up or if holding Throat Spray
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.soundMove?
  roles = []
    for i in user.roles
      roles.push(i)
    end
  dmg = user.get_calc_self(target, move)
  if target.effects[PBEffects::Substitute] > 0 && dmg >= target.hp
    score += 3
    PBAI.log_score("+ 3 for being able to kill behind a Substitute")
  end
  if user.hasActiveItem?(:THROATSPRAY)
    score += 2
    PBAI.log_score("+ 2 for activating Throat Spray")
    if user.has_role?([:SETUPSWEEPER,:WINCON,:SPECIALBREAKER])#.include?(roles)
      score += 1
      PBAI.log_score("+ 1 for being a setup mon or special breaker")
    end
  end
  next score
end

#Prefer status moves if you have Truant on your truant turn
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.statusMove?
  if user.hasActiveAbility?(:TRUANT) && user.effects[PBEffects::Truant]
    score += 10
    PBAI.log_score("+ 10 for using status moves on the Truant turn")
  end
  next score
end

# Prefer priority moves that deal enough damage to knock the target out.
# Use previous damage dealt to determine if it deals enough damage now,
# or make a rough estimate.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  # Apply this logic only for priority moves
  next if move.priority <= 0 || move.function == "MultiTurnAttackBideThenReturnDoubleDamage" # Bide
  next if ai.battle.field.terrain == :Psychic
  next if target.priority_blocking?
  next if move.statusMove?
  dmg = user.get_calc_self(target, move)
  if dmg >= target.battler.hp
    # We have the previous damage this user has done with this move.
    # Use the average of the previous damage dealt, and if it's more than the target's hp,
    # we can likely use this move to knock out the target.
    PBAI.log_score("+ 3 for priority move with damage (#{dmg}) >= target hp (#{target.battler.hp})")
    score += 3
  end
  if target.hp <= target.totalhp/4 && dmg >= target.hp && !$spam_block_flags[:no_priority_flag].include?(target)
    score += 1
    PBAI.log_score("+ 1 for attempting to kill the target with priority")
  end
  if user.has_role?(:FEAR) && target.hp == 1
    score += 10
    PBAI.log_score("+ 10 to kill with priority")
  end
  status = 0
  target.moves.each {|m| status += 1 if m.statusMove?}
  if status == 0 && move.function == "FailsIfTargetActed"
    score += 1
    PBAI.log_score("+ 1 because target has no status moves")
  end
  next score
end

PBAI::ScoreHandler.add do |score, ai, user, target, move|
  # Apply this logic only for priority moves
  next if move.priority <= 0
  next if !move.damagingMove?
  next if ai.battle.field.terrain == :Psychic
  next if target.priority_blocking?
  next if move.id == :FAKEOUT && user.turnCount > 0
  kill = 0
  target.moves.each {|m| kill += 1 if user.get_calc(target,m) >= user.hp}
  if kill > 0 && target.faster_than?(user)
    score += 9
    PBAI.log_score("+ 9 to get a last ditch hit off.")
  end
  next score
end

# Encourage using fixed-damage moves if the fixed damage is more than the target has HP
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.is_a?(Battle::Move::FixedDamageMove) || move.function == "OHKO" || move.function == "MultiTurnAttackBideThenReturnDoubleDamage"
  dmg = move.pbFixedDamage(user, target)
  dmg = 0 if dmg == nil
  if dmg >= target.hp
    score += 2
    PBAI.log_score("+ 2 for this move's fixed damage being enough to knock out the target")
  end
  next score
end

# Prefer moves that are usable while the user is asleep
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  # If the move is usable while asleep, and if the user won't wake up this turn
  # Kind of cheating, but insignificant. This way the user can choose a more powerful move instead
  if move.usableWhenAsleep?
    if user.asleep? && user.statusCount > 1
      score += 2
      PBAI.log_score("+ 2 for being able to use this move while asleep")
    else
      score -= 1
      PBAI.log_score("- 1 for this move will have no effect")
    end
  end
  next score
end


# Prefer moves that can thaw the user if the user is frozen
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  # If the user is frozen and the move thaws the user
  if user.frozen? && move.thawsUser?
    score += 2
    PBAI.log_score("+ 2 for being able to thaw the user")
  end
  next score
end

# Encourage using flinching moves if the user is faster
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.flinchingMove? && (user.faster_than?(target) || move.priority > 0)
    score += 1
    PBAI.log_score("+ 1 for being able to flinch the target")
  end
  next score
end


# Discourage using a multi-hit physical move if the target has an item or ability
# that will damage the user on each contact.
# Also slightly discourages physical moves if the target has a bad ability in general.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.pbContactMove?(user)
    if user.discourage_making_contact_with?(target)
      if move.multiHitMove?
        score -= 6
        PBAI.log_score("- 6 for the target has an item or ability that activates on each contact")
      else
        score -= 3
        PBAI.log_score("- 3 for the target has an item or ability that activates on contact")
      end
    end
  end
  next score
end

#Remove a move as a possible choice if not the one Choice locked into
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if user.effects[PBEffects::ChoiceBand]
    choiced_move = user.effects[PBEffects::ChoiceBand]
    if choiced_move == move.id
      score += 5
      PBAI.log_score("+ 5 for being Choice locked")
      if !user.can_switch?
        score += 10
        PBAI.log_score("+ 10 for being Choice locked and unable to switch")
      end
    else
      score -= 20
      PBAI.log_score("- 20 for being Choice locked")
    end
  end
  next score
end

#=============================================================================#
#                                                                             #
# Damaging Moves                                                              #
#                                                                             #
#=============================================================================#


# Discourage using damaging moves if the target is semi-invulnerable and slower,
# and encourage using damaging moves if they can break through the semi-invulnerability
# (e.g. prefer earthquake when target is underground)
PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  # Target is semi-invulnerable
  if target.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0
    encourage = false
    discourage = false
    # User will hit first while target is still semi-invulnerable.
    # If this move will do extra damage because the target is semi-invulnerable,
    # encourage using this move. If not, discourage using it.
    if user.faster_than?(target)
      if target.in_two_turn_attack?("TwoTurnAttackInvulnerableInSky", "TwoTurnAttackInvulnerableInSkyParalyzeTarget", "TwoTurnAttackInvulnerableInSkyTargetCannotAct") # Fly, Bounce, Sky Drop
        encourage = move.hitsFlyingTargets?
        discourage = !encourage
      elsif target.in_two_turn_attack?("TwoTurnAttackInvulnerableUnderground") # Dig
        # Do not encourage using Fissure, even though it can hit digging targets, because it's an OHKO move
        encourage = move.hitsDiggingTargets? && move.function != "OHKOHitsUndergroundTarget"
        discourage = !encourage
      elsif target.in_two_turn_attack?("TwoTurnAttackInvulnerableUnderwater") # Dive
        encourage = move.hitsDivingTargets?
        discourage = !encourage
      else
        discourage = true
      end
    end
    # If the user has No Guard
    if user.has_ability?(:NOGUARD)
      # Then any move would be able to hit the target, meaning this move wouldn't be anything special.
      encourage = false
      discourage = false
    end
    if encourage
      score += 1
      PBAI.log_score("+ 1 for being able to hit through a semi-invulnerable state")
    elsif discourage
      score -= 2
      PBAI.log_score("- 2 for not being able to hit target because of semi-invulnerability")
    end
  end
  next score
end


# Lower the score of multi-turn moves, because they likely have quite high power and thus score.
PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  next if user.hasActiveAbility?(:IMPATIENT)
  if !user.has_item?(:POWERHERB) && (move.chargingTurnMove? || move.function == "AttackAndSkipNextTurn") # Hyper Beam
    score -= 3
    PBAI.log_score("- 3 for requiring a charging turn")
  end
  next score
end

# Discourage using physical moves when the user is burned
PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  if user.burned?
    if move.physicalMove? && move.function != "DoublePowerIfUserPoisonedBurnedParalyzed"
      score -= 1
      PBAI.log_score("- 1 for being a physical move and being burned")
    end
    if move.physicalMove? && user.hasActiveAbility?(:GUTS)
      if move.function != "DoublePowerIfUserPoisonedBurnedParalyzed"
        score += 3
        PBAI.log_score("+ 3 for Guts Facade")
      else
        score += 2
        PBAI.log_score("+ 2 to capitalize on Guts")
      end
    end
  end
  next score
end


# Encourage high-critical hit rate moves, or damaging moves in general
# if Laser Focus or Focus Energy has been used
PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  next if !move.pbCouldBeCritical?(user.battler, target.battler)
  if move.highCriticalRate? || user.effects[PBEffects::LaserFocus] > 0 ||
     user.effects[PBEffects::FocusEnergy] > 0
    score += 1
    PBAI.log_score("+ 1 for having a high critical-hit rate")
  end
  next score
end


# Discourage recoil moves if they would knock the user out
PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  if move.is_a?(Battle::Move::RecoilMove) && !user.hasActiveAbility?([:ROCKHEAD,:MAGICGUARD])
    dmg = move.pbRecoilDamage(user.battler, target.battler)
    if dmg >= user.hp
      score -= 1
      PBAI.log_score("- 1 for the recoil will knock the user out")
    end
  end
  next score
end

# Encourage using offense boosting setup moves if neither of us can kill.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !PBAI::AI_Move.offense_setup_move?(move)
  if user.set_up_max?(move) || ($spam_block_flags[:haze_flag].include?(target) && move.statusMove?)
    score -= 15
    PBAI.log_score("- 15 to discourage use")
    next score
  end
  ded = 0
  me_ded = 0
  for i in user.moves
    next if i.statusMove?
    ded += 1 if user.get_calc_self(target,i) >= target.hp
  end
  for j in target.moves
    next if j.statusMove?
    me_ded += 1 if user.get_calc(target,j) >= user.hp/2
  end
  if ded == 0 && me_ded == 0 && user.set_up_score < 2
    add = 9 - user.set_up_score
    score += add
    PBAI.log_score("+ #{add} to encourage setup")
  end
  next score
end

# Encourage using defense boosting setup moves if neither of us can kill.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !PBAI::AI_Move.defense_setup_move?(move)
  if user.set_up_max?(move) || ($spam_block_flags[:haze_flag].include?(target) && move.statusMove?)
    score -= 15
    PBAI.log_score("- 15 to discourage use")
    next score
  end
  ded = 0
  me_ded = 0
  for i in user.moves
    next if i.statusMove?
    ded += 1 if user.get_calc_self(target,i) >= target.hp
  end
  for j in target.moves
    next if j.statusMove?
    me_ded += 1 if user.get_calc(target,j) >= user.hp/2
  end
  if ded == 0 && me_ded == 0 && user.set_up_score < 2
    add = 9 - user.set_up_score
    score += add
    PBAI.log_score("+ #{add} to encourage setup")
  end
  next score
end

# Encourage using speed boosting setup moves if neither of us can kill.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !PBAI::AI_Move.speed_setup_move?(move)
  if user.set_up_max?(move) || ($spam_block_flags[:haze_flag].include?(target) && move.statusMove?)
    score -= 15
    PBAI.log_score("- 15 to discourage use")
    next score
  end
  ded = 0
  me_ded = 0
  for i in user.moves
    next if i.statusMove?
    ded += 1 if user.get_calc_self(target,i) >= target.hp
  end
  for j in target.moves
    next if j.statusMove?
    me_ded += 1 if user.get_calc(target,j) >= user.hp/2
  end
  if ded == 0 && me_ded == 0 && target.faster_than?(user)
    add = 9
    score += add
    PBAI.log_score("+ #{add} to encourage setup")
  end
  next score
end

# Status-inducing move handling.
PBAI::ScoreHandler.add_status do |score, ai, user, target, move|
  next if !PBAI::AI_Move.status_condition_move?(move)
  if ai.battle.field.terrain == :Misty || target.hasActiveAbility?(:HOPEFULTOLL)
    score -= 15
    PBAI.log_score("- 15 to prevent use")
    next score
  end
  ability_list = [:MAGICBOUNCE,:GOODASGOLD,:PURIFYINGSALT,:GUTS,:COMATOSE,:FAIRYBUBBLE,:MARVELSCALE,:QUICKFEET]
  can_status = true
  case move.id
  when :WILLOWISP
    flag = :burn
    ability_list = [:MAGICBOUNCE,:GOODASGOLD,:PURIFYINGSALT,:WATERVEIL,:WATERBUBBLE,:GUTS,:COMATOSE,:FAIRYBUBBLE,:FLAREBOOST,:MARVELSCALE,:WELLBAKEDBODY,:STEAMENGINE,:FLASHFIRE,:QUICKFEET]
    can_status = target.can_burn?(user,move)
  when :DEEPFREEZE
    flag = :frostbite
    ability_list = [:MAGICBOUNCE,:GOODASGOLD,:PURIFYINGSALT,:MAGMAARMOR,:GUTS,:COMATOSE,:FAIRYBUBBLE,:MARVELSCALE,:QUICKFEET]
    can_status = target.can_freeze?(user,move)
  when :THUNDERWAVE,:GLARE,:STUNSPORE
    flag = :paralysis
    ability_list = [:MAGICBOUNCE,:GOODASGOLD,:PURIFYINGSALT,:LIMBER,:GUTS,:COMATOSE,:FAIRYBUBBLE,:MARVELSCALE,:QUICKFEET]
    can_status = target.can_paralyze?(user,move)
  when :POISONGAS,:TOXIC,:POISONPOWDER,:TOXICTHREAD
    flag = :poison
    ability_list = [:MAGICBOUNCE,:GOODASGOLD,:PURIFYINGSALT,:IMMUNITY,:TOXICBOOST,:POISONHEAL,:GUTS,:QUICKFEET,:COMATOSE,:FAIRYBUBBLE,:MARVELSCALE,:PASTELVEIL,:QUICKFEET]
    can_status = target.can_poison?(user,move)
  when :SPORE,:SING,:SLEEPPOWDER,:YAWN,:HYPNOSIS,:DARKVOID
    flag = :sleep
    ability_list = [:MAGICBOUNCE,:GOODASGOLD,:PURIFYINGSALT,:INSOMNIA,:SWEETVEIL,:VITALSPIRIT,:FAIRYBUBBLE,:GUTS,:COMATOSE,:MARVELSCALE,:QUICKFEET]
    can_status = target.can_sleep?(user,move)
  else
    next score
  end
  prankster = user.hasActiveAbility?(:PRANKSTER) && target.pbHasType?(:DARK)
  if PBAI.threat_score(user,target) > 0 && $threat_flags[flag] == true && !prankster
    score += PBAI.threat_score(user,target)
    PBAI.log_score("+ #{PBAI.threat_score(user,target)} to add extra incentive to target this.")
  end
  if (target.hasActiveAbility?(ability_list) || !can_status || user.hasActiveAbility?(:PRANKSTER) && target.pbHasType?(:DARK))
    score -= 10
    PBAI.log_score("- 10 for not being able to status")
  end
  if (user.pbHasMove?(:HEX) || user.pbHasMove?(:BITTERMALICE)|| user.pbHasMove?(:BARBBARRAGE)|| user.pbHasMove?(:INFERNALPARADE)) && can_status
      score += 2
      PBAI.log_score("+ 2 to set up for Hex-style spam")
    end
  if (user.target_is_immune?(move,target) || !can_status)
    score -= 10
    PBAI.log_score("- 10 for being immune to status or is already statused")
  end
  if flag == :paralysis
    if user.has_role?(:SPEEDCONTROL)
      score += 1
      PBAI.log_score("+ 1")
    end
  end
  if flag == :poison
    if user.has_role?(:TOXICSTALLER)
      score += 2
      PBAI.log_score("+ 2 for being a Toxic Staller")
    end
  end
  if target.hasActiveAbility?(:HOPEFULTOLL)
    PBAI.log_score("- #{score} to encourage other moves since this will be removed at the end of the turn.")
    score = 0
  end
  next score
end



#=============================================================================#
#                                                                             #
# Move-specific                                                               #
#                                                                             #
#=============================================================================#


# Facade
PBAI::ScoreHandler.add("DoublePowerIfUserPoisonedBurnedParalyzed") do |score, ai, user, target, move|
  if user.burned? || user.poisoned? || user.paralyzed? || user.frozen?
    score += 2
    PBAI.log_score("+ 2 for doing more damage with a status condition")
  end
  next score
end

# Assist
PBAI::ScoreHandler.add("UseRandomMoveFromUserParty") do |score, ai, user, target, move|
  if user.choice_locked?
    score += 12
    PBAI.log_score("+ 12 to hopefully bypass attempting to attack with something else")
  end
  next score
end

# Aromatherapy, Heal Bell
PBAI::ScoreHandler.add("CureUserPartyStatus") do |score, ai, user, target, move|
  count = 0
  user.side.battlers.each do |proj|
    next if proj.nil?
    # + 80 for each active battler with a status condition
    count += 2.0 if proj.has_non_volatile_status?
  end
  user.side.party.each do |proj|
    next if proj.battler # Skip battlers
    # Inactive party members do not have a battler attached,
    # so we can't use has_non_volatile_status?
    count += 1.0 if proj.pokemon.status > 0
    # + 40 for each inactive pokemon with a status condition in the party
  end
  if count != 0
    add = count
    score += add
    PBAI.log_score("+ #{add} for curing status condition(s)")
  else
    score -= 2
    PBAI.log_score("- 2 for not curing any status conditions")
  end
  next score
end


# Psycho Shift
PBAI::ScoreHandler.add("GiveUserStatusToTarget") do |score, ai, user, target, move|
  if user.has_non_volatile_status?
    # And the target doesn't have any status conditions
    if !target.has_non_volatile_status?
      # Then we can transfer our status condition
      transferrable = true
      transferrable = false if user.burned? && !target.can_burn?(user, move)
      transferrable = false if user.poisoned? && !target.can_poison?(user, move)
      transferrable = false if user.paralyzed? && !target.can_paralyze?(user, move)
      transferrable = false if user.asleep? && !target.can_sleep?(user, move)
      transferrable = false if user.frozen? && !target.can_freeze?(user, move)
      if transferrable
        score += 5
        PBAI.log_score("+ 5 for being able to pass on our status condition")
        if user.burned? && target.is_physical_attacker?
          score += 2
          PBAI.log_score("+ 2 for being able to burn the physical-attacking target")
        end
        if user.frozen? && target.is_special_attacker?
          score += 2
          PBAI.log_score("+ 2 for being able to frostbite the special-attacking target")
        end
      end
    end
  else
    score -= 2
    PBAI.log_score("- 2 for not having a transferrable status condition")
  end
  next score
end


# Refresh
PBAI::ScoreHandler.add("CureUserBurnPoisonParalysis") do |score, ai, user, target, move|
  if user.burned? || user.poisoned? || user.paralyzed?
    score += 2
    PBAI.log_score("+ 2 for being able to cure our status condition")
  end
  next score
end


# Rest
PBAI::ScoreHandler.add("HealUserFullyAndFallAsleep") do |score, ai, user, target, move|
  factor = 1 - user.hp / user.totalhp.to_f
  deciding_factor = user.faster_than?(target) ? (factor <= 0.5) : (factor <= 0.67)
  if user.flags[:will_be_healed]
    score -= 3
    PBAI.log_score("- 3 for the user will already be healed by something")
  elsif factor == 0
    score -= 9
    PBAI.log_score("- 9 because we are at full HP")
  elsif deciding_factor && user.target_highest_move_damage(target)
    # Not at full hp
    if user.can_sleep?(user, move, true)
      add = (1/factor).floor
      score += add
      PBAI.log_score("+ #{add} for we have lost some hp")
    else
      score -= 1
      PBAI.log_score("- 1 for the move will fail")
    end
  end
  next score
end

# Pain Split
PBAI::ScoreHandler.add("UserTargetAverageHP") do |score, ai, user, target, move|
  factor = ((target.hp + user.hp)/2).floor
  if factor <= 0
    PBAI.log_score("- 10 because we will lose HP")
    score -= 10
    next score
  end
  hp_after = factor + user.hp
  perc = (user.totalhp/factor).floor
  diff = user.hp - user.target_highest_move_damage(target)
  if user.flags[:will_be_healed]
    score -= 3
    PBAI.log_score("- 3 for the user will already be healed by something")
    next score
  end
  if hp_after > user.target_highest_move_damage(target) && user.faster_than?(target)
    score += perc
    PBAI.log_score("+ #{perc} to encourage use")
  elsif diff > 0 && (hp_after > user.target_highest_move_damage(target)) && !user.faster_than?(target)
    score += perc
    PBAI.log_score("+ #{perc} to encourage use")
  else
    score -= 2
    PBAI.log_score("- 2 because we will not outlast the damage taken")
  end
  next score
end


# Toxic Thread
PBAI::ScoreHandler.add("PoisonTargetLowerTargetSpeed1") do |score, ai, user, target, move|
  if !target.poisoned? && target.can_poison?(user, move)
    score += 1
    PBAI.log_score("+ 1 for being able to poison the target")
  end
  if target.battler.pbCanLowerStatStage?(:SPEED, user, move) &&
     target.faster_than?(user)
    score += 1
    PBAI.log_score("+ 1 for being able to lower target speed")
  end
  next score
end


# Dark Void
PBAI::ScoreHandler.add("SleepTargetIfUserDarkrai") do |score, ai, user, target, move|
  if !target.asleep? && target.can_sleep?(user, move) && user.hasActiveAbility?(:BADDREAMS)
    score += 3
    PBAI.log_score("+ 3 for damaging the target with Nightmare if it is asleep")
  end
  next score
end


# Yawn
PBAI::ScoreHandler.add("SleepTargetNextTurn") do |score, ai, user, target, move|
  if !target.has_non_volatile_status? && target.effects[PBEffects::Yawn] == 0
    score += 2
    PBAI.log_score("+ 2 for putting the target to sleep")
  end
  next score
end


# Stealth Rock, Spikes, Toxic Spikes, Sticky Web
PBAI::ScoreHandler.add("AddSpikesToFoeSide", "AddToxicSpikesToFoeSide", "AddStealthRocksToFoeSide", "AddStickyWebToFoeSide") do |score, ai, user, target, move|
  ded = 0
  mov = []
  target.moves.each do |m|
    next if m.statusMove?
    PBAI.log_score("Damage from #{m.name}: #{user.get_calc(target,m)}/#{user.hp}")
    if user.get_calc(target, m) >= user.hp
      ded += 1
      mov.push(m)
    end
  end
  if ded > 0
    PBAI.log_score("Skip scoring for hazards because #{target.pokemon.name} does #{user.get_calc(target,mov[0])} damage with #{mov[0].name}")
    next
  end
  next if user.opposing_side.party.size == 1
  if move.function == "AddSpikesToFoeSide" && user.opposing_side.effects[PBEffects::Spikes] >= 3 ||
     move.function == "AddToxicSpikesToFoeSide" && user.opposing_side.effects[PBEffects::ToxicSpikes] >= 2 ||
     move.function == "AddStealthRocksToFoeSide" && user.opposing_side.effects[PBEffects::StealthRock] ||
     move.function == "AddStickyWebToFoeSide" && user.opposing_side.effects[PBEffects::StickyWeb]
    score -= 20
    PBAI.log_score("- 20 for the opposing side already has max hazards")
  else
    inactive = user.opposing_side.party.size - user.opposing_side.battlers.compact.size
    add = inactive
    if inactive > 0
      add += (3 - user.opposing_side.effects[PBEffects::Spikes]) if move.function == "AddSpikesToFoeSide"
      add += (2 - user.opposing_side.effects[PBEffects::ToxicSpikes]) if move.function == "AddToxicSpikesToFoeSide"
      add += 3 if !user.opposing_side.effects[PBEffects::StealthRock] && move.function == "AddStealthRocksToFoeSide"
      add += 3 if !user.opposing_side.effects[PBEffects::StickyWeb] && move.function == "AddStickyWebToFoeSide"
      score += add
      PBAI.log_score("+ #{add} for there are #{inactive} pokemon to be sent out at some point")
    end
    if ai.battle.pbSideSize(0) == 2 && user.opposing_side.effects[PBEffects::ToxicSpikes] == 1
      score -= 12
      PBAI.log_score("- 12 to prevent bugs and create more balance")
    end
    if user.has_role?(:LEAD)
      score += 5
      PBAI.log_score("+ 5 for being a Hazard Lead")
    end
    if user.has_role?(:SPEEDCONTROL) && move.function == "AddStickyWebToFoeSide" && ai.battle.field.effects[PBEffects::TrickRoom] != 0
      score += 1
      PBAI.log_score("+ 1 to lower speed")
    end
    removal = 0
    target.moves.each {|move| removal += 1 if [:RAPIDSPIN,:MORTALSPIN,:DEFOG,:TIDYUP].include?(move.id)}
    if removal > 0
      score -= 20
      PBAI.log_score("- 20 because the target has removal")
    end
  end
  party = ai.battle.pbParty(user.index)
  able = 0
  party.each {|mon| able += 1 if mon && !mon.fainted? && !mon.egg?}
  if able == 1
    score = 0
    PBAI.log_score("* 0 because setting hazards late is pointless.")
  end
  next score
end


# Disable
PBAI::ScoreHandler.add("DisableTargetLastMoveUsed") do |score, ai, user, target, move|
  # Already disabled one of the target's moves
  if target.effects[PBEffects::Disable] > 1
    score -= 3
    PBAI.log_score("- 30 for the target is already disabled")
  elsif target.flags[:will_be_disabled] == true
    score -= 3
    PBAI.log_score("- 30 for the target is being disabled by another battler")
  else
    # Get previous damage done by the target
    prevDmg = target.get_damage_by_user(user)
    if prevDmg.size > 0 && prevDmg != 0
      lastDmg = prevDmg[-1]
      # If the last move did more than 50% damage and the target was faster,
      # we can't disable the move in time thus using Disable is pointless.
      if user.is_healing_pointless?(0.5) && target.faster_than?(user)
        score -= 3
        PBAI.log_score("- 3 for the target move is too strong and the target is faster")
      else
        add = 3
        score += add
        PBAI.log_score("+ #{add} for we disable a strong move")
      end
    else
      # Target hasn't used a damaging move yet
      score -= 3
      PBAI.log_score("- 3 for the target hasn't used a damaging move yet.")
    end
  end
  next score
end

#Explosion, Misty Explosion
PBAI::ScoreHandler.add("UserFaintsExplosive","UserFaintsPowersUpInMistyTerrainExplosive") do |score, ai, user, target, move|
  if !user.can_switch?
    score -= 10
    PBAI.log_score("- 10 to prevent killing the last mon")
  end
  next score
end


# Counter
PBAI::ScoreHandler.add("CounterPhysicalDamage") do |score, ai, user, target, move|
  expect = false
  expect = true if target.is_physical_attacker? && !target.is_healing_necessary?(0.5)
  prevDmg = user.get_damage_by_user(target)
  if prevDmg.size > 0 && prevDmg != 0
    lastDmg = prevDmg[-1]
    lastMove = lastDmg[1]
    last = GameData::Move.get(lastMove).physical?
    expect = true if last
  end
  # If we can reasonably expect the target to use a physical move
  if expect
    score += 6
    PBAI.log_score("+ 6 for we can reasonably expect the target to use a physical move")
  end
  next score
end

# Mirror Coat
PBAI::ScoreHandler.add("CounterSpecialDamage") do |score, ai, user, target, move|
  expect = false
  expect = true if target.is_special_attacker? && !target.is_healing_necessary?(0.5)
  prevDmg = user.get_damage_by_user(target)
  if prevDmg.size > 0 && prevDmg != 0
    lastDmg = prevDmg[-1]
    lastMove = lastDmg[1]
    last = GameData::Move.get(lastMove).special?
    expect = true if last
  end
  # If we can reasonably expect the target to use a special move
  if expect
    score += 6
    PBAI.log_score("+ 6 for we can reasonably expect the target to use a special move")
  end
  next score
end

# Leech Seed
PBAI::ScoreHandler.add("StartLeechSeedTarget") do |score, ai, user, target, move|
  if target.has_type?(:GRASS) || target.effects[PBEffects::LeechSeed] != 0
    score -= 9
    PBAI.log_score("- 9")
  end
  if !user.underdog?(target) && !target.has_type?(:GRASS) && target.effects[PBEffects::LeechSeed] == 0
    score += 6
    PBAI.log_score("+ 6 for sapping hp from the target")
    if user.has_role?([:PHYSICALWALL,:SPECIALWALL,:DEFENSIVEPIVOT])#.include?(user.role)
      score += 3
      PBAI.log_score("+ 3")
    end
  end
  next score
end


# Dream Eater
PBAI::ScoreHandler.add("HealUserByHalfOfDamageDoneIfTargetAsleep") do |score, ai, user, target, move|
  if target.asleep?
    add = 2
    score += add
    PBAI.log_score("+ #{add} for hp gained")
  else
    score -= 3
    PBAI.log_score("- 3 for the move will fail")
  end
  next score
end


# Heal Pulse
PBAI::ScoreHandler.add("HealTargetHalfOfTotalHP","HealAllyOrDamageFoe") do |score, ai, user, target, move|
  # If the target is an ally
  ally = false
  target.battler.eachAlly do |battler|
    ally = true if battler == user.battler
  end
  if ally# && !target.will_already_be_healed?
    factor = 1 - target.hp / target.totalhp.to_f
    # At full hp, factor is 0 (thus not encouraging this move)
    # At half hp, factor is 0.5 (thus slightly encouraging this move)
    # At 1 hp, factor is about 1.0 (thus encouraging this move)
    if target.flags[:will_be_healed]
      score -= 3
      PBAI.log_score("- 3 for the target will already be healed by something")
    elsif factor != 0
      if target.is_healing_pointless?(0.5)
        score -= 1
        PBAI.log_score("- 1 for the target will take more damage than we can heal if the opponent repeats their move")
      elsif target.is_healing_necessary?(0.5)
        add = 3
        score += add
        PBAI.log_score("+ #{add} for the target will likely die without healing")
      else
        add = 2
        score += add
        PBAI.log_score("+ #{add} for the target has lost some hp")
      end
    else
      score -= 3
      PBAI.log_score("- 3 for the target is at full hp")
    end
  else
    score -= 3
    PBAI.log_score("- 3 for the target is not an ally")
  end
  next score
end


# Whirlwind, Roar, Circle Throw, Dragon Tail, U-Turn, Volt Switch
PBAI::ScoreHandler.add("SwitchOutTargetStatusMove", "SwitchOutTargetDamagingMove", "SwitchOutUserDamagingMove","LowerTargetAtkSpAtk1SwitchOutUser","SwitchOutUserStartHailWeather") do |score, ai, user, target, move|
  if user.bad_against?(target) && !target.has_ability?(:SUCTIONCUPS) && !target.effects[PBEffects::Ingrain] && !["SwitchOutUserDamagingMove","LowerTargetAtkSpAtk1SwitchOutUser","SwitchOutUserStartHailWeather"].include?(move.function)
    score += 1
    PBAI.log_score("+ 1 for forcing our target to switch and we're bad against our target")
    o_boost = 0
    faint = 0
    GameData::Stat.each_battle { |s| o_boost += target.stages[s] if target.stages[s] != nil}
    target.side.party.each do |pkmn|
      faint +=1 if pkmn.fainted?
    end
    if o_boost > 0 && faint > 1
      score += 3
      PBAI.log_score("+ 3 for forcing out a set up mon")
    end
    if user.has_role?(:PHAZER)
      score += 2
      PBAI.log_score("+ 2 for being a Phazer")
    end
  elsif ["SwitchOutUserDamagingMove","LowerTargetAtkSpAtk1SwitchOutUser","SwitchOutUserStartHailWeather"].include?(move.function)
    roles = []
    for i in user.roles
      roles.push(i)
    end
    if user.has_role?([:DEFENSIVEPIVOT,:OFFENSIVEPIVOT,:LEAD])#.include?(roles)
      score += 1 if user.can_switch?
      PBAI.log_score("+ 1 for being a Pivot or Lead")
    end
    boosts = 0
    o_boost = 0
    GameData::Stat.each_battle { |s| boosts += user.stages[s] if user.stages[s] != nil}
    boosts *= -1
    score += boosts
    GameData::Stat.each_battle { |s| o_boost += target.stages[s] if target.stages[s] != nil}
    if boosts > 0
      PBAI.log_score("+ #{boosts} for switching to reset lowered stats")
    elsif boosts < 0
      PBAI.log_score("#{boosts} for not wasting boosted stats")
    end
    if o_boost > 0  
      score -= 2
      PBAI.log_score("- 2 to prevent switching out on setup mon to get free switch later")
    end
    if user.trapped? && user.can_switch?
      score += 1
      PBAI.log_score("+ 1 for escaping a trap")
    end
    if target.faster_than?(user) && !user.bad_against?(target)
      score += 1
      PBAI.log_score("+ 1 for making a more favorable matchup")
    end
    dead = 0
    target.moves.each {|move| dead += 1 if !move.statusMove? && user.get_calc(target,move) >= user.hp}
    if user.bad_against?(target) && target.faster_than?(user) && dead == 0
      score += 5
      PBAI.log_score("+ 5 for gaining switch initiative against a bad matchup")
    end
    if user.bad_against?(target) && user.faster_than?(target)
      score += 4
      PBAI.log_score("+ 4 for switching against a bad matchup")
    end
    if (user.effects[PBEffects::Substitute] > 0 || user.hp <= user.totalhp/2) && move.function == "UserMakeSubstituteSwitchOut"
      score - 20
      PBAI.log_score("- 20 because we already have a Substitute")
    end
    kill = 0
    for i in user.moves
      kill += 1 if user.get_calc_self(target,i) >= target.hp
    end
    fnt = 0
    user.side.party.each do |pkmn|
      fnt +=1 if pkmn.fainted?
    end
    if fnt == (user.side.party.length - 1)
      score -= 20
      PBAI.log_score("- 20 to prevent spamming when no switches are available")
    end
    diff = user.side.party.length - fnt
    if user.predict_switch?(target) && kill == 0 && diff > 1 && !$spam_block_triggered
      score += 1
      PBAI.log_score("+ 1 for predicting the target to switch, being unable to kill, and having something to switch to")
    end
    if user.hasActiveAbility?(:ZEROTOHERO) && user.form == 0
      score += 9
      PBAI.log_score("+ 9 to activate ability")
    end
  end
  if user.set_up_score <= -2 && user.can_switch?
    score += 9
    PBAI.log_score("+ 9 to encourage switching out lowered stats")
  end
  if target.hasActiveAbility?([:MAGICBOUNCE,:GOODASGOLD]) && move.statusMove?
    score -= 20
    PBAI.log_score("- 20 because move will fail")
  end
  next score
end

# Shed Tail
PBAI::ScoreHandler.add("UserMakeSubstituteSwitchOut") do |score, ai, user, target, move|
  roles = []
  for i in user.roles
    roles.push(i)
  end
  if user.has_role?([:DEFENSIVEPIVOT,:OFFENSIVEPIVOT,:LEAD])#.include?(roles)
    score += 1
    PBAI.log_score("+ 1 for being a Lead or Pivot")
  end
  if user.trapped? && user.can_switch?
    score += 2
    PBAI.log_score("+ 2 for escaping a trap")
  end
  if target.faster_than?(user)
    score += 2
    PBAI.log_score("+ 2 for making a more favorable matchup")
  end
  if user.bad_against?(target) && user.faster_than?(target)
    score += 1
    PBAI.log_score("+ 1 for switching against a bad matchup")
  end
  if user.effects[PBEffects::Substitute] > 0 || user.hp < user.totalhp/2
    score - 10
    PBAI.log_score("- 20 because we cannot make a Substitute")
  end
  if !user.can_switch?
    score -= 20
    PBAI.log_score("- 20 because we cannot pass a Substitute")
  end
  kill = 0
  for i in user.moves
    kill += 1 if user.get_calc_self(target,i) >= target.hp
  end
  fnt = 0
  user.side.party.each do |pkmn|
    fnt +=1 if pkmn.fainted?
  end
  diff = user.side.party.length - fnt
  if user.predict_switch?(target) && kill == 0 && diff > 1
    score += 1
    PBAI.log_score("+ 1 for predicting the target to switch, being unable to kill, and having something to switch to")
  end
  boosts = 0
  GameData::Stat.each_battle { |s| boosts += user.stages[s] if user.stages[s] != nil}
  boosts *= -2
  score += boosts
  if boosts > 0
    PBAI.log_score("+ #{boosts} for switching to reset lowered stats")
  elsif boosts < 0
    PBAI.log_score("#{boosts} for not wasting boosted stats")
  end
  next score
end

# Anchor Shot, Block, Mean Look, Spider Web, Spirit Shackle, Thousand Waves
PBAI::ScoreHandler.add("TrapTargetInBattle") do |score, ai, user, target, move|
  if target.bad_against?(user) && !target.has_type?(:GHOST)
    score += 2
    PBAI.log_score("+ 2 for locking our target in battle with us and they're bad against us")
    if user.has_role?(:TRAPPER)
      score += 2
      PBAI.log_score("+ 2 for being a Trapper role")
    end
  end
  next score
end

# Recover, Slack Off, Soft-Boiled, Heal Order, Milk Drink, Roost, Wish
PBAI::ScoreHandler.add("HealUserHalfOfTotalHP", "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn", "HealUserPositionNextTurn") do |score, ai, user, target, move|
  factor = 1 - user.hp / user.totalhp.to_f
  # At full hp, factor is 0 (thus not encouraging this move)
  # At half hp, factor is 0.5 (thus slightly encouraging this move)
  # At 1 hp, factor is about 1.0 (thus encouraging this move)
  roles = []
    for i in user.roles
      roles.push(i)
    end
  if user.flags[:will_be_healed] && ai.battle.pbSideSize(0) == 2
    score = 0
    PBAI.log_score("* 0 for the user will already be healed by something")
  elsif factor != 0
    if user.is_healing_pointless?(0.50)
      score -= 20
      PBAI.log_score("- 20 for we will take more damage than we can heal if the target repeats their move")
    elsif user.is_healing_necessary?(0.50)
      add = 6
      score += add
      PBAI.log_score("+ #{add} for we will likely die without healing")
      if user.has_role?([:PHYSICALWALL,:SPECIALWALL,:TOXICSTALLER,:DEFENSIVEPIVOT,:OFFENSIVEPIVOT,:CLERIC])#.include?(roles)
        score += 1
        PBAI.log_score("+ 1 for being a defensive role")
      end
    else
      plus = (user.hp/user.totalhp)
      plus = 1 if plus == 0
      add = (1/plus).floor
      score += add
      PBAI.log_score("+ #{add} for we have lost some hp")
      if user.has_role?([:PHYSICALWALL,:SPECIALWALL,:TOXICSTALLER,:DEFENSIVEPIVOT,:OFFENSIVEPIVOT,:CLERIC])#.include?(roles)
        score += 1
        PBAI.log_score("+ 1 for being a defensive role")
      end
    end
  else
    score -= 20
    PBAI.log_score("- 20 for we are at full hp")
  end
  score += 1 if user.has_role?(:CLERIC) && move.function == "HealUserPositionNextTurn"
  PBAI.log_score("+ 1  and potentially passing a Wish") if user.has_role?(:CLERIC) && move.function == "HealUserPositionNextTurn"
  score += 1 if user.predict_switch?(target) && user.hp < user.totalhp/2
  PBAI.log_score("+ 1 for predicting the switch") if user.predict_switch?(target)
  fnt = 0
  user.side.party.each do |pkmn|
    fnt +=1 if pkmn.fainted?
  end
  if fnt == 5
    score -= 20
    PBAI.log_score("- 20 to prevent recovery spam as last mon")
  end
  next score
end


# Moonlight, Morning Sun, Synthesis
PBAI::ScoreHandler.add("HealUserDependingOnWeather") do |score, ai, user, target, move|
  heal_factor = 0.5
  case ai.battle.pbWeather
  when :Sun, :HarshSun
    heal_factor = 2.0 / 3.0
  when :None, :StrongWinds
    heal_factor = 0.5
  else
    heal_factor = 0.25
  end
  effi_factor = 1.0
  effi_factor = 0.5 if heal_factor == 0.25
  factor = 1 - user.hp / user.totalhp.to_f
  # At full hp, factor is 0 (thus not encouraging this move)
  # At half hp, factor is 0.5 (thus slightly encouraging this move)
  # At 1 hp, factor is about 1.0 (thus encouraging this move)
  if user.flags[:will_be_healed]
    score -= 1
    PBAI.log_score("- 1 for the user will already be healed by something")
  elsif factor != 0
    if user.is_healing_pointless?(heal_factor)
      score -= 1
      PBAI.log_score("- 1 for we will take more damage than we can heal if the target repeats their move")
    elsif user.is_healing_necessary?(heal_factor)
      add = 3
      score += add
      PBAI.log_score("+ #{add} for we will likely die without healing")
    else
      add = 2
      score += add
      PBAI.log_score("+ #{add} for we have lost some hp")
    end
  else
    score -= 3
    PBAI.log_score("- 3 for we are at full hp")
  end
  next score
end

# Shore Up
PBAI::ScoreHandler.add("HealUserDependingOnSandstorm") do |score, ai, user, target, move|
  heal_factor = 0.5
  if ai.battle.pbWeather == :Sandstorm
    heal_factor = 2.0 / 3.0
  end
  factor = 1 - user.hp / user.totalhp.to_f
  # At full hp, factor is 0 (thus not encouraging this move)
  # At half hp, factor is 0.5 (thus slightly encouraging this move)
  # At 1 hp, factor is about 1.0 (thus encouraging this move)
  if user.flags[:will_be_healed] && ai.battle.pbSideSize(0) == 2
    score -= 3
    PBAI.log_score("- 30 for the user will already be healed by something")
  elsif factor != 0
    if user.is_healing_pointless?(heal_factor)
      score -= 1
      PBAI.log_score("- 1 for we will take more damage than we can heal if the target repeats their move")
    elsif user.is_healing_necessary?(0.65)
      add = 4
      score += add
      PBAI.log_score("+ #{add} for we will likely die without healing")
    else
      add = 2
      score += add
      PBAI.log_score("+ #{add} for we have lost some hp")
    end
    score += 1 if ai.battle.pbWeather == :Sandstorm
    PBAI.log_score("+ 1 for extra healing in Sandstorm")
  else
    score -= 3
    PBAI.log_score("- 3 for we are at full hp")
  end
  next score
end

# Reflect
PBAI::ScoreHandler.add("StartWeakenPhysicalDamageAgainstUserSide") do |score, ai, user, target, move|
  if user.side.effects[PBEffects::Reflect] > 0
    score -= 3
    PBAI.log_score("- 3 for reflect is already active")
  else
    enemies = target.side.battlers.select { |proj| proj && !proj.fainted? }.size
    physenemies = target.side.battlers.select { |proj| proj && proj.is_physical_attacker? }.size
    add = enemies + physenemies * 2
    score += add
    PBAI.log_score("+ #{add} based on enemy and physical enemy count")
    if user.has_role?(:SCREENS)
      score += 1
      PBAI.log_score("+ 1")
    end
  end
  next score
end


# Light Screen
PBAI::ScoreHandler.add("StartWeakenSpecialDamageAgainstUserSide") do |score, ai, user, target, move|
  if user.side.effects[PBEffects::LightScreen] > 0
    score -= 3
    PBAI.log_score("- 3 for light screen is already active")
  else
    enemies = target.side.battlers.select { |proj| proj && !proj.fainted? }.size
    specenemies = target.side.battlers.select { |proj| proj && proj.is_special_attacker? }.size
    add = enemies + specenemies * 2
    score += add
    PBAI.log_score("+ #{add} based on enemy and special enemy count")
    if user.has_role?(:SCREENS)
      score += 1
      PBAI.log_score("+ 1")
    end
  end
  next score
end

# Aurora Veil
PBAI::ScoreHandler.add("StartWeakenDamageAgainstUserSideIfHail") do |score, ai, user, target, move|
  if user.side.effects[PBEffects::AuroraVeil] > 0
    score -= 3
    PBAI.log_score("- 3 for Aurora Veil is already active")
  elsif user.effectiveWeather != :Hail
    score -= 3
    PBAI.log_score("- 3 for Aurora Veil will fail without Hail active")
  else
    enemies = target.side.battlers.select { |proj| proj && !proj.fainted? }.size
    add = enemies
    score += add
    PBAI.log_score("+ #{add} based on enemy count")
    if user.has_role?(:SCREENS)
      score += 2
      PBAI.log_score("+ 2")
    end
  end
  next score
end

#Taunt
PBAI::ScoreHandler.add("DisableTargetStatusMoves") do |score, ai, user, target, move|
  if target.flags[:will_be_taunted] && ai.battle.pbSideSize(0) == 2
    score -= 3
    PBAI.log_score("- 3 for another battler will already use Taunt on this target")
  elsif target.effects[PBEffects::Taunt]>0
    score -= 3
    PBAI.log_score("- 3 for the target is already Taunted")
  else
    weight = 0
    target_moves = target.moves
    target_moves.each do |proj|
      weight += 1 if proj.statusMove?
    end
    score += weight
    PBAI.log_score("+ #{weight} to Taunt potential stall or setup")
    if user.has_role?(:STALLBREAKER) && weight > 1
      score += 1
      PBAI.log_score("+ 1 for being a Stallbreaker")
    end
    setup_moves = [:SWORDSDANCE,:WORKUP,:NASTYPLOT,:GROWTH,:HOWL,:BULKUP,:CALMMIND,:TAILGLOW,:AGILITY,:ROCKPOLISH,:AUTOTOMIZE,
      :SHELLSMASH,:SHIFTGEAR,:QUIVERDANCE,:VICTORYDANCE,:CLANGOROUSSOUL,:CHARGE,:COIL,:HONECLAWS,:IRONDEFENSE,:COSMICPOWER,:AMNESIA,:DRAGONDANCE,:FILLETAWAY]
    for i in target.moves
      if setup_moves.include?(i.id)
        setup = true
      end
    end
    if setup == true
      score += 2
      PBAI.log_score("+ 2 to counter setup")
    end
    if $learned_flags[:should_taunt].include?(target) || $spam_block_flags[:no_attacking_flag] == target
      score += 3
      PBAI.log_score("+ 3 for stallbreaking")
    end
    if $spam_block_triggered && $spam_block_flags[:choice].is_a?(Battle::Move) && setup_moves.include?($spam_block_flags[:choice].id)
      buff = user.faster_than?(target) ? 3 : 2
      score += buff
      PBAI.log_score("+ #{buff} to prevent setup")
    end
  end
  if target.hasActiveAbility?([:MAGICBOUNCE,:GOODASGOLD,:AROMAVEIL,:OBLIVIOUS])
    score -= 20
    PBAI.log_score("- 20 because Taunt will fail")
  end
  next score
end

# Haze
PBAI::ScoreHandler.add("ResetAllBattlersStatStages") do |score, ai, user, target, move|
  roles = []
    for i in user.roles
      roles.push(i)
    end
 # if user.side.flags[:will_haze] && ai.battle.doublebattle
  #  score -= 30
   # PBAI.log_score("- 30 for another battler will already use haze")
  #else
    net = 0
    # User buffs: net goes up
    # User debuffs: net goes down
    # Target buffs: net goes down
    # Target debuffs: net goes up
    # The lower net is, the better Haze is to choose.
    user.side.battlers.each do |proj|
      next if proj.nil?
      GameData::Stat.each_battle { |s| net -= proj.stages[s] if proj.stages[s] != nil }
    end
    target.side.battlers.each do |proj|
      next if proj.nil?
      GameData::Stat.each_battle { |s| net += proj.stages[s] if proj.stages[s] != nil }
    end
    # As long as the target's stat stages are more advantageous than ours (i.e. net < 0), Haze is a good choice
    if net < 0
      add = -net
      score += add
      PBAI.log_score("+ #{add} to reset disadvantageous stat stages")
      if user.has_role?([:STALLBREAKER,:PHAZER])##.include?(roles)
        score += 1
        PBAI.log_score("+ 1 for having a role that compliments this move")
      end
      score += 1 if target.include?($learned_flags[:has_setup])
      PBAI.log_score("+ 1 for preventing the target from setting up")
    else
      score -= 3
      PBAI.log_score("- 3 for our stat stages are advantageous")
    end
  #end
  next score
end

# Curse
PBAI::ScoreHandler.add("CurseTargetOrLowerUserSpd1RaiseUserAtkDef1") do |score, ai, user, target, move|
  next unless user.types.include?(:GHOST)
  curse_target = (target.set_up_score > 0 || target.status != :NONE)
  if curse_target
    score += 6
    PBAI.log_score("+ 6 to add residual damage.")
  end
  next score
end

# Charge
PBAI::ScoreHandler.add("RaiseUserSpDef1PowerUpElectricMove") do |score, ai, user, target, move|
  if (target.types.include?(:GROUND) || target.hasActiveAbility?([:LIGHTNINGROD, :MOTORDRIVE, :VOLTABSORB])) || (user.effects[PBEffects::Charge] != 0 || user.charge != 0)
    score -= 10
    PBAI.log_score("- 10 because it's not worth using")
    next score
  end
  has_move = user.moves.any? {|mov| mov.type == :ELECTRIC && move.damagingMove?}
  if !has_move
    score -= 10
    PBAI.log_score("- 10 because there's no moves to boost")
  end
  next score
end

# Relic Song
PBAI::ScoreHandler.add("SleepTargetChangeUserMeloettaForm") do |score, ai, user, target, move|
  if user.is_physical_attacker? && user.isSpecies?(:MELOETTA) && user.form == 0
    score += 9
    PBAI.log_score("+ 9 to change form")
  end
  next score
end

#Grassy Glide
PBAI::ScoreHandler.add("HigherPriorityInGrassyTerrain") do |score, ai, user, target, move|
  if ai.battle.field.terrain == :Grassy
    pri = 0
    for i in user.moves
      pri += 1 if i.priority > 0 && i.damagingMove?
    end
    if target.faster_than?(user)
      score += 1
      PBAI.log_score("+ 1 for being a priority move to outspeed opponent")
      if user.get_calc_self(target, move) >= target.hp
        score += 1
        PBAI.log_score("+ 1 for being able to KO with priority")
      end
    end
    if pri > 0
      score += 1
      PBAI.log_score("+ 1 for being a priority move to counter opponent's priority")
      if user.faster_than?(target)
        score += 1
        PBAI.log_score("+ 1 for outprioritizing opponent")
      end
    end
    if user.underdog?(target)
      score += 1
      PBAI.log_score("+ 1 for being a priority move and being and underdog")
    end
    score += 1
    field = "Grassy Terrain boost"
    PBAI.log_score("+ 1 for #{field}")
  end
  next score
end

# Protect
PBAI::ScoreHandler.add("ProtectUser","ProtectUserFromDamagingMovesKingsShield") do |score, ai, user, target, move|
  if ai.battle.positions[user.index].effects[PBEffects::Wish] > 0
    score += 3
    PBAI.log_score("+ 3 for receiving an incoming Wish")
  end
  if ai.battle.pbSideSize(0) == 2 && user.effects[PBEffects::ProtectRate] == 1
    score += 1
    PBAI.log_score("+ 1 for encouraging use of Protect in Double battles")
  end
  if user.hasActiveAbility?(:MOODY) && user.effects[PBEffects::ProtectRate] == 1
    score += 4
    PBAI.log_score("+ 4 to activate Moody")
  end
  if user.effects[PBEffects::Substitute] > 0 && user.effects[PBEffects::ProtectRate] == 1
    if user.hasActiveAbility?(:SPEEDBOOST) && target.faster_than?(user)
      score += 2
      PBAI.log_score("+ 2 for boosting speed to outspeed opponent")
    end
    if (user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveAbility?(:POISONHEAL) && user.status == :POISON)) && user.hp < user.totalhp
      score += 1
      PBAI.log_score("+ 1 for recovering HP behind a Substitute")
    end
    if target.effects[PBEffects::LeechSeed] || [:POISON,:BURN,:FROZEN].include?(target.status)
      score += 1
      PBAI.log_score("+ 1 for forcing opponent to take residual damage")
    end
  end
  if (user.hasActiveItem?(:FLAMEORB) && user.status == :NONE && user.hasActiveAbility?([:GUTS,:MARVELSCALE])) || ((user.hasActiveItem?(:TOXICORB) || ai.battle.field.terrain == :Poison) && user.hasActiveAbility?([:TOXICBOOST,:POISONHEAL,:GUTS]) && user.affectedByTerrain? && user.status == :NONE)
    score += 25
    PBAI.log_score("+ 25 for getting a status to benefit their ability")
  end
  if (target.status == :POISON || target.status == :BURN || target.status == :FROZEN)
    protect = 2 - user.effects[PBEffects::ProtectRate]
    score += protect
    PBAI.log_score("+ #{protect} for stalling status damage")
    if user.has_role?(:TOXICSTALLER) && target.status == :POISON
      score += 1
      PBAI.log_score("+ 1 forbeing a Toxic Staller")
    end
  end
  score -= 2 if user.predict_switch?(target)
  if user.predict_switch?(target)
    PBAI.log_score("- 2 for predicting the switch")
  end
  score += 2 if user.flags[:should_protect] == true
  PBAI.log_score("+ 2 because there are no better moves") if user.flags[:should_protect] == true
  if user.effects[PBEffects::ProtectRate] > 1
    protect = user.effects[PBEffects::ProtectRate]
    score -= protect*2
    PBAI.log_score("- #{protect} to prevent potential Protect failure")
  else
    if user.turnCount == 0 && user.hasActiveAbility?(:SPEEDBOOST)
      score += 3
      PBAI.log_score("+ 3 for getting turn 1 Speed Boost")
    end
  end
  if user.has_role?(:FEAR) && target.turnCount == 0 && target.moves.any? {|move| move.id == :FAKEOUT}
    score += 10
    PBAI.log_score("+ 10 to prevent breaking Sash with Fake Out Turn 1")
  end
  if user.hasActiveAbility?(:STANCECHANGE) && user.form == 1 && move.function == "ProtectUserFromDamagingMovesKingsShield"
    score += 3
    PBAI.log_score("+ 3 for switching forms")
  end
  next score
end

# Teleport
PBAI::ScoreHandler.add("SwitchOutUserStatusMove") do |score, ai, user, target, move|
  roles = []
    for i in user.roles
      roles.push(i)
    end
  if user.effects[PBEffects::Trapping] > 0 && !user.predict_switch?(target)
    score += 3
    PBAI.log_score("+ 3 for escaping the trap")
  end
  if user.has_role?([:PHYSICALWALL,:SPECIALWALL,:DEFENSIVEPIVOT,:OFFENSIVEPIVOT,:TOXICSTALLER,:LEAD])
    score += 1
    PBAI.log_score("+ 1 ")
  end
  fnt = 0
  user.side.party.each do |pkmn|
    fnt +=1 if pkmn.fainted?
  end
  if user.hasActiveAbility?(:REGENERATOR) && fnt < user.side.party.length && user.hp < user.totalhp*0.67
    score += 1
    PBAI.log_score("+ 1 for being able to recover with Regenerator")
  end
  if fnt == user.side.party.length - 1
    score -= 20
    PBAI.log_score("- 20 for being the last Pokémon in the party")
  end
  if !user.can_switch?
    score -= 20
    PBAI.log_score("- 20 because we cannot Teleport")
  end
  next score
end

# Rapid Spin
PBAI::ScoreHandler.add("RemoveUserBindingAndEntryHazards") do |score, ai, user, target, move|
  hazard_score = 0
  rocks = user.own_side.effects[PBEffects::StealthRock] ? 1 : 0
  webs = user.own_side.effects[PBEffects::StickyWeb] ? 1 : 0
  spikes = user.own_side.effects[PBEffects::Spikes] > 0 ? user.own_side.effects[PBEffects::Spikes] : 0
  tspikes = $toxic_spikes[user.idxOwnSide] > 0 ? $toxic_spikes[user.idxOpposingSide] : 0
  hazard_score = (rocks) + (webs) + (spikes) + (tspikes)
  score += hazard_score
  PBAI.log_score("+ #{hazard_score} for removing hazards")
  if user.has_role?(:HAZARDREMOVAL)
    score += 2
    PBAI.log_score("+ 2")
  end
  fnt = 0
  user.side.party.each do |pkmn|
    fnt +=1 if pkmn.fainted?
  end
  if fnt == user.side.party.length - 1
    score -= 20
    PBAI.log_score("- 20 because of being the last mon")
  end
  next score
end

# Defog
PBAI::ScoreHandler.add("LowerTargetEvasion1RemoveSideEffects") do |score, ai, user, target, move|
  hazard_score = 0
  rocks = user.own_side.effects[PBEffects::StealthRock] ? 1 : 0
  webs = user.own_side.effects[PBEffects::StickyWeb] ? 1 : 0
  spikes = user.own_side.effects[PBEffects::Spikes] > 0 ? user.own_side.effects[PBEffects::Spikes] : 0
  tspikes = $toxic_spikes[user.idxOwnSide] > 0 ? $toxic_spikes[user.idxOwnSide] : 0
  light = user.opposing_side.effects[PBEffects::LightScreen] > 0 ? user.opposing_side.effects[PBEffects::LightScreen] : 0
  reflect = user.opposing_side.effects[PBEffects::Reflect] > 0 ? user.opposing_side.effects[PBEffects::Reflect] : 0
  veil = user.opposing_side.effects[PBEffects::AuroraVeil] > 0 ? user.opposing_side.effects[PBEffects::AuroraVeil] : 0
  hazard_score = (rocks) + (webs) + (spikes) + (tspikes) + (light) + (reflect) + (veil)

  orocks = user.opposing_side.effects[PBEffects::StealthRock] ? 1 : 0
  owebs = user.opposing_side.effects[PBEffects::StickyWeb] ? 1 : 0
  ospikes = user.opposing_side.effects[PBEffects::Spikes] > 0 ? user.opposing_side.effects[PBEffects::Spikes] : 0
  otspikes = $toxic_spikes[user.idxOpposingSide] > 0 ? $toxic_spikes[user.idxOpposingSide] : 0
  slight = user.own_side.effects[PBEffects::LightScreen] > 0 ? user.own_side.effects[PBEffects::LightScreen] : 0
  sreflect = user.own_side.effects[PBEffects::Reflect] > 0 ? user.own_side.effects[PBEffects::Reflect] : 0
  sveil = user.own_side.effects[PBEffects::AuroraVeil] > 0 ? user.own_side.effects[PBEffects::AuroraVeil] : 0
  user_score = (orocks) + (owebs) + (ospikes) + (otspikes) + (slight) + (sreflect) + (sveil)
  hazards = (hazard_score - user_score)
  score += hazards
  PBAI.log_score("+ #{hazards} for removing hazards and screens")
  if user.has_role?(:HAZARDREMOVAL) && hazards > 0
    score += 2
    PBAI.log_score("+ 2 ")
  end
  fnt = 0
  user.side.party.each do |pkmn|
    fnt +=1 if pkmn.fainted?
  end
  if target.hasActiveAbility?(:GOODASGOLD) || fnt == user.side.party.length - 1
    score -= 20
    PBAI.log_score("- 20 because Defog will fail")
  end
  next score
end

# Rage Powder/Ally Switch/Follow Me
PBAI::ScoreHandler.add("RedirectAllMovesToUser","UserSwapsPositionsWithAlly") do |score, ai, user, target, move|
  if ai.battle.pbSideSize(0) == 2
    ally = false
    b = nil
    enemy = []
    user.battler.eachAlly do |battler|
      ally = true if battler != user.battler
    end
    if ally
      ai.battle.eachOtherSideBattler(user.index) do |opp|
        next if opp.fainted?
        next if opp.nil?
        enemy.push(opp)
      end
      mon = user.side.battlers.find {|proj| proj && proj != self && !proj.fainted?}
      if enemy.any? {|e| mon.bad_against?(e)}
        score += 3
        PBAI.log_score("+ 3 for redirecting an attack away from partner")
        if user.has_role?(:REDIRECTION)
          score += 3
          PBAI.log_score("+ 3")
        end
      end
      if user.has_role?(:REDIRECTION) && mon.setup?
        score += 2
        PBAI.log_score("+ 2")
      end
      if mon.effects[PBEffects::HyperBeam] && move.function == "RedirectAllMovesToUser"
        score += 9
        PBAI.log_score("+ 9 to synergize with Hyper Beam spam")
      end
      if $chosen_move != nil
        if $chosen_move.id == :PROTECT
          score = 0
          PBAI.log_score("* 0 for not wasting a turn.")
        end
      end
    end
  else
    score -= 20
    PBAI.log_score("- 20 because move will fail")
  end
  next score
end

# Helping Hand
PBAI::ScoreHandler.add("PowerUpAllyMove") do |score, ai, user, target, move|
  if ai.battle.pbSideSize(0) == 2
    ally = false
    b = nil
    enemy = []
    user.battler.eachAlly do |battler|
      ally = true if battler != user.battler
    end
    if ally
      add = user.has_role?(:SUPPORT) ? 6 : 4
      score += add
      PBAI.log_score("#{add} to boost damage of ally")
      mon = user.side.battlers.find {|proj| proj && proj != self && !proj.fainted?}
      ally_kill = mon.moves.any? {|m| (mon.get_calc_self(target, m)*1.5) >= target.hp} #the 1.5x multiplier here is to consider the Helping Hand boost
      target_kill_ally = target.moves.any? {|m2| mon.get_calc(target,m2) >= mon.hp}
      target_fast_kill_ally - target_kill_ally && target.faster_than?(mon)
      ally_fast_kill = ally_kill && mon.faster_than?(target)
      if mon.effects[PBEffects::HyperBeam] || mon.defensive? || target_kill_ally && !ally_fast_kill || target_fast_kill_ally
        score -= 10
        PBAI.log_score("- 10 because move will be pointless")
      end
    end
  else
    score -= 20
    PBAI.log_score("- 20 because move will fail")
  end
  next score
end

# After You
PBAI::ScoreHandler.add("TargetActsNext") do |score, ai, user, target, move|
  if ai.battle.pbSideSize(0) == 2
    ally = false
    b = nil
    enemy = []
    user.battler.eachAlly do |battler|
      ally = true if battler != user.battler
    end
    if ally
      mon = user.side.battlers.find {|proj| proj && proj != self && !proj.fainted?}
      ally_kill = mon.moves.any? {|m| (mon.get_calc_self(target, m)) >= target.hp} #the 1.5x multiplier here is to consider the Helping Hand boost
      target_kill_ally = target.moves.any? {|m2| mon.get_calc(target,m2) >= mon.hp}
      target_kill = target.moves.any? {|m3| user.get_calc(target,m3) >= user.hp}
      target_fast_kill_ally = target_kill_ally && target.faster_than?(mon)
      target_fast_kill = target_kill && target.faster_than?(user)
      ally_fast_kill = ally_kill && mon.faster_than?(target)
      if ally_kill && target_fast_kill_ally && user.faster_than?(target)
        add = 9
        score += add
        PBAI.log_score("#{add} to make ally go first")
      end
      if mon.defensive? || ally_fast_kill || target_fast_kill
        score -= 10
        PBAI.log_score("- 10 because move will be pointless")
      end
    end
  else
    score -= 20
    PBAI.log_score("- 20 because move will fail")
  end
  next score
end

# Destiny Bond
PBAI::ScoreHandler.add("AttackerFaintsIfUserFaints") do |score, ai, user, target, move|
  next if user.effects[PBEffects::DestinyBondTarget] >= 0
  dmg = target.moves.any? {|mov| user.will_die_from_attack?(target,mov)}
  prio_kill = target.moves.any? {|mo| user.get_calc(target,mo) >= user.hp && mo.priority > 0} && !user.priority_blocking?
  fast_kill = (user.faster_than?(target) && user.moves.any? {|mv| user.get_calc_self(target,mv) >= target.hp} && !prio_kill)
  if dmg && !fast_kill
    score += 50
    PBAI.log_score("+ 50 to go for Destiny Bond")
    if !target.moves.any? {|m| m.statusMove?}
      score += 50
      PBAI.log_score("+ 50 more because target has no status moves")
    end
  end
  next score
end

# Spin Out
PBAI::ScoreHandler.add("LowerUserSpeed2") do |score, ai, user, target, move|
  if ai.battle.field.effects[PBEffects::TrickRoom] > 0 && user.stages[:SPEED] >= 0
    score += 15
    PBAI.log_score("+ 15 to set up for Trick Room")
  end
  next score
end

# Rolling Fog
PBAI::ScoreHandler.add("DoublePowerInMistyTerrain") do |score, ai, user, target, move|
  if ai.battle.field.terrain == :Misty
    score += 2
    PBAI.log_score("+ 2 for double power in Misty Terrain")
  end
  next score
end

# Body Press
PBAI::ScoreHandler.add("UseUserBaseDefenseInsteadOfUserBaseAttack") do |score, ai, user, target, move|
  if user.stages[:DEFENSE] > 0
    add = user.stages[:DEFENSE] * 2
    score += add
    PBAI.log_score("+ #{add} to encourage using Body Press")
  end
  next score
end

#Clangourous Soul
PBAI::ScoreHandler.add("RaiseUserMainStats1LoseThirdOfTotalHP") do |score, ai, user, target, move|
  if user.hasActiveItem?(:THROATSPRAY)
    score += 1
    PBAI.log_score("+ 1 for activating Throat Spray")
  end
  next score
end

#Belly Drum
PBAI::ScoreHandler.add("MaxUserAttackLoseHalfOfTotalHP","RaiseUserAtk2SpAtk2Speed2LoseHalfOfTotalHP") do |score, ai, user, target, move|
  ded = 0
  me_ded = 0
  for i in user.moves
    next if i.statusMove?
    ded += 1 if user.get_calc_self(target,i) >= target.hp
  end
  for j in target.moves
    next if j.statusMove?
    me_ded += 1 if user.get_calc(target,j) >= user.totalhp/2
  end
  if user.setup? && user.hp > user.totalhp/2 && ded == 0 && !user.statStageAtMax?(:ATTACK) && !$spam_block_flags[:haze_flag].include?(target) && me_ded == 0
    score += 9
    PBAI.log_score("+ 9 to encourage setup since we cannot kill")
  end
  next score
end

#First Impression
PBAI::ScoreHandler.add("FailsIfNotUserFirstTurn") do |score, ai, user, target, move|
  if user.turnCount == 0 && ai.battle.field.terrain != :Psychic && !target.hasActiveAbility?([:ARMORTAIL,:DAZZLING,:QUEENLYMAJESTY])
    score += 4
    PBAI.log_score("+ 4 for getting priority damage")
  else
    score -= 20
    PBAI.log_score("- 20 to discourage use after turn 1")
  end
  next score
end

#Tailwind
PBAI::ScoreHandler.add("StartUserSideDoubleSpeed") do |score, ai, user, target, move|
  if user.own_side.effects[PBEffects::Tailwind] <= 0
    score += 4
    PBAI.log_score("+ 4 for setting up to outspeed")
    if user.has_role?(:SPEEDCONTROL)
      score += 2
      PBAI.log_score("+ 2 ")
    end
  else
    score -= 20
    PBAI.log_score("- 20 because Tailwind is already up")
  end
  next score
end

# Pursuit
PBAI::ScoreHandler.add("PursueSwitchingFoe") do |score, ai, user, target, move|
  damage = user.get_calc_self(target,move)
  if damage >= target.hp
    score += 15
    PBAI.log_score("+ 15 because we kill regardless of whether they switch or not")
  elsif (damage*2) >= target.hp
    if user.predict_switch?(target)
      score += 7
      PBAI.log_score("+ 7 for predicting the switch and being able to kill if they switch")
    else
      score += 4
      PBAI.log_score("+4 because we will kill if they switch, even if the switch is unlikely")
    end
  end
  next score
end

# Hex, Bitter Malice, Barb Barrage, Infernal Parade
PBAI::ScoreHandler.add("DoublePowerIfTargetStatusProblem","DoublePowerIfTargetPoisonedPoisonTarget","DoublePowerIfTargetStatusProblemBurnTarget","DoublePowerIfTargetStatusProblemFrostbiteTarget") do |score, ai, user, target, move|
  if target.status != :NONE
    score += 2
    PBAI.log_score("+ 2 for abusing target's status")
  end
  next score
end

# Bolt Beak, Fishious Rend
PBAI::ScoreHandler.add("DoublePowerIfTargetNotActed") do |score, ai, user, target, move|
  if (user.faster_than?(target) && !user.target_is_immune?(move,target)) || user.predict_switch?(target)
    score += 6
    PBAI.log_score("+ 6 for getting double damage")
  end
  next score
end

#Knock Off
PBAI::ScoreHandler.add("RemoveTargetItem") do |score, ai, user, target, move|
  item = target.item
  dmg = 0
  for i in target.moves
      dmg += 1 if user.get_calc(target,i) >= user.hp
    end
  next score if item.nil?
  if !user.unlosableItem?(item)
    score += 2
    PBAI.log_score("+ 2 for removing items")
  else
    score -= 20
    PBAI.log_score("- 20 because these items cannot be removed")
  end
  if target.faster_than?(user) && dmg > 0 && user.moves.any? {|move| move.priority > 0 && move.damagingMove?}
    score -= 20
    PBAI.log_score("- 20 to prioritize priority moves over removing items since we will die anyway")
  end
  next score
end

# Endeavor
PBAI::ScoreHandler.add("LowerTargetHPToUserHP") do |score, ai, user, target, move|
  if user.has_role?(:FEAR) && user.turnCount != 1
    score += 10
    PBAI.log_score("+ 10 to prefer Endeavor")
  end
  next score
end

# Poltergeist
PBAI::ScoreHandler.add("FailsIfTargetHasNoItem") do |score, ai, user, target, move|
  if target.item == nil
    score -= 20
    PBAI.log_score("- 20 since it will fail")
  end
  next score
end

# Gigaton Hammer
PBAI::ScoreHandler.add("CantSelectConsecutiveTurns") do |score, ai, user, target, move|
  if $gigaton[user.index] > 0 || $bloodmoon[user.index] > 0
    score -= 20
    PBAI.log_score("- 20 since it will fail")
  end
  next score
end

# Sleep Talk
PBAI::ScoreHandler.add("UseRandomUserMoveIfAsleep") do |score, ai, user, target, move|
  if user.hasActiveAbility?(:COMATOSE) || user.asleep?
    score += 10
    PBAI.log_score("+ 10 to prioritize using moves while sleeping")
  end
  next score
end

# Last Resort
PBAI::ScoreHandler.add("FailsIfUserHasUnusedMove") do |score, ai, user, target, move|
  moveslist = []
  used = []
  unused_moves = false
  user.moves.each {|use| used.push(use.id) if use.id != :LASTRESORT}
  user.moves.each {|m| moveslist.push(m.id) if m.pp > 0}
  used.each do |move2|
    unused_moves = true if !user.movesUsed.include?(move2)
  end
  if (user.hasActiveAbility?(:COMATOSE) && user.moves.length == moveslist.length && moveslist.include?(:SLEEPTALK)) || unused_moves == true
    score -= 20
    PBAI.log_score("- 20 to prioritize using other moves over this move")
  end
  if unused_moves == false
    score += 10
    PBAI.log_score("+ 10 because this move is now usable")
  end
  next score
end

# Focus Energy
PBAI::ScoreHandler.add("RaiseUserCriticalHitRate2") do |score, ai, user, target, move|
  if user.has_role?(:CRIT) && user.turnCount == 0
    score += 10
    PBAI.log_score("+ 10 to set up crit")
  else
    score -= 20
    PBAI.log_score("- 20 to prevent bad move")
  end
  next score
end

# Trick Room
PBAI::ScoreHandler.add("StartSlowerBattlersActFirst") do |score, ai, user, target, move|
  if ai.battle.field.effects[PBEffects::TrickRoom] == 0 && target.faster_than?(user)
    score += 3
    PBAI.log_score("+ 3 for setting Trick Room to outspeed target")
    if user.has_role?(:TRICKROOMSETTER)
      score += 2
      PBAI.log_score("+ 2 for being a Trick Room setter")
    end
  else
    score -= 20
    PBAI.log_score("- 20 to not undo Trick Room") if ai.battle.field.effects[PBEffects::TrickRoom] != 0
  end
  next score
end

# Glare/Thunder Wave
PBAI::ScoreHandler.add("ParalyzeTargetIfNotTypeImmune") do |score, ai, user, target, move|
  if move.statusMove? && !user.target_is_immune?(move,target) && !target.hasActiveAbility?([:LIMBER,:COMATOSE,:VOLTABSORB,:GOODASGOLD,:HOPEFULTOLL]) && user.has_role?(:SPEEDCONTROL)
    score += 2
    PBAI.log_score("+ 2 for being able to paralyze and having the Speed Control role")
    if PBAI.threat_score(user,target) > 0 && $threat_flags[:paralyze] == true
      score += PBAI.threat_score(user,target)
      PBAI.log_score("+ #{PBAI.threat_score(user,target)} to add extra incentive to target this.")
    end
  end
  if ((target.status != :NONE || target.pbHasType?(:GROUND) || target.pbHasType?(:ELECTRIC) || target.hasActiveAbility?([:LIMBER,:COMATOSE,:VOLTABSORB,:GOODASGOLD])) && move.id == :THUNDERWAVE) || 
    (target.status != :NONE || target.pbHasType?(:ELECTRIC) || target.hasActiveAbility?([:LIMBER,:COMATOSE,:VOLTABSORB,:GOODASGOLD,:HOPEFULTOLL]))
    score -= 20
    PBAI.log_score("- 20 because the target cannot be paralyzed")
  end
  next score
end


# Fling
PBAI::ScoreHandler.add("ThrowUserItemAtTarget") do |score, ai, user, target, move|
  if user.item == nil
    score -= 20
    PBAI.log_score("- 20 because it will fail")
  end
  next score
end

# Double Shock
PBAI::ScoreHandler.add("UserLosesElectricType") do |score, ai, user, target, move|
  score = 0 if user.effects[PBEffects::DoubleShock] == true
  next score
end

# Aqua Ring
PBAI::ScoreHandler.add("StartHealUserEachTurn") do |score, ai, user, target, move|
  score = 0 if user.effects[PBEffects::AquaRing] == true
  next score
end

# Stuff Cheeks
PBAI::ScoreHandler.add("UserConsumeBerryRaiseDefense2") do |score, ai, user, target, move|
  next if user.set_up_score >= 2
  next if !user.item
  item = GameData::Item.get(user.item)
  if !item.is_berry?
    subs = score
    score = 0
    PBAI.log_score("- #{subs} to prevent failing")
  end
  next score
end

# Recycle
PBAI::ScoreHandler.add("RestoreUserConsumedItem") do |score, ai, user, target, move|
  if !user.recycleItem
    subs = score
    score = 0
    PBAI.log_score("- #{subs} to prevent failing")
  end
  next score
end


#=============================================================================#
#                                                                             #
# Multipliers                                                                 #
#                                                                             #
#=============================================================================#
#Discount Status Moves if Taunted
PBAI::ScoreHandler.add_final do |score, ai, user, target, move|
  if move.statusMove? && user.effects[PBEffects::Taunt] > 0
      score -= 20
      PBAI.log_score("- 20 to prevent failing")
  end
  if $spam_block_triggered && move.statusMove? && target.faster_than?(user) && $spam_block_flags[:choice].is_a?(Battle::Move) && $spam_block_flags[:choice].function == "DisableTargetStatusMoves"
    score -= 20
    PBAI.log_score("- 20 because target is going for Taunt")
  end
  next score
end

#Properly choose moves if Tormented
PBAI::ScoreHandler.add_final do |score, ai, user, target, move|
  if move == user.lastRegularMoveUsed && user.effects[PBEffects::Torment]
      score -= 20
      PBAI.log_score("- 20 to prevent failing")
  end
  next score
end

#Properly choose moves if Encored
PBAI::ScoreHandler.add_final do |score, ai, user, target, move|
  if user.effects[PBEffects::Encore] > 0
    encore_move = user.effects[PBEffects::EncoreMove]
    if move.id == encore_move
      score += 30
      PBAI.log_score("+ 30 to guarantee use of this move")
    else
      score -= 20
      PBAI.log_score("- 20 to prevent failing")
    end
  end
  next score
end

# Encourage using Fake Out properly
PBAI::ScoreHandler.add("FlinchTargetFailsIfNotUserFirstTurn") do |score, ai, user, target, move|
  next if target.priority_blocking?
  next if ai.battle.field.terrain == :Psychic
  if user.turnCount == 0
    score += 13
    PBAI.log_score("+ 13 for using Fake Out turn 1")
    if ai.battle.pbSideSize(0) == 2
      score += 2
      PBAI.log_score("+ 2 for being in a Double battle")
    end
    if PBAI.threat_score(user,target) == 50
      score += 10
      PBAI.log_score("+ 10 because the target outspeeds and OHKOs our entire team.")
    end
  else
    score -= 30
    PBAI.log_score("- 30 to discourage use after turn 1")
  end
  next score
end

#Prefer Weather/Terrain Moves if you are a weather setter
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if move.damagingMove?
  next if !PBAI::AI_Move.weather_terrain_move?(move)
  weather = [:Sun,:Rain,:Snow,:Sandstorm,:Electric,:Grassy,:Misty,:Psychic]
  setter = [[:SUNNYDAY],[:RAINDANCE],[:HAIL,:SNOWSCAPE,:CHILLYRECEPTION],[:SANDSTORM],[:ELECTRICTERRAIN],[:GRASSYTERRAIN],[:MISTYTERRAIN],[:PSYCHICTERRAIN]]
  ability = [
  [:SOLARPOWER,:CHLOROPHYLL,:PROTOSYNTHESIS,:FLOWERGIFT,:HARVEST,:FORECAST,:STEAMPOWERED],
  [:SWIFTSWIM,:RAINDISH,:DRYSKIN,:FORECAST,:STEAMPOWERED],
  [:ICEBODY,:SLUSHRUSH,:SNOWCLOAK,:ICEFACE,:FORECAST],
  [:SANDRUSH,:SANDVEIL,:SANDFORCE,:FORECAST],
  [:SURGESURFER,:QUARKDRIVE],
  [:MEADOWRUSH],
  [:NOCTEMBOOST],
  [:BRAINBLAST]]
  idx = -1
  setter.each do |abil|
    idx += 1
    break if abil.include?(move.id)
  end
  next if weather[idx] == ai.battle.pbWeather
  party = ai.battle.pbParty(user.index)
  if weather[idx] != ai.battle.pbWeather
    if user.has_role?(:WEATHERTERRAIN)
      mod = party.any? {|pkmn| !pkmn.fainted? && pkmn.has_role?(:WEATHERTERRAINABUSER) && ability[idx].include?(pkmn.ability_id)}
      add = mod ? 8 : 5
      score += add
      PBAI.log_score("+ #{add} to set weather for abuser in the back")
    end
  elsif weather[idx] != ai.battle.field.terrain
    if user.has_role?(:WEATHERTERRAIN)
      mod = party.any? {|pkmn| !pkmn.fainted? && pkmn.has_role?(:WEATHERTERRAINABUSER) && ability[idx].include?(pkmn.ability_id)}
      add = mod ? 8 : 5
      score += add
      PBAI.log_score("+ #{add} to set terrain for abuser in the back")
    end
  end
  next score
end

#=============================================================================#
#                                                                             #
# FINAL CONSIDERATIONS                                                        #
#                                                                             #
#=============================================================================#

# Ally considerations
PBAI::ScoreHandler.add_final do |score, ai, user, target, move|
# Prefer a different move if this move would also hit the user's ally and it is super effective against the ally
  # The target is not an ally to begin with (to exclude Heal Pulse and any other good ally-targeting moves)
  next if !ai.battle.doublebattle
  if target.side != user.side
    # If the move is a status move, we can assume it has a positive effect and thus would be good for our ally too.
    if !move.statusMove?
      target_type = move.pbTarget(user)
      # If the move also targets our ally
      if [:AllNearOthers,:AllBattlers,:BothSides].include?(target_type)
        # See if we have an ally
        if ally = user.side.battlers.find { |proj| proj && proj != user && !proj.fainted? }
          matchup = ally.calculate_move_matchup(move.id)
          # The move would be super effective on our ally
          if matchup > 1
            decr = (matchup / 2.0 * 5.0).round
            score -= decr
            PBAI.log_score("- #{decr} for super effectiveness on ally battler")
          end
        end
      end
    end
  end
  next score
end

# Immunity modifier
PBAI::ScoreHandler.add_final do |score, ai, user, target, move|
  next if $inverse
  if !move.statusMove? && user.target_is_immune?(move, target) && !user.choice_locked?
    score -= 10
    PBAI.log_score("- 10 for the target being immune")
  end
  if user.choice_locked? && user.target_is_immune?(move, target) && user.can_switch?
    score -= 10
    PBAI.log_score("- 10 for the target being immune")
  end
  next score
end

# Disabled modifier
PBAI::ScoreHandler.add_final do |score, ai, user, target, move|
  if user.effects[PBEffects::DisableMove] == move.id
    score -= 50
    PBAI.log_score("- 50 for the move being disabled")
  end
  next score
end

# Threat score modifier
PBAI::ScoreHandler.add_final do |score, ai, user, target, move|
  next if move.statusMove?
  threat = PBAI.threat_score(user,target)
  threat = 1 if threat <= 0
  if user.target_is_immune?(move,target) && !$inverse && user.effects[PBEffects::ChoiceBand] != move.id
    score -= 20
    PBAI.log_score("- 20 for extra weight against using ineffective moves")
  else
    if threat > 1 && threat < 7
      score += (threat/2).floor
      PBAI.log_score("+ #{(threat/2).floor} to weight move scores vs this target.")
    elsif threat >= 7
      if move.damagingMove?
        score += threat
        PBAI.log_score("+ #{threat} to add urgency to killing the threat.")
      end
    end
  end
  next score
end

# Setup prevention when kill is seen modifier
PBAI::ScoreHandler.add_final do |score, ai, user, target, move|
  count = 0
  o_count = 0
  se = 0
  user.moves.each do |m|
    next if m.statusMove?
    count += 1 if user.get_calc_self(target, m) >= target.hp
    matchup = target.calculate_move_matchup(m.id)
    se += 1 if matchup > 1
  end
  target.moves.each do |t|
    next if t.statusMove?
    o_count += 1 if user.get_calc(target, t) >= user.hp
  end
  faster = target.faster_than?(user)
  fast_kill = faster && o_count > 0
  slow_kill = !faster && o_count > 0 && count == 0
  user_slow_kill = faster && o_count == 0 && count > 0
  user_fast_kill = !faster && count > 0
  next score if !PBAI::AI_Move.setup_move?(move)
  minus = 0
  minus = 20 if fast_kill
  minus = 20 if user_slow_kill
  minus = 20 if slow_kill
  minus = 20 if user_fast_kill
  if minus > 0
    score -= minus
    PBAI.log_score("- 20 because a kill is seen and we should prioritize attacking moves")
  else
  end
  next score
end

# Effectiveness modifier
# For this to have a more dramatic effect, this block could be moved lower down
# so that it factors in more score modifications before multiplying.
PBAI::ScoreHandler.add_final do |score, ai, user, target, move|
  # Effectiveness doesn't add anything for fixed-damage moves.
  next if move.is_a?(Battle::Move::FixedDamageMove) || move.statusMove?
  next if user.hasActiveAbility?([:AIRLOCK,:CLOUDNINE])
  next if user.hasActiveItem?(:UTILITYUMBRELLA)
  # Add half the score times the effectiveness modifiers. Means super effective
  # will be a 50% increase in score.
  target_types = target.types
  mod = move.pbCalcTypeMod(move.type, user, target) / Effectiveness::NORMAL_EFFECTIVE.to_f
  # If mod is 0, i.e. the target is immune to the move (based on type, at least),
  # we do not multiply the score to 0, because immunity is handled as a final multiplier elsewhere.
  case ai.battle.pbWeather
  when :HarshSun
    mod = 0 if move.type == :WATER
    if mod == 0
      score -= 10
      PBAI.log_score("- 10 to prevent using useless moves in Primal weather")
    end
  when :HeavyRain
    mod = 0 if move.type == :FIRE
    if mod == 0
      score -= 10
      PBAI.log_score("- 10 to prevent using useless moves in Primal weather")
    end
  end
  next score
end

# Factoring in immunity to all status moves
PBAI::ScoreHandler.add_final do |score, ai, user, target, move|
  next if move.damagingMove?
  next if move.id == :SLEEPTALK
  if target.immune_to_status?(user)
    score -= 20
    PBAI.log_score("- 20 for the move being ineffective")
  end
  next score
end

# Adding score based on the ability to outspeed and KO
PBAI::ScoreHandler.add_final do |score, ai, user, target, move|
  next score if [:FAKEOUT,:FIRSTIMPRESSION].include?(move.id) && ai.battle.turnCount == 0
  next score if ai.battle.wildBattle? && !$game_switches[908]
  count = 0
  o_count = 0
  se = 0
  user.moves.each do |m|
    next if m.statusMove?
    count += 1 if user.get_calc_self(target, m) >= target.hp
    matchup = target.calculate_move_matchup(m.id)
    se += 1 if matchup > 1
  end
  prio_kill = false
  target.moves.each do |t|
    next if t.statusMove?
    o_count += 1 if user.get_calc(target, t) >= user.hp
    prio_kill = true if user.get_calc(target,t) >= user.hp && t.priority > 0
  end
  faster = user.faster_than?(target)
  fast_kill = faster
  slow_kill = !faster && count == 0 && o_count > 0
  user_slow_kill = !faster && o_count == 0 && count > 0
  target_fast_kill = (!faster && o_count > 0) || prio_kill
  prankster = user.hasActiveAbility?(:PRANKSTER) && !target.types.include?(:DARK)
  inflict_status = ["BurnTarget","FrostbiteTarget","ParalyzeTargetIfNotTypeImmune","PoisonTarget","BadPoisonTarget","SleepTarget","SleepTarget","SleepTargetIfUserDarkrai","AttackerFaintsIfUserFaints","UserFaintsLowerTargetAtkSpAtk2"]
  last_status = move.statusMove? && inflict_status.include?(move.function)
  if (move.statusMove? && prio_kill || last_status && target_fast_kill && !prankster)
    prev = score
    score = 0
    PBAI.log_score("- #{prev} because we will not be able to get a status move off without dying")
  elsif last_status && !fast_kill && !user_slow_kill && (prankster || faster)
    add = (9 + PBAI.threat_score(user,target))
    score += add
    PBAI.log_score("+ #{add} to get a last ditch status off against target")
  end
  if count > 0
    if move.damagingMove? && user.get_calc_self(target, move) >= target.hp
      if fast_kill
        add = 15
      elsif target_fast_kill
        add = 5
      elsif user_slow_kill
        add = 12
      else
        add = 0
      end
      score += add
      if target_fast_kill
        PBAI.log_score("+ 5 because we kill even though they kill us first")
      elsif fast_kill
        PBAI.log_score("+ #{add} for fast kill")
      elsif user_slow_kill
        PBAI.log_score("+ #{add} for slow kill")
      end
    end
    $ai_flags[:can_kill] = true
  else
    $ai_flags[:can_kill] = false if se == 0
    move_damage = []
    ind = 0
    user.moves.each do |m|
      next if m.statusMove?
      next if m.id == :FINALGAMBIT
      temp = [m,user.get_calc_self(target, m),ind]
      move_damage.push(temp)
      ind += 1
    end
    if move_damage.length > 1
      move_damage.sort! do |a,b|
        if b[1] != a[1]
          b[1] <=> a[1]
        else
          a[2] <=> b[2]
        end
      end
    elsif move_damage.length == 0
      if move.id == :ASSIST
        info = [move,1,0]
        move_damage.push(info)
      else
        i = 0
        user.moves.each do |mo|
          data = [mo,1,i]
          move_damage.push(data)
          i += 1
        end
      end
    end
    if move_damage[0][0] == move
      add = 4
      score += add
      PBAI.log_score("+ #{add} to prefer highest damaging move or first status move")
    end
  end
  if user.moves.length == 1
    score += 10
    PBAI.log_score("+ 10 to bypass Struggle issues with choiced single-move mons")
  end
  if score <= 0
    score = 1
    PBAI.log_score("Set score to 1 if less than 1 to prevent going for Struggle")
  end
  next score
end