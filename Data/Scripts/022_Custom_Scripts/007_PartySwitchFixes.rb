#--------------------------------------------------------------------------------
#Allows one to see summary when choosing a Pokemon in party menu
#--------------------------------------------------------------------------------
class PokemonPartyScreen

  def pbChoosePokemonSummary
    ret = -1
    loop do
      @scene.pbSetHelpText(_INTL("Choose a Pokémon.")) 
      pkmnid = @scene.pbChoosePokemon
      break if pkmnid < 0   # Cancelled
      pkmn = @party[pkmnid]
      cmdChoose   = -1
      cmdSummary = -1
      commands = []
      commands[cmdChoose = commands.length]   = _INTL("Choose")
      commands[cmdSummary = commands.length]   = _INTL("Summary")
      commands[commands.length]                = _INTL("Cancel")
      command = @scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),commands) if pkmn
      if cmdChoose>=0 && command == cmdChoose
        ret = pkmnid
        break
      elsif cmdSummary>=0 && command == cmdSummary
        @scene.pbSummary(pkmnid) {
          @scene.pbSetHelpText(_INTL("Choose a Pokémon."))
        }
      end
    end
    return ret
  end
end

#--------------------------------------------------------------------------------
#Main Function
#--------------------------------------------------------------------------------
def pbStorePokemon(pkmn)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  pkmn.record_first_moves
  if $player.party_full? && ($PokemonSystem.sendtoboxes == 0 || $PokemonSystem.sendtoboxes == 2)   # Ask/must add to party
    # Store the Pokémon
    cmds = [_INTL("Add to your party"),
            _INTL("Send to a Box"),
            _INTL("See {1}'s summary", pkmn.name)]
    cmds.delete_at(1) if $PokemonSystem.sendtoboxes == 2
    loop do   
      cmd = pbMessage(_INTL("Where do you want to send {1} to?", pkmn.name), cmds, 99)
      break if cmd == 99   # Cancelling = send to a Box
      cmd += 1 if cmd >= 1 && $PokemonSystem.sendtoboxes == 2
      case cmd
      when 0   # Add to your party
        chosen = -1 
        # Account for eggs
        eggcount = 0
        for i in $player.party
          next if i.egg?
          eggcount += 1
        end
        # Choose Pokémon portion
        pbMessage(_INTL("Choose a Pokémon in your party to send to your Boxes."))
        pbFadeOutIn {
          scene = PokemonParty_Scene.new
          screen = PokemonPartyScreen.new(scene, $player.party)
          screen.pbStartScene(_INTL("Choose a Pokémon."), false)
          loop do
            chosen = screen.pbChoosePokemonSummary
            # Egg/cannot store check
            if eggcount <= 1 && !$player.party[chosen].egg? && pkmn.egg?
              pbMessage(_INTL("That's your last Pokémon!"))  
            elsif $player.party[chosen]&.cannot_store && chosen != -1
              pbMessage(_INTL("{1} refuses to go into storage!", $player.party[chosen].name))             
            else
              screen.pbEndScene
              break
            end
          end
        }
        next if chosen < 0
        party_size = $player.party.length
        # Send chosen Pokémon to storage
        send_pkmn = $player.party[chosen]
        stored_box = $PokemonStorage.pbStoreCaught(send_pkmn)
        box_name   = $PokemonStorage[stored_box].name
        # Add new Pokémon
        $player.party.delete_at(chosen)
        pbMessage(_INTL("{1} has been sent to Box \"{2}\".", send_pkmn.name, box_name))
        break
      when 1   # Send to a Box
        break
      when 2   # See X's summary
        pbFadeOutIn {
          summary_scene = PokemonSummary_Scene.new
          summary_screen = PokemonSummaryScreen.new(summary_scene, true)
          summary_screen.pbStartScreen([pkmn], 0)
        }
      end
    end
  end
  # Store as normal (add to party if there's space, or send to a Box if not)
  if $player.party_full?
    stored_box = $PokemonStorage.pbStoreCaught(pkmn)
    box_name   = $PokemonStorage[stored_box].name
    pbMessage(_INTL("{1} has been sent to Box \"{2}\"!", pkmn.name, box_name))
  else
    $player.party[$player.party.length] = pkmn
  end
end

def pbAddForeignPokemon(pkmn, level = 1, owner_name = nil, nickname = nil, owner_gender = 0, see_form = true)
  return false if !pkmn 
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  pkmn.owner = Pokemon::Owner.new_foreign(owner_name || "", owner_gender)
  pkmn.name = nickname[0, Pokemon::MAX_NAME_SIZE] if !nil_or_empty?(nickname)
  pkmn.calc_stats
  if owner_name
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon from {2}.\1", $player.name, owner_name))
  else
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon.\1", $player.name))
  end
  was_owned = $player.owned?(pkmn.species)
  $player.pokedex.set_seen(pkmn.species)
  $player.pokedex.set_owned(pkmn.species)
  $player.pokedex.register(pkmn) if see_form
  # Show Pokédex entry for new species if it hasn't been owned before
  if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && see_form && !was_owned && $player.has_pokedex
    pbMessage(_INTL("The Pokémon's data was added to the Pokédex."))
    $player.pokedex.register_last_seen(pkmn)
    pbFadeOutIn {
      scene = PokemonPokedexInfo_Scene.new
      screen = PokemonPokedexInfoScreen.new(scene)
      screen.pbDexEntry(pkmn.species)
    }
  end
  # Add the Pokémon
  pbStorePokemon(pkmn)
  return true
end

def pbGenerateEgg(pkmn, text = "")
  pkmn = Pokemon.new(pkmn, Settings::EGG_LEVEL) if !pkmn.is_a?(Pokemon)
    if GiftHiddenAbilityPercentage::Chance #Hidden Ability Modifier
      pkmn.ability_index = 2
    end
  # Set egg's details
  pkmn.name           = _INTL("Egg")
  pkmn.steps_to_hatch = pkmn.species_data.hatch_steps
  pkmn.obtain_text    = text
  pkmn.calc_stats
  # Add egg to party
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  if $player.party_full? && ($PokemonSystem.sendtoboxes == 0 || $PokemonSystem.sendtoboxes == 2)   # Ask/must add to party
    # Store the Pokémon
    cmds = [_INTL("Add to your party"),
            _INTL("Send to a Box"),
            _INTL("See {1}'s summary", pkmn.name)]
    cmds.delete_at(1) if $PokemonSystem.sendtoboxes == 2
    loop do   
      cmd = pbMessage(_INTL("Where do you want to send {1} to?", pkmn.name), cmds, 99)
      break if cmd == 99   # Cancelling = send to a Box
      cmd += 1 if cmd >= 1 && $PokemonSystem.sendtoboxes == 2
      case cmd
      when 0   # Add to your party
        chosen = -1 
        # Account for eggs
        eggcount = 0
        for i in $player.party
          next if i.egg?
          eggcount += 1
        end
        # Choose Pokémon portion
        pbMessage(_INTL("Choose a Pokémon in your party to send to your Boxes."))
        pbFadeOutIn {
          scene = PokemonParty_Scene.new
          screen = PokemonPartyScreen.new(scene, $player.party)
          screen.pbStartScene(_INTL("Choose a Pokémon."), false)
          loop do
            chosen = screen.pbChoosePokemonSummary
            # Egg/cannot store check
            if eggcount <= 1 && !$player.party[chosen].egg? && pkmn.egg?
              pbMessage(_INTL("That's your last Pokémon!"))  
            elsif $player.party[chosen]&.cannot_store && chosen != -1
              pbMessage(_INTL("{1} refuses to go into storage!", $player.party[chosen].name))             
            else
              screen.pbEndScene
              break
            end
          end
        }
        next if chosen < 0 # Cancelled
        party_size = $player.party.length
        # Send chosen Pokémon to storage
        send_pkmn = $player.party[chosen]
        stored_box = $PokemonStorage.pbStoreCaught(send_pkmn)
        box_name   = $PokemonStorage[stored_box].name
        # Add new Pokémon
        $player.party.delete_at(chosen)
        pbMessage(_INTL("{1} has been sent to Box \"{2}\".", send_pkmn.name, box_name))
        break
      when 1   # Send to a Box
        break
      when 2   # See X's summary
        pbFadeOutIn {
          summary_scene = PokemonSummary_Scene.new
          summary_screen = PokemonSummaryScreen.new(summary_scene, true)
          summary_screen.pbStartScreen([pkmn], 0)
        }
      end
    end
  end
  # Store as normal (add to party if there's space, or send to a Box if not)
  if $player.party_full?
    stored_box = $PokemonStorage.pbStoreCaught(pkmn)
    box_name   = $PokemonStorage[stored_box].name
    pbMessage(_INTL("{1} has been sent to Box \"{2}\"!", pkmn.name, box_name))
  else
    $player.party[$player.party.length] = pkmn
  end
end
alias pbAddEgg pbGenerateEgg
alias pbGenEgg pbGenerateEgg