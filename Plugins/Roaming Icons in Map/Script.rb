#===============================================================================
# * Roaming Icon - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It displays icons on map for roaming
# pokémon.
#
#== INSTALLATION ===============================================================
#
# To this script works, put it above main OR convert into a plugin. On script 
# section UI_RegionMap, add line 'draw_roaming_position(mapindex)' before line 
# 'if playerpos && mapindex == playerpos[0]' (it is 
# 'if playerpos && mapindex==playerpos[0]' in Essentials v19 and v19.1). 
#
# Put the desired icons on "Graphics\Pokemon\Map icons\X.png" changing X for 
# species internal name, where "Graphics\Pokemon\Map icons\000.png" is the
# default one. Works with forms. Example: 
# "Graphics\Pokemon\Map icons\ARTICUNO_1.png" is Galarian Articuno file name.
#
#===============================================================================

if !PluginManager.installed?("Roaming Icon")
  PluginManager.register({                                                 
    :name    => "Roaming Icon",                                        
    :version => "1.1.2",                                                     
    :link    => "https://www.pokecommunity.com/showthread.php?t=438704",             
    :credits => "FL"
  })
end

class PokemonRegionMap_Scene
  def draw_roaming_position(mapindex)
    icon_index = 0
    for roam_pos in $PokemonGlobal.roamPosition
      active = $game_switches[Settings::ROAMING_SPECIES[roam_pos[0]][2]] && (
        $PokemonGlobal.roamPokemon.size <= roam_pos[0] || 
        $PokemonGlobal.roamPokemon[roam_pos[0]]!=true
      )
      next if !active
      roam_town_map_pos = GameData::MapMetadata.try_get(
        roam_pos[1]
      )&.town_map_position
      next if roam_town_map_pos.empty?
      next if mapindex != roam_town_map_pos[0]
      x = roam_town_map_pos[1]
      y = roam_town_map_pos[2]
      @sprites["roaming#{icon_index}"] = IconSprite.new(0,0,@viewport)
      @sprites["roaming#{icon_index}"].setBitmap(
        get_roaming_icon(Settings::ROAMING_SPECIES[roam_pos[0]][0])
      )
      @sprites["roaming#{icon_index}"].x = -SQUARE_WIDTH/2+(x*SQUARE_WIDTH)+(
        Graphics.width-@sprites["map"].bitmap.width
      )/2
      @sprites["roaming#{icon_index}"].y = -SQUARE_HEIGHT/2+(y*SQUARE_HEIGHT)+(
        Graphics.height-@sprites["map"].bitmap.height
      )/2
      icon_index+=1
    end
  end
  
  def get_roaming_icon(species)
    species_data = GameData::Species.try_get(species)
    return nil if !species_data
    path = "Graphics/Pokemon/Map icons/"
    if species_data.form > 0
      ret = pbResolveBitmap(
        sprintf("%s%s_%d",path, species_data.species, species_data.form)
      )
      return ret if ret
    end
    ret = pbResolveBitmap(sprintf("%s%s", path, species_data.species))
    return ret if ret
    return pbResolveBitmap(path+"000")
  end

  # Essentials v19 compatibility
  SQUARE_WIDTH = SQUAREWIDTH if !defined?(SQUARE_WIDTH)
  SQUARE_HEIGHT = SQUAREHEIGHT if !defined?(SQUARE_HEIGHT)
end