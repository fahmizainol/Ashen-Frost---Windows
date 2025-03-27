# class PokemonData # Data will be fetched from :Battler and :Pokemon
#     attr_accessor :battlerIndex
#     attr_accessor :partyIndex
#     attr_accessor :species

#     attr_accessor :stats
#     attr_accessor :totalhp
#     attr_accessor :hp # current hp
#     attr_accessor :attack
#     attr_accessor :defense
#     attr_accessor :spatk
#     attr_accessor :spdef
#     attr_accessor :speed

#     attr_accessor :stages
#     attr_accessor :item
#     attr_accessor :ability
#     attr_accessor :moves
#     attr_accessor :level
#     attr_accessor :gender
#     attr_accessor :nature
#     attr_accessor :ivs
#     attr_accessor :evs

# class PlayerData # Fetched from :Trainer
#     attr_accessor :flags
#     attr_accessor :partydata # Array of PokemonData
#     attr_accessor :partycount

# class AIData # Fetched from :Trainer
#     attr_accessor :partydata
#     attr_accessor :partycount

# class ScoreData
#     attr_accessor :move # In the field only?
#     attr_accessor :item
#     attr_accessor :switch
#     attr_accessor :total

#     def initialize
#         @move = []
#         @item = -100
#         @switch = -100
#         @total = 0

# class GoatAI
#     # :Battle, yeah some data can be accessed directly from @battle but for porting might cause issue
#     attr_accessor :battle
#     attr_accessor :player
#     attr_accessor :ai

#     # attr_accessor :field
#     # attr_accessor :sides
#     # attr_accessor :terrains
#     # attr_accessor :lastMoveUsed
#     # attr_accessor :lastMoveUser
#     # attr_accessor :lastAttacker
#     # attr_accessor :lastFoeAttacker
#     # attr_accessor :choices

#     attr_accessor :playerdata # Array of PlayerData, fetched from Battler.party OR as the game goes
#     attr_accessor :aidata # Array of AIData, fetched from Battler.party
#     attr_accessor :currplayermon # PokemonData 

#     attr_accessor :scores # :ScoreData
    
    
#     def initialize(battle)
#         @battle = battle
#         @player = @battle.player # Trainer, refer to_trainer
#         @ai = @battle.opponent

#         @playerdata = @battle.party1
#         @aidata = @battle.party2
#         @currplayermon = @battle.battlers[0] # Battler

#         @scores = ScoreData.new()
#     end

#     def pbProcessAITurn()
        
#     end

