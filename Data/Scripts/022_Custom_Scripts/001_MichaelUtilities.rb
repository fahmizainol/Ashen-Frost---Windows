#===========================================================================
# Truffles Copier (3.5) Script
# Created by Michael
#===========================================================================
def truffles_find_evolve_copy(evolve = false)
    for pkmn in $player.party
        if [:SWINUB, :PILOSWINE, :MAMOSWINE].include?(pkmn.species)
            truffles = pkmn.clone
            if evolve
                truffles.species = :PILOSWINE
                truffles.level = 35
                truffles.learn_move(:ICESHARD)
                truffles.learn_move(:BULLDOZE)
                truffles.learn_move(:ROCKTOMB)
                truffles.learn_move(:RETURN)
            end
            $game_variables[325] = truffles
            break
        end
    end
end
#===========================================================================
# Pokemon Deletion Script
# Created by Michael
#===========================================================================
def delete_pokemon(pkmn)
  for i in 0...$player.party.length
    if $player.party[i].species == pkmn
      $player.party.delete_at(i)
      break
    end
  end
end
#===========================================================================
# Password Checker Script
# Modified by Michael
#===========================================================================
def passCheck(password,helptext="What's the password?",minlength=0,maxlength=8,casesensitive=false)
    code=pbEnterText(helptext,minlength,maxlength)
    $game_variables[27]=code
    if code==password || (casesensitive==false && code.downcase==password.downcase)
      return true
    else
      return false
    end
  end

#===========================================================================
# Exp Candy Checker
# Created by Michael
#===========================================================================
def pbEXPCandyCheck
  pLevel = pbBalancedLevel($player.party)
  if pLevel <= 30
    pbReceiveItem(:EXPCANDYS, 3)
  elsif pLevel > 30 and pLevel <= 50
    pbReceiveItem(:EXPCANDYM, 5)
  elsif pLevel > 50 and pLevel <= 70
    pbReceiveItem(:EXPCANDYL, 10)
  else
    pbReceiveItem(:EXPCANDYXL, 10)
  end
end

#===========================================================================
# Create Temp Zapdos
# Modified by Michael
#===========================================================================
def create_temp_zapdos(return_party = false)
  if !return_party
    # Store and clear party
    $game_variables[113] = $player.party.clone
    $player.party.clear
    # Add Zapdos
    poke = Pokemon.new(:ZAPDOS, $player.level_cap)
    poke.cannot_store = true
    poke.cannot_trade = true
    poke.cannot_release = true
    poke.name = "Fearow"
    poke.learn_move(:WILDCHARGE)
    poke.learn_move(:WEATHERBALL)
    poke.learn_move(:FLY)
    $PokemonGlobal.case_num > 17 ? poke.learn_move(:ANCIENTPOWER) : poke.learn_move(:FRUSTRATION)
    poke.ability_index = 2
    poke.nature = :NAUGHTY
    poke.iv[:HP] = 31
    poke.iv[:ATTACK] = 31
    poke.iv[:DEFENSE] = 31
    poke.iv[:SPECIAL_ATTACK] = 31
    poke.iv[:SPECIAL_DEFENSE] = 31
    poke.iv[:SPEED] = 31
    poke.happiness = $PokemonGlobal.case_num > 17 ? 1 : 0
    poke.shiny = false
    poke.poke_ball = $PokemonGlobal.case_num > 17 ? :TOPAZBALL : :COPPERBALL
    poke.owner.id = $player.id
    poke.calc_stats
    pbAddPokemonSilent(poke)
  else
    # Return player's party
    $player.party.clear
    $player.party = $game_variables[113]
  end
end

#===========================================================================
# Pull Zapdos from Party
# Modified by Michael
#===========================================================================
def pull_zapdos_from_party
  # Find Zapdos
  zapdos = ""
  for i in 0...$player.party.length
    zapdos = $player.party[i] if $player.party[i].species == :ZAPDOS
  end
  # Clear Party
  $game_variables[113] = $player.party.clone
  $player.party.clear
  # Add Zapdos to party
  pbAddPokemonSilent(zapdos)
end

#===========================================================================
# Allow Player to Modify IVs
# Created by Dem
#===========================================================================

def partyRaiseIVs(stat,choice=nil)
  if choice
    pkmn = $player.party[choice]
    if pkmn.iv[stat] >= 25
      pbMessage(_INTL("{1} can't be trained further.",pkmn.name))
      return
    end
    until pkmn.iv[stat] == 25
      if $player.money < 100
        pbMessage(_INTL("You couldn't fully train {1} because you ran out of money...",pkmn.name))
        return
      end
      pkmn.iv[stat] += 1
      $player.money -= 100
    end
  else
    $player.party.each do | pkmn |
        next if pkmn.iv[stat] >= 25
        until pkmn.iv[stat] == 25
          if $player.money < 100
            pbMessage(_INTL("You couldn't fully train everyone because you ran out of money..."))
            return
          end
          pkmn.iv[stat] += 1
          $player.money -= 100
        end
    end
  end
end

#===========================================================================
# Level Grinder ID Generator
# Created by Michael 
#===========================================================================
def level_grinder_id
  pLevel = pbBalancedLevel($player.party)
  case pLevel
  # First tier
  when 1..34
    return rand(1..10)
  # Second tier
  when 35..44
    return rand(11..20)
  # Third tier
  when 45..59
    return rand(21..30)
  # Fourth tier
  when 60..100
    return rand(31..40)
  end
end

#===========================================================================
# Controls Scrambler
# Created by Michael 
#===========================================================================
=begin
def scramble_controls
  $game_switches[252] = true
  CONTROLS_LIST = [ ["move_down", "turn_down"], ["move_left", "turn_left"], 
  ["move_right", "turn_right"], ["move_up", "turn_up"] ].shuffle!
end
=end
#===========================================================================
# DemICE Item Printer
# Created by DemICE
#===========================================================================

class PokemonGlobalMetadata
	attr_accessor(:itemprinter)
	attr_accessor(:itemprinterlist)
	
	alias itemprinter_initialize initialize
	def initialize
		itemprinter_initialize
    @itemprinter=false
		@itemprinterlist=[]
	end
end


def pbItemPrinterAdd(item)
  if $PokemonGlobal.itemprinter.nil?
    $PokemonGlobal.itemprinter=false
  end
  if $PokemonGlobal.itemprinterlist.nil?
    $PokemonGlobal.itemprinterlist=[]
  end
	#return false if !$PokemonGlobal.itemprinter
	found=false
	for i in 0...$PokemonGlobal.itemprinterlist.length
		if $PokemonGlobal.itemprinterlist[i]==item	
			found=true
		end
	end     
	if !found
		$PokemonGlobal.itemprinterlist.push(item)
		pbMessage(_INTL("You can now 3d print copies of {1}!",GameData::Item.get(item).name)) if $PokemonGlobal.itemprinter
		return true             
	end
	return false
end

def pbItemPrinterBackwardsComp 
  GameData::Item.each do |item|
    next if !item.is_evolution_stone?
    for i in 0..$bag.pockets.length-1
      pbItemPrinterAdd(item.id) if ItemStorageHelper.quantity($bag.pockets[i], item.id)>0
    end
  end
end

def pbPlatePocketChange 
  GameData::Item.each do |item|
    next if !item.is_plate?
    pbReceiveItem(item.id) if ItemStorageHelper.quantity($bag.pockets[4], item.id) > 0
    ItemStorageHelper.remove($bag.pockets[4], item.id, 1)
  end
end
