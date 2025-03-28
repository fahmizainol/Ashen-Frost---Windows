#-------------------------------------------------------------------------------
# Sky Battles + Inverse Battles
# Credit: mej71 (original), bo4p5687 (update)
#
#   If you want to set inverse battles, call: setBattleRule("inverseBattle")
#   If you want to set sky battles, call: setBattleRule("skyBattle")
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
module SkyBattle
  # Store pokemon can't battle (sky mode)
  # Pokemon aren't allowed to participate even though they are flying or have levitate
  # Add new pokemon: ':NAME'
  SkyPokemon = [
		:PIDGEY, :SPEAROW, :FARFETCHD, :DODUO, :DODRIO, :GENGAR, :HOOTHOOT, :NATU,
		:MURKROW, :DELIBIRD, :TAILLOW, :STARLY, :CHATOT, :SHAYMIN, :PIDOVE, :ARCHEN,
		:DUCKLETT, :RUFFLET, :VULLABY, :FLETCHLING, :HAWLUCHA
  ]
  
	# Store pokemon can battle (sky mode)
	# Pokemon are allowed to participate even though they aren't flying or haven't levitate
	# Add new pokemon: ':NAME'
	CanBattle = [
		# Example: :BULBASAUR
		# Add below this: 
		:RATTATA, :EKANS
	]

  def self.checkPkmnSky?(pkmn)
    list = []
    SkyPokemon.each { |species| list <<  GameData::Species.get(species).id }
    return true if list.include?(pkmn.species)
    return false
  end
  
	def self.checkExceptPkmn?(pkmn)
    list = []
    CanBattle.each { |species| list <<  GameData::Species.get(species).id }
    return true if list.include?(pkmn.species)
    return false
  end

  # Check pokemon in sky battle
	def self.canSkyBattle?(pkmn)
    checktype    = pkmn.hasType?(:FLYING)
    checkability = pkmn.hasAbility?(:LEVITATE)
    checkpkmn    = SkyBattle.checkPkmnSky?(pkmn)
    except       = SkyBattle.checkExceptPkmn?(pkmn)
    return ( (checktype || checkability) && !checkpkmn ) || except
  end
  
  # Store move pokemon can't use (sky mode)
  # Add new move: ':MOVE'
  SkyMove = [
		:BODYSLAM, :BULLDOZE, :DIG, :DIVE, :EARTHPOWER, :EARTHQUAKE, :ELECTRICTERRAIN,
		:FISSURE, :FIREPLEDGE, :FLYINGPRESS, :FRENZYPLANT, :GEOMANCY, :GRASSKNOT,
		:GRASSPLEDGE, :GRASSYTERRAIN, :GRAVITY, :HEATCRASH, :HEAVYSLAM, :INGRAIN, 
		:LANDSWRATH, :MAGNITUDE, :MATBLOCK, :MISTYTERRAIN, :MUDSPORT, :MUDDYWATER,
		:ROTOTILLER, :SEISMICTOSS, :SLAM, :SMACKDOWN, :SPIKES, :STOMP, :SUBSTITUTE,
		:SURF, :TOXICSPIKES, :WATERPLEDGE, :WATERSPORT
  ]
  
  def self.checkMoveSky?(id)
    list = []
    SkyMove.each { |moves| list << GameData::Move.get(moves).id }
    return true if list.include?(id)
    return false
  end
end
#-------------------------------------------------------------------------------
# Set rules
#-------------------------------------------------------------------------------
class Game_Temp
  attr_accessor :battle_sky
  attr_accessor :battle_inverse
  
  alias sky_inverse_battle_rule add_battle_rule
  def add_battle_rule(rule, var = nil)
    rules = self.battle_rules
    case rule.to_s.downcase
    when "skybattle";     rules["skyBattle"] = true
    when "inversebattle"; rules["inverseBattle"] = true
    else; sky_inverse_battle_rule(rule,var)
    end
  end
end

EventHandlers.add(:on_end_battle, :end_inverse_sky_rule,
  proc { |decision, canLose|
    $game_temp.battle_sky = false
    $game_temp.battle_inverse = false
  }
)
#-------------------------------------------------------------------------------
# Set type for 'inverse'
#-------------------------------------------------------------------------------
module GameData
	class Type
		alias inverse_effect effectiveness
		def effectiveness(other_type)
			return Effectiveness::NORMAL_EFFECTIVE_ONE if !other_type
			ret = inverse_effect(other_type)
			if $game_temp.battle_inverse || $atkinverter
				case ret
				when Effectiveness::INEFFECTIVE, Effectiveness::NOT_VERY_EFFECTIVE_ONE
          ret = Effectiveness::SUPER_EFFECTIVE_ONE
				when Effectiveness::SUPER_EFFECTIVE_ONE
          ret = Effectiveness::NOT_VERY_EFFECTIVE_ONE
				end
			end
			return ret
		end
	end
end
#-------------------------------------------------------------------------------
class Battle
  alias sky_choose_move pbCanChooseMove?
  def pbCanChooseMove?(idxBattler, idxMove, showMessages, sleepTalk = false)
    ret = sky_choose_move(idxBattler,idxMove,showMessages,sleepTalk)
    battler = @battlers[idxBattler]
    move = battler.moves[idxMove]
    # Check move
    if ret && $game_temp.battle_sky && SkyBattle.checkMoveSky?(move.id)
      pbDisplayPaused(_INTL("{1} can't use in a sky battle!",move.name)) if showMessages
      return false
    end
    return ret
  end
end
#-------------------------------------------------------------------------------
# Set sky battle conditions
#-------------------------------------------------------------------------------
module BattleCreationHelperMethods
  module_function

  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  def skip_battle?
    return true if $player.able_pokemon_count == 0
    if $game_temp.battle_rules["skyBattle"]
      count = 0
      $player.able_party.each { |p| count+=1 if SkyBattle.canSkyBattle?(p)}
      return true if count==0
    end
    return true if $DEBUG && Input.press?(Input::CTRL)
    return false
  end
  
 def partner_can_participate?(foe_party)
    return false if !$PokemonGlobal.partner || $game_temp.battle_rules["noPartner"]
    if $game_temp.battle_rules["skyBattle"]
      count = 0
      $PokemonGlobal.partner[3].each { |p| count+=1 if SkyBattle.canSkyBattle?(p)}
      return false if count==0
    end
    return true if foe_party.length > 1
    if $game_temp.battle_rules["size"]
      return false if $game_temp.battle_rules["size"] == "single" ||
                      $game_temp.battle_rules["size"][/^1v/i]   # "1v1", "1v2", "1v3", etc.
      return true
    end
    return false
  end
  
  # Generate information for the player and partner trainer(s)
  def set_up_player_trainers(foe_party)
    trainer_array = [$player]
    ally_items    = []
    pokemon_array = $player.party
    party_starts  = [0]
    if $game_temp.battle_rules["skyBattle"]
      pokemon_array = []
      # allows fainted mons, if they could participate if revived
      # leaves eggs alone, because they don't count anyways
      $player.party.each { |p| pokemon_array.push(p) if p && SkyBattle.canSkyBattle?(p) }
    end
    if partner_can_participate?(foe_party)
      ally = NPCTrainer.new($PokemonGlobal.partner[1], $PokemonGlobal.partner[0])
      ally.id    = $PokemonGlobal.partner[2]
      ally.party = $PokemonGlobal.partner[3]
      ally_items[1] = ally.items.clone
      trainer_array.push(ally)
      pokemon_array = []
      if $game_temp.battle_rules["skyBattle"]
        # allows fainted mons, if they could participate if revived
        # leaves eggs alone, because they don't count anyways
        $player.party.each { |p| pokemon_array.push(p) if p && SkyBattle.canSkyBattle?(p) }
      else
        $player.party.each { |pkmn| pokemon_array.push(pkmn) }
      end
      party_starts.push(pokemon_array.length)
      if $game_temp.battle_rules["skyBattle"]
        # allows fainted mons, if they could participate if revived
        # leaves eggs alone, because they don't count anyways
        ally.party.each { |pkmn| pokemon_array.push(pkmn) if SkyBattle.canSkyBattle?(pkmn) }
      else
        ally.party.each { |pkmn| pokemon_array.push(pkmn) }
      end
      setBattleRule("double") if $game_temp.battle_rules["size"].nil?
    end
    return trainer_array, ally_items, pokemon_array, party_starts
  end
  
  class << self
    alias sky_inverse_prepare_battle prepare_battle
    def prepare_battle(battle)
      self.sky_inverse_prepare_battle(battle)
      $game_temp.battle_sky = false
      $game_temp.battle_sky = true if $game_temp.battle_rules["skyBattle"]
      $game_temp.battle_inverse = false
      $game_temp.battle_inverse = true if $game_temp.battle_rules["inverseBattle"]
    end
  end
end