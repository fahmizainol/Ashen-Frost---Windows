
class Pokemon
  attr_accessor :hp

  
end



class Pokemon
  class Move
    attr_accessor :move

    def initialize(move_id)
      @id   = GameData::Move.get(move_id).id
      @move = GameData::Move.get(move_id)
      @ppup = 0
      @pp   = total_pp
    end
  end
end

module PBEffects
  DesertsMark=3232
  Shelter =32322
  Blazed = 6969
  ELECTERRAIN = 14
  GRASSY = 15
  MISTY = 16
  PSYTERRAIN = 17
end

class Battle::ActiveField
  def initialize
    @effects = []
    @effects[PBEffects::AmuletCoin]      = false
    @effects[PBEffects::FairyLock]       = 0
    @effects[PBEffects::FusionBolt]      = false
    @effects[PBEffects::FusionFlare]     = false
    @effects[PBEffects::Gravity]         = 0
    @effects[PBEffects::HappyHour]       = false
    @effects[PBEffects::IonDeluge]       = false
    @effects[PBEffects::MagicRoom]       = 0
    @effects[PBEffects::MudSportField]   = 0
    @effects[PBEffects::PayDay]          = 0
    @effects[PBEffects::TrickRoom]       = 0
    @effects[PBEffects::WaterSportField] = 0
    @effects[PBEffects::WonderRoom]      = 0
    @effects[PBEffects::ClearFlute]      = 0 #Ashen Frost Exclusive
    @effects[PBEffects::ELECTERRAIN] = 0
    @effects[PBEffects::PSYTERRAIN] = 0
    @effects[PBEffects::MISTY] = 0
    @effects[PBEffects::GRASSY] = 0
    @defaultWeather  = :None
    @weather         = :None
    @weatherDuration = 0
    @defaultTerrain  = :None
    @terrain         = :None
    @terrainDuration = 0
  end

  def moveData(move)
    return fieldmove = {
      :fieldchange => false,
    }
  end

  

end

class Battle::ActiveSide
  def screenActive?(type=nil)
    return true if @effects[PBEffects::AuroraVeil] > 0
    return @effects[PBEffects::LightScreen] > 0 || @effects[PBEffects::Reflect] > 0 if type.nil?
    return @effects[PBEffects::LightScreen] > 0 if type == :special
    return @effects[PBEffects::Reflect] > 0 if type == :physical
  end

end

class Battle::Battler
  attr_accessor :crested
  attr_accessor :pokemon
  attr_accessor :personalID

  def pbInitBlankPokemon(species, level, owner = $player, withMoves = true, recheck_form = true)
    @species          = ""
    @form             = ""
    @forced_form      = nil
    @time_form_set    = nil
    self.level        = level
    @steps_to_hatch   = 0
    @gender           = nil
    @shiny            = nil
    @ability_index    = nil
    @ability          = nil
    @nature           = nil
    @nature_for_stats = nil
    @item             = nil
    @mail             = nil
    @moves            = []
    @first_moves      = []
    @ribbons          = []
    @cool             = 0
    @beauty           = 0
    @cute             = 0
    @smart            = 0
    @tough            = 0
    @sheen            = 0
    @pokerus          = 0
    @name             = nil
    @happiness        = 0
    @markings         = []
    @iv               = {}
    @ivMaxed          = {}
    @ev               = {}
    GameData::Stat.each_main do |s|
      @iv[s.id]       = rand(30 + 1)
      @ev[s.id]       = 0
    end
    @owner = owner

    @personalID       = rand(2**16) | (rand(2**16) << 16)
    @hp               = 0
    @totalhp          = 0
  end

  def initialize(battle, idxBattler)
      @battle      = battle
      @index       = idxBattler
      @captured    = false
      @dummy       = false
      @stages      = {}
      @effects     = []
      @damageState = Battle::DamageState.new
      @fainted = true
      pbInitBlank
      if idxBattler == 2 
        owner = @battle.player
      else
        owner = @battle.opponent
      end
      @pokemon = pbInitBlankPokemon("", 0, owner, false, false)
      pbInitEffects(false)
  end

  def hasType?(type)
    type = GameData::Type.get(type).id
    return self.types.include?(type)
  end


  def personalID
    return (@pokemon) ? @pokemon.personalID : 0
  end

  def ev
    return (@pokemon) ? @pokemon.ev : 0
  end

  def nature
    return (@pokemon) ? @pokemon.nature : 0
  end

  def pbOppositeOpposing
    if @battle.doublebattle
      return @battle.battlers[(@index^3)].pokemon.nil? ? @battle.battlers[(@index^1)] : @battle.battlers[(@index^3)]
    else
      return @battle.battlers[(@index^1)]
    end
  end

  def isFainted?
    return @pokemon.hp<=0
  end

  def pbPartner
    #puts @battle.battlers.inspect
    # return false
    return @battle.battlers[(@index^2)] ? @battle.battlers[(@index^2)] : nil
  end

  def type1
    return @types[0]
  end

  def type2
    return @types[1]
  end

  def itemWorks?(ignorefainted=false)
    return false if self.isFainted? if !ignorefainted
    return false if @item.nil?
    return true if @crested
    return false if @effects[:Embargo]>0
    return false if @battle.state.effects[:MagicRoom]>0
    return false if self.ability == :KLUTZ
    return false if @pokemon.corrosiveGas
    return true
  end

  def pbProcessTurn(choice, tryFlee = true)
    return false if fainted?
    # Wild roaming Pokémon always flee if possible
    if tryFlee && wild? &&
       @battle.rules["alwaysflee"] && @battle.pbCanRun?(@index)
      pbBeginTurn(choice)
      pbSEPlay("Battle flee")
      @battle.pbDisplay(_INTL("{1} fled from battle!", pbThis))
      @battle.decision = 3
      pbEndTurn(choice)
      return true
    end
    # Shift with the battler next to this one
    if choice[0] == :Shift
      idxOther = -1
      case @battle.pbSideSize(@index)
      when 2
        idxOther = (@index + 2) % 4
      when 3
        if @index != 2 && @index != 3   # If not in middle spot already
          idxOther = (@index.even?) ? 2 : 3
        end
      end
      if idxOther >= 0
        @battle.pbSwapBattlers(@index, idxOther)
        case @battle.pbSideSize(@index)
        when 2
          @battle.pbDisplay(_INTL("{1} moved across!", pbThis))
        when 3
          @battle.pbDisplay(_INTL("{1} moved to the center!", pbThis))
        end
      end
      pbBeginTurn(choice)
      pbCancelMoves
      @lastRoundMoved = @battle.turnCount   # Done something this round
      return true
    end
    # If this battler's action for this round wasn't "use a move"
    if choice[0] != :UseMove
      # Clean up effects that end at battler's turn
      pbBeginTurn(choice)
      pbEndTurn(choice)
      return false
    end
    # Use the move
    PBDebug.log("[Move usage] #{pbThis} started using #{choice[2].name}")
    PBDebug.logonerr {
      pbUseMove(choice, choice[2] == @battle.struggle)
    }
    if !@battle.isOnline? && !choice[2].zmove#perry aimemory
      @battle.battleAI.addMoveToMemory(self,choice[2])
    end
    @battle.pbJudge
    # Update priority order
    @battle.pbCalculatePriority if Settings::RECALCULATE_TURN_ORDER_AFTER_SPEED_CHANGES
    return true
  end

  def pbTarget(move)
    target=move.target
    print(target)
    return target

  end
end

class Battle
  attr_accessor :doublebattle
  attr_accessor :internalbattle
  attr_accessor :state
  attr_accessor :battlers
  attr_accessor :playerTrainer
  attr_accessor :opponentTrainer

  

  def initialize(scene, p1, p2, player, opponent)
    print("init battle")
    if p1.length == 0
      raise ArgumentError.new(_INTL("Party 1 has no Pokémon."))
    elsif p2.length == 0
      raise ArgumentError.new(_INTL("Party 2 has no Pokémon."))
    end
    @scene             = scene
    @peer              = Peer.new
    # @battleAI          = AI.new(self)
    @field             = ActiveField.new    # Whole field (gravity/rooms)
    @sides             = [ActiveSide.new,   # Player's side
    ActiveSide.new]   # Foe's side
    @positions         = []                 # Battler positions
    @battlers          = []
    @sideSizes         = [1, 1]   # Single battle, 1v1
    @backdrop          = ""
    @backdropBase      = nil
    @time              = 0
    @environment       = :None   # e.g. Tall grass, cave, still water
    @turnCount         = 0
    @decision          = 0
    @caughtPokemon     = []
    player   = [player] if !player.nil? && !player.is_a?(Array)
    opponent = [opponent] if !opponent.nil? && !opponent.is_a?(Array)
    # if opponent && player.is_a?(Array) && player.length==0
    #   player = player[0]
    # end
    # if opponent && opponent.is_a?(Array) && opponent.length==0
    #   opponent = opponent[0]
    # end
    @player            = player    # Array of Player/NPCTrainer objects, or nil
    @opponent          = opponent   # Array of NPCTrainer objects, or nil
    @playerTrainer = player[0]
    @opponentTrainer = opponent[0]
    @items             = nil
    @ally_items        = nil        # Array of items held by ally. This is just used for Mega Evolution for now.
    @party1            = p1
    @party2            = p2
    @party1order       = Array.new(@party1.length) { |i| i }
    @party2order       = Array.new(@party2.length) { |i| i }
    @party1starts      = [0]
    @party2starts      = [0]
    @internalBattle    = true
    @debug             = false
    @canRun            = true
    @canLose           = false
    @noforfeit         = false
    @alwayslosemoney   = false
    @switchStyle       = true
    @showAnims         = true
    @controlPlayer     = false
    @expGain           = true
    @moneyGain         = true
    @disablePokeBalls  = false
    @sendToBoxes       = 1
    @canScale          = false
    @rules             = {}
    @priority          = []
    @priorityTrickRoom = false
    @choices           = []
    @megaEvolution     = [
      [-1] * (@player ? @player.length : 1),
      [-1] * (@opponent ? @opponent.length : 1)
    ]
    @initialItems      = [
      Array.new(@party1.length) { |i| (@party1[i]) ? @party1[i].item_id : nil },
      Array.new(@party2.length) { |i| (@party2[i]) ? @party2[i].item_id : nil }
    ]
    @defeatItems      = [   # DemICE attempt to recover items upon defeat/forfeit
    Array.new(@party1.length) { |i| (@party1[i]) ? @party1[i].item_id : nil },
      Array.new(@party2.length) { |i| (@party2[i]) ? @party2[i].item_id : nil }
    ]
    @recycleItems      = [Array.new(@party1.length, nil),   Array.new(@party2.length, nil)]
    @belch             = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @battleBond        = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @corrosiveGas      = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @usedInBattle      = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @successStates     = []
    @lastMoveUsed      = nil
    @lastMoveUser      = -1
    @switching         = false
    @futureSight       = false
    @endOfRound        = false
    @moldBreaker       = false
    @runCommand        = 0
    @nextPickupUse     = 0
    if GameData::Move.exists?(:STRUGGLE)
      @struggle = Move.from_pokemon_move(self, Pokemon::Move.new(:STRUGGLE))
    else
      @struggle = Move::Struggle.new(self, nil)
    end
    @mega_rings = []
    GameData::Item.each { |item| @mega_rings.push(item.id) if item.has_flag?("MegaRing") }
    @foreground        = ""
    @doublebattle      = false
    @state = @field
    # @battleAI          = PokeBattle_AI.new(self)

    # $ai_log_data = [PokeBattle_AI_Info.new,PokeBattle_AI_Info.new,PokeBattle_AI_Info.new,PokeBattle_AI_Info.new]
  end
  
  def pbGetOpposingIndicesInOrder(idxBattler)
    case pbSideSize(0)
    when 1
      case pbSideSize(1)
      when 1   # 1v1 single
        return [0] if opposes?(idxBattler)
        return [1]
      when 2   # 1v2
        return [0] if opposes?(idxBattler)
        return [3, 1]
      when 3   # 1v3
        return [0] if opposes?(idxBattler)
        return [3, 5, 1]
      end
    when 2
      case pbSideSize(1)
      when 1   # 2v1
        return [0, 2] if opposes?(idxBattler)
        return [1]
      when 2   # 2v2 double
        return [[3, 1], [2, 0], [1, 3], [0, 2]][idxBattler]
        @doublebattle = true
      when 3   # 2v3
        return [[5, 3, 1], [2, 0], [3, 1, 5]][idxBattler] if idxBattler < 3
        return [0, 2]
      end
    when 3
      case pbSideSize(1)
      when 1   # 3v1
        return [2, 0, 4] if opposes?(idxBattler)
        return [1]
      when 2   # 3v2
        return [[3, 1], [2, 4, 0], [3, 1], [2, 0, 4], [1, 3]][idxBattler]
      when 3   # 3v3 triple
        return [[5, 3, 1], [4, 2, 0], [3, 5, 1], [2, 0, 4], [1, 3, 5], [0, 2, 4]][idxBattler]
      end
    end
    return [idxBattler]
  end

  def FE
    return @field.effects
  end 

  def trickroom
    return @field.effects[PBEffects::TrickRoom] 
  end

  def pbGetOwner(index)
    return pbGetOwnerFromBattlerIndex(index)
  end

  def pbCommandPhaseLoop(isPlayer)
		# NOTE: Doing some things (e.g. running, throwing a Poké Ball) takes up all
		#       your actions in a round.
		actioned = []
		idxBattler = -1
    # battlers_length = @battlers.length
    # if battlers_length == 2
    #   @battlers[2] = Battle::Battler.new(self, 2)
    #   @battlers[3] = Battle::Battler.new(self, 3)
    # end

    # if !@doublebattle
    #   battlers_length = 2
    # else
    #   battlers_length = 4
    # end

		# DemICE store all damages in a hash for better efficiency.
		loop do
			break if @decision != 0   # Battle ended, stop choosing actions
			idxBattler += 1
			break if idxBattler >= @battlers.length
			# break if idxBattler >= 4
			next if !@battlers[idxBattler] || pbOwnedByPlayer?(idxBattler) != isPlayer
			next if @choices[idxBattler][0] != :None    # Action is forced, can't choose one
			next if !pbCanShowCommands?(idxBattler)   # Action is forced, can't choose one
			if !@controlPlayer && pbOwnedByPlayer?(idxBattler)
				# Player chooses an action
				actioned.push(idxBattler)
				commandsEnd = false   # Whether to cancel choosing all other actions this round
				loop do
					cmd = pbCommandMenu(idxBattler, actioned.length == 1)
					# If being Sky Dropped, can't do anything except use a move
					if cmd > 0 && @battlers[idxBattler].effects[PBEffects:PBEffects::SkyDrop] >= 0
						pbDisplay(_INTL("Sky Drop won't let {1} go!", @battlers[idxBattler].pbThis(true)))
						next
					end
					case cmd
					when 0    # Fight
						break if pbFightMenu(idxBattler)
					when 1    # Bag
						if pbItemMenu(idxBattler, actioned.length == 1)
							commandsEnd = true if pbItemUsesAllActions?(@choices[idxBattler][1])
							break
						end
					when 2    # Pokémon
						break if pbPartyMenu(idxBattler)
					when 3    # Run
						# NOTE: "Run" is only an available option for the first battler the
						#       player chooses an action for in a round. Attempting to run
						#       from battle prevents you from choosing any other actions in
						#       that round.
						if pbRunMenu(idxBattler)
							commandsEnd = true
							break
						end
					when 4    # Call
						break if pbCallMenu(idxBattler)
					when -2   # Debug
						pbDebugMenu
						next
					when -1   # Go back to previous battler's action choice
						next if actioned.length <= 1
						actioned.pop   # Forget this battler was done
						idxBattler = actioned.last - 1
						pbCancelChoice(idxBattler + 1)   # Clear the previous battler's choice
						actioned.pop   # Forget the previous battler was done
						break
					end
					pbCancelChoice(idxBattler)
				end
			else 
				# DemICE moved the AI decision after player decision.
				# AI controls this battler
				# @battleAI.pbDefaultChooseEnemyCommand(idxBattler)
        @battleAI.processAIturn
            #AI Data collection perry

        for i in 0...3
          # print(@battlers[i])
          if @battlers[i] == nil then next end
          $ai_log_data[i].logAIScorings() if !isOnline? && @battlers[i].hp > 0 && !pbOwnedByPlayer?(i)
        end
			end 
			break if commandsEnd
		end
	end

  
  def pbStartTerrain(user, newTerrain, fixedDuration = true)
    return if @field.terrain == newTerrain
    @field.terrain = newTerrain
    duration = (fixedDuration) ? 5 : -1
    if duration > 0 && user && user.itemActive?(true)
      duration = Battle::ItemEffects.triggerTerrainExtender(user.item, newTerrain,
                                                            duration, user, self)
    end
    @field.terrainDuration = duration
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    pbHideAbilitySplash(user) if user
    case @field.terrain
    when :Electric
      @field.effects[PBEffects::ELECTERRAIN] = duration
      pbDisplay(_INTL("An electric current runs across the battlefield!"))
    when :Grassy
      @field.effects[PBEffects::GRASSY] = duration
      pbDisplay(_INTL("Grass grew to cover the battlefield!"))
    when :Misty
      @field.effects[PBEffects::MISTY] = duration
      pbDisplay(_INTL("Mist swirled about the battlefield!"))
    when :Psychic
      @field.effects[PBEffects::PSYTERRAIN] = duration
      pbDisplay(_INTL("The battlefield got weird!"))
    end
    # Check for abilities/items that trigger upon the terrain changing
    allBattlers.each { |b| b.pbAbilityOnTerrainChange }
    allBattlers.each { |b| b.pbItemTerrainStatBoostCheck }
  end

  # alias pbSendOut_ori pbSendOut
  # def pbSendOut(sendOuts, startBattle = false)
  #   print sendOuts[0][1]
  #   print sendOuts[0][0]
  #   @battleAI.addMonToMemory(sendOuts[0][1],sendOuts[0][0])
  #   pbSendOut_ori(sendOuts, startBattle)
  # end

  def pbIsOpposing?(index)
    return (index%2)==1
  end

  def isbossmon
    return false
  end 

  def issossmon
    return false
  end

  def pbPartySingleOwner(battlerIndex)
    party = pbParty(battlerIndex)
    ownerparty = []
    for i in 0...party.length
      ownerparty.push(party[i]) if pbIsOwner?(battlerIndex,i) && !party[i].nil?
    end
    return ownerparty
  end

  def isOnline?
    return false 
  end

  def ProgressiveFieldCheck(field,startstage=1,endstage=nil)
    return false
  end
end

class Battle::Move
  # # attr_accessor :move
  attr_accessor :zmove

  # def initialize(battle, move)
  #   @battle     = battle
  #   @realMove   = move
  #   # @move = @realMove
  #   # print("@move: #{@move}")
  #   @id         = move.id
  #   @name       = move.name   # Get the move's name
  #   # Get data on the move
  #   @function   = move.function_code
  #   @baseDamage = move.base_damage
  #   @type       = move.type
  #   @category   = move.category
  #   @accuracy   = move.accuracy
  #   @pp         = move.pp   # Can be changed with Mimic/Transform
  #   @addlEffect = move.effect_chance
  #   @target     = move.target
  #   @priority   = move.priority
  #   @flags      = move.flags.clone
  #   @calcType   = nil
  #   @powerBoost = false   # For Aerilate, Pixilate, Refrigerate, Galvanize
  #   @snatched   = false
  #   @zmove = false
  # end

  def zmove
    return false
  end

  def move
    return @realMove
  end

  # TODO: Recheck
  def pbTypeModifier(type,attacker,opponent,zorovar=false)
    mod1=1
    mod2=1
    return mod1*mod2
  end

  def pbTypeModifierNonBattler(type,attacker,opponent)
    mod1=1
    mod2=1
    return mod1*mod2
  end

  # TODO: Recheck
  def pbIsPriorityMoveAI(attacker)
    # print(pbPriority(attacker))
    pbPriority(attacker)
  end

  def pbIsSpecial?(type)
    return specialMove?
  end

  def pbIsPhysical?(type)
    return physicalMove?
  end

  def pbIsStatus?
    return statusMove?
  end

  def betterCategory(type = @type)
    return :physical if pbIsPhysical?(type = @type)
    return :special if pbIsSpecial?(type = @type)
    return :status if pbIsStatus?
  end

  def pbHitsSpecialStat?(type = @type)
    return false if @function == 0x122  # Psyshock/Psystrike
    return true if @function == 0x204   # Matrix Shot
    return pbIsSpecial?(type)
  end

  def pbHitsPhysicalStat?(type = @type)
    return false if @function == 0x204
    return true if @function == 0x122
    return pbIsPhysical?(type)
  end

  def pbCritRate?(user, target)
    return -1 if target.pbOwnSide.effects[PBEffects::LuckyChant] > 0
    # Set up the critical hit ratios
    ratios = (Settings::NEW_CRITICAL_HIT_RATE_MECHANICS) ? [24, 8, 2, 1] : [16, 8, 4, 3, 2]
    c = 0
    # Ability effects that alter critical hit rate
    if c >= 0 && user.abilityActive?
      c = Battle::AbilityEffects.triggerCriticalCalcFromUser(user.ability, user, target, c)
    end
    if c >= 0 && target.abilityActive? && !@battle.moldBreaker
      c = Battle::AbilityEffects.triggerCriticalCalcFromTarget(target.ability, user, target, c)
    end
    # Item effects that alter critical hit rate
    if c >= 0 && user.itemActive?
      c = Battle::ItemEffects.triggerCriticalCalcFromUser(user.item, user, target, c)
    end
    if c >= 0 && target.itemActive?
      c = Battle::ItemEffects.triggerCriticalCalcFromTarget(target.item, user, target, c)
    end
    return c if c < 0
    # Move-specific "always/never a critical hit" effects
    case pbCritialOverride(user, target)
    when 1  then return true
    when -1 then return false
    end
    # Other effects
    return c if c > 50   # Merciless
    return c if user.effects[PBEffects::LaserFocus] > 0
    c += 1 if highCriticalRate?
    c += user.effects[PBEffects::FocusEnergy]
    c += 1 if user.inHyperMode? && @type == :SHADOW
    c = ratios.length - 1 if c >= ratios.length
    # Calculation
    return c if ratios[c] == 1
    r = @battle.pbRandom(ratios[c])
    return c if r == 0

    return -1
  end

  def pbTargetsAll?(attacker)
    # TODO: Recheck again
    target_data = pbTarget(attacker)
    return target_data.num_targets > 1 && target_data.targets_foe
    # if @target==:AllOpposing 
    #   # TODO: should apply even if partner faints during an attack
    #   numtargets=0
    #   numtargets+=1 if !attacker.pbOpposing1.isFainted?
    #   numtargets+=1 if !attacker.pbOpposing2.isFainted?
    #   return numtargets>1
    # elsif @target==:AllNonUsers
    #   # TODO: should apply even if partner faints during an attack
    #   numtargets=0
    #   numtargets+=1 if !attacker.pbOpposing1.isFainted?
    #   numtargets+=1 if !attacker.pbOpposing2.isFainted?
    #   numtargets+=1 if !attacker.pbPartner.isFainted?
    #   return numtargets>1
    # end
    # return false
  end



  # def typeOverlayBoost(type,attacker=nil,opponent=nil) #returns multiplier value of overlay boost
  #   return 1 if !Rejuv
  #   overlayBoost = 1
  #   booster = nil
  #   for terrain in [:ELECTERRAIN,:GRASSY,:MISTY,:PSYTERRAIN]
  #     next if @battle.state.effects[terrain] == 0
  #     overlaytype = $cache.FEData[terrain].overlaytypedata[type]
  #     next if !overlaytype|| !overlaytype[:mult]
  #     if overlaytype[:condition] && attacker && opponent
  #       next if !eval(overlaytype[:condition])
  #     end
  #     if $game_variables[:DifficultyModes]==1 && !$game_switches[:FieldFrenzy]
  #       mult = ((overlaytype[:mult]-1.0)/2.0)+1.0
  #     elsif $game_variables[:DifficultyModes]!=1 && $game_switches[:FieldFrenzy]
  #       mult = ((overlaytype[:mult]-1.0)*2.0)+1.0 if overlaytype[:mult] >1
  #       mult = overlaytype[:mult]/2.0 if overlaytype[:mult] < 1
  #     else
  #       mult = overlaytype[:mult]
  #     end
  #     if mult && mult > overlayBoost
  #       overlayBoost = mult
  #       booster = terrain
  #     end
  #   end
  #   return overlayBoost, booster
  # end

  def typeOverlayBoost(type,attacker=nil,opponent=nil) #returns multiplier value of overlay boost
    return 1
  end

  def moveFieldBoost
    return 1
  end

  def typeFieldBoost(type, attacker, opponent)
    return 1
  end

  def fieldDefenseBoost(type, opponent)
    return 1
  end

  def basedamage
    return @baseDamage
  end


  def isSoundBased?
    print(soundMove?)
    return soundMove?
  end

  # Checking the move type prolly
  def pbType(attacker, type=@type)
    return @move.type
  end

end




# class Battle::Move 

#   def self.pbFromPBMove(battle,move,user,zbase=nil)
#     validate move => Pokemon::Move
#     code = move.function_code || "None"
#     if code[/^\d/]   # Begins with a digit
#       class_name = sprintf("Battle::Move::Effect%s", code)
#     else
#       class_name = sprintf("Battle::Move::%s", code)
#     end
#     if Object.const_defined?(class_name)
#       return Object.const_get(class_name).new(battle, move)
#     end
#     return Battle::Move::Unimplemented.new(battle, move)
#   end

# end

def fieldTypeChange(attacker, opponent, typemod, return_type=false)
  return typemod
end

# Renamed pbRoughDamge -> pbRoughDamageRejuv
# Renamed pbDefaultChooseNewEnemy -> pbDefaultChooseNewEnemyRejuv

