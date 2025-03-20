################################################################################
# Weather Overhaul by ArchyArc [v17] v1-
# This is an overhaul of a weather system not overhauling how the weathers look
# or act ingame.
#
# CONDITIONCHANGETIME is how long a condition will last before shifting in a
# region.
#
# WEATHERCHANGETIME is how long a weather will last before changing within the
# same condition for each map.
#
# CONDITIONS are the weather conditions that will change every 24 hours and
# determine what weathers can and can't appear.
#
# (Condition)WEATHER is what weathers can appear in that condition, and the
# chance out of 100 that they will appear.
#
# WEATHERMAPS are the maps affected by weather, any maps not included will set
# their weather to none essentially turning it off. you should do seperate ones
# for other regions, maybe have WEATHERKANTOMAP and WEATHERKALOSMAP for example.
################################################################################
WEATHERCHANGETIME      = 0.4  # Default 6 hours

RIVERVIEWVAR           = 296
FOGDALEVAR             = 297
MOROVEVAR              = 328

CITYWEATHER = [
  :None,         # None
  :Snow,         # Snow
  :Blizzard,     # Blizzard
  :FreezingRain  # Freezing Rain
]

ISLANDWEATHER = [
  :Rain, # Rain
  :Fog   # Foggy
]

DESERTWEATHER = [
  :Sun,       # Sun
  :Sandstorm, # Sandstorm
  :SolarWinds # Solar Winds
]

EXCEPTIONS  = [185] 
################################################################################

# Start of the coding
class PokemonGlobalMetadata
  attr_accessor :currentRiverviewWeatherCycle #the current weather cycle attribute used. must match up later
  attr_accessor :currentFogdaleWeatherCycle
  attr_accessor :currentMoroveWeatherCycle
end

EventHandlers.add(:on_map_or_spriteset_change, :check_weather_cycle,
  proc { |scene, _map_changed|
    if !$PokemonGlobal.currentRiverviewWeatherCycle ||
      $PokemonGlobal.currentRiverviewWeatherCycle[0] <= -1 ||
      ((Time.now - $PokemonGlobal.currentRiverviewWeatherCycle[1]) > WEATHERCHANGETIME * 60 * 60) #checking if the time is up
      pbGenerateWeather # calls the generate/change the weather
   end
  }
)

def pbGenerateWeather
  index = rand(CITYWEATHER.length) # randomly picks a weather
  $PokemonGlobal.currentRiverviewWeatherCycle = [index, Time.now] # sets it and restarts the timer
  index = rand(ISLANDWEATHER.length)
  $PokemonGlobal.currentFogdaleWeatherCycle = [index, Time.now]
  index = rand(DESERTWEATHER.length)
  $PokemonGlobal.currentMoroveWeatherCycle = [index, Time.now]
  pbWeatherChange
end

def pbWeatherChange
  $game_variables[RIVERVIEWVAR] = $PokemonGlobal.currentRiverviewWeatherCycle[0] # changes a variable to the new weather
  $game_variables[FOGDALEVAR] = $PokemonGlobal.currentFogdaleWeatherCycle[0]
  $game_variables[MOROVEVAR] = $PokemonGlobal.currentMoroveWeatherCycle[0]
end

# Weather changer
EventHandlers.add(:on_enter_map, :change_weather,
  proc { |old_map_id|
    # Check for exceptions
    next if EXCEPTIONS.include?($game_map.map_id) || !$game_map.metadata&.outdoor_map
    # Fogdale Weather
    if GameData::MapMetadata.get($game_map.map_id)&.has_flag?("Fogdale")
      $game_screen.weather(ISLANDWEATHER[$game_variables[FOGDALEVAR]], 9, 0)
    # Morove Weather
    elsif GameData::MapMetadata.get($game_map.map_id)&.has_flag?("Morove")
      $game_screen.weather(DESERTWEATHER[$game_variables[MOROVEVAR]], 9, 0)
    # Riverview Weather
    else
      $game_screen.weather(CITYWEATHER[$game_variables[RIVERVIEWVAR]], 9, 0)
    end
  }
)

# Sfx changer
EventHandlers.add(:on_enter_map, :change_sfx,
  proc { |old_map_id|
    # Start SFX
    !GameData::Weather.get($game_screen.weather_type).sfx.nil? ? pbBGSPlay(GameData::Weather.get($game_screen.weather_type).sfx) : pbBGSFade(0.8)
  }
)
