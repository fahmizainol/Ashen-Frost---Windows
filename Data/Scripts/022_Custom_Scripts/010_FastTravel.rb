#===========================================================================
# Fast Travel Handler
# Modified by Michael
#===========================================================================

def pbFastTravel
    if pbCanFastTravel?
        scene = PokemonRegionMap_Scene.new(-1, false)
        screen = PokemonRegionMapScreen.new(scene)
        ret = screen.pbStartFlyScreen2
    end
end

def pbCanFastTravel?(show_messages = false)
    if !$game_player.can_map_transfer_with_follower?
      pbMessage(_INTL("Only room for one person!")) if show_messages
      return false
    end
#    if !$game_map.metadata&.outdoor_map
#      pbMessage(_INTL("You can't take fast travel indoors!")) if show_messages
#      return false
#    end
    return true
end
