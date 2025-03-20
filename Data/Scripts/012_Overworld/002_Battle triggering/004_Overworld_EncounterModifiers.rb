################################################################################
# This section was created solely for you to put various bits of code that
# modify various wild Pokémon and trainers immediately prior to battling them.
# Be sure that any code you use here ONLY applies to the Pokémon/trainers you
# want it to apply to!
################################################################################

# Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
EventHandlers.add(:on_wild_pokemon_created, :make_shiny_switch,
  proc { |pkmn|
    pkmn.shiny = true if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH]
  }
)

# Make all wild Pokémon male while a certain Switch is ON (see Settings).
EventHandlers.add(:on_wild_pokemon_created, :make_male_switch,
  proc { |pkmn|
    pkmn.makeMale if $game_switches[Settings::MALE_WILD_POKEMON_SWITCH]
  }
)

# Used in the random dungeon map. Makes the levels of all wild Pokémon in that
# map depend on the levels of Pokémon in the player's party.
# This is a simple method, and can/should be modified to account for evolutions
# and other such details.  Of course, you don't HAVE to use this code.
=begin
EventHandlers.add(:on_wild_pokemon_created, :level_depends_on_party,
  proc { |pkmn|
    next if $game_map.map_id != 51
    new_level = pbBalancedLevel($player.party) - 4 + rand(5)   # For variety
    new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
    pkmn.level = new_level
    pkmn.calc_stats
    pkmn.reset_moves
  }
)
=end

#Ekat Note: Map Array for Level Scaling
# Ashen Frost - Used to scale trainer levels based on Battle Rule
EventHandlers.add(:on_trainer_load, :level_depends_on_party,
  proc { |trainer|
    if trainer && ($game_temp.battle_rules["canScale"] || [315, 323, 324, 326, 336, 625, 627, 713, 788].include?($game_map.map_id))
      # DemICE adding level variety between the trainer's mons based on the PBS entries.
      if $PokemonGlobal.difficulty != 2 
        # Easy/Normal Mode
        maxlevel = 0
        for pokemon in trainer.party
          next if pokemon.level == 1 # Ignore level 1 cheese strats
          maxlevel = pokemon.level if pokemon.level > maxlevel
        end
        for pokemon in trainer.party
          next if pokemon.level == 1 # Ignore level 1 cheese strats
          new_level = pbBalancedLevel($player.party) #- 4 + rand(5)   # For variety
          new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
          difference = maxlevel - pokemon.level
          pokemon.level = new_level - difference
          pokemon.calc_stats
        end
      else
        # Hard Mode
        minlevel = 100
        for pokemon in trainer.party
          next if pokemon.level == 1 # Ignore level 1 cheese strats
          minlevel = pokemon.level if pokemon.level < minlevel
        end
        for pokemon in trainer.party
          next if pokemon.level == 1 # Ignore level 1 cheese strats
          new_level = pbBalancedLevel($player.party) #- 4 + rand(5)   # For variety
          new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
          difference = pokemon.level - minlevel
          new_level+=difference
          new_level = 100 if new_level > 100
          pokemon.level = new_level
          pokemon.calc_stats
        end
      end
      if trainer.name == "Grinder"
        for pokemon in trainer.party
          pokemon.level = new_level
					GameData::Stat.each_main do |s|
            newiv = pbBalancedLevel($player.party)
            newiv *= 0.7
            newiv = newiv.floor
            newiv = 31 if newiv > 31
						pokemon.iv[s.id] = newiv
            pokemon.calc_stats
					end		
        end
        trainer.party.shuffle!
      end
    end
  }
)

# Ashen Frost - Used to give wild Pokemon a chance of having an egg move
EventHandlers.add(:on_wild_pokemon_created, :random_egg_moves,
  proc { |pkmn|
    moves = pkmn.species_data.egg_moves
    num_moves_learned = rand(2)
    for i in 0...num_moves_learned
      pkmn.learn_move(moves[rand(moves.length)])
    end
  }
)

# Ashen Frost - Used for Battle Roulette Simulation fight
EventHandlers.add(:on_trainer_load, :battle_roulette_adjustment,
  proc { |trainer|
    if $game_switches[420]
      # Create temporary party
      temp_party = []
      for pkmn in $player.party
        clone_pkmn = pkmn.clone
        clone_pkmn.level = 50
        clone_pkmn.calc_stats
        temp_party.push(clone_pkmn)
      end
      $player.party = temp_party
    end
  }
)

# This is the basis of a trainer modifier. It works both for trainers loaded
# when you battle them, and for partner trainers when they are registered.
# Note that you can only modify a partner trainer's Pokémon, and not the trainer
# themselves nor their items this way, as those are generated from scratch
# before each battle.
#EventHandlers.trigger(:on_trainer_load, :put_a_name_here,
#  proc { |trainer|
#    if trainer   # An NPCTrainer object containing party/items/lose text, etc.
#      YOUR CODE HERE
#    end
#  }
#)
