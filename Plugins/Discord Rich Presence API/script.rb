DiscordAppID = 887363647318421534

require 'discord'

# Graphics module override to pass updates to Discord

module Graphics

  unless defined?(__discord_update)
    class << Graphics
      alias __discord_update update 
    end

    def self.update
      __discord_update
      Discord.update
    end
  end

end

module DiscordRPC
  # Hash containing relevant Discord attributes for rich presence
  # :large_image should be a game-specific, recognizable image (logo, art, etc)
  # Image should be uploaded to the application art assets here https://discord.com/developers/applications
  # Use the asset key you define when uploading the image.
  @@discordRPCInfo = {
    :details => "",
    :state => "",
    :start_timestamp => Time.now.to_i,
    :end_timestamp => nil,
    :large_image => "ashen_frost_logo",
    :small_image => "cover",
    :large_image_text => "Pokémon Ashen Frost",
    :small_image_text => ""
  }

  # Method to connect to Discord & begin displaying info.
  def self.start
    return if Discord.connected? || DiscordAppID.nil?

    Discord.connect(DiscordAppID)

    @@discordRPCInfo[:start_timestamp] = Time.now.to_i
    @@discordRPCInfo[:end_timestamp] = nil
    exploration if inGame?

    update
  end

  # Method to disconnect from Discord & remove info.
  def self.end
    if Discord.connected?
      Discord.disconnect
    end
  end

  def self.title_screen
    @@discordRPCInfo[:details] = "On the title screen"
    update
  end

  def self.load_screen
    @@discordRPCInfo[:details] = "In the loading screen"
    if defined?($PokemonGlobal.case_num) && defined?($player.name)
      @@discordRPCInfo[:state] = "Case " + $PokemonGlobal.case_num.to_s + " - " + $player.name 
    end
    update
  end

  def self.single_trainer(opp)
    @@discordRPCInfo[:details] = "In a battle | " + opp.full_name
    update
  end

  def self.double_trainer(opp, opp2)
    @@discordRPCInfo[:details] = "In a battle | " + opp.full_name + " and " + opp2.full_name
    update
  end

  def self.triple_trainer(opp, opp2, opp3)
    @@discordRPCInfo[:details] = "In a battle | " + opp.full_name + ", " + opp2.full_name + ", and " + opp3.full_name
    update
  end

  def self.single_wild(pkmn)
    @@discordRPCInfo[:details] = "In a wild battle | " + pkmn.name
    update
  end

  def self.double_wild(pkmn, pkmn2)
    @@discordRPCInfo[:details] = "In a wild battle | " + pkmn.name + " and " + pkmn2.name
    update
  end

  def self.triple_wild(pkmn, pkmn2, pkmn3)
    @@discordRPCInfo[:details] = "In a wild battle | " + pkmn.name + ", " + pkmn2.name + ", and " + pkmn3.name
    update
  end

  #  def self.onEndBattle(sender, event)
#    exploration
#  end

  def self.on_map_change
    if !Discord.connected? && !DiscordAppID.nil?
      Discord.connect(DiscordAppID)
    end

    exploration
  end

  def self.exploration
    @@discordRPCInfo[:details] = pbGetMapNameFromId($game_map.map_id)
    $PokemonGlobal.case_num = 1 if !defined?($PokemonGlobal.case_num)
    @@discordRPCInfo[:state] = "Case " + $PokemonGlobal.case_num.to_s + " - " + $player.name
    update
  end

  def self.inGame?
    return $game_switches && $game_variables && $game_map && $player
  end

  def self.update
    Discord.update_activity(@@discordRPCInfo)
  end
end

# Processes to update Discord status.

# Changes Discord RPC value based on location
EventHandlers.add(:on_map_or_spriteset_change, :discord_rpc,
  proc { |scene, _map_changed|
    next unless $PokemonSystem.discordrpc == 0
    DiscordRPC.on_map_change
  }
)
