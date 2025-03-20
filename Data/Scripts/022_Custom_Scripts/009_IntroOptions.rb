#===============================================================================
# Options main screen
#===============================================================================
class PokemonIntroOption_Scene
    attr_reader :sprites
    attr_reader :in_load_screen
  
    def pbStartScene(in_load_screen = false)
      @in_load_screen = in_load_screen
      # Get all options
      @options = []
      @hashes = []
      MenuHandlers.each_available(:intro_options) do |option, hash, name|
        @options.push(
          hash["type"].new(name, hash["parameters"], hash["get_proc"], hash["set_proc"])
        )
        @hashes.push(hash)
      end
      # Create sprites
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      @sprites = {}
      addBackgroundOrColoredPlane(@sprites, "bg", "optionsbg", Color.new(192, 200, 208), @viewport)
      @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
        _INTL("Options"), 0, -16, Graphics.width, 64, @viewport
      )
      @sprites["title"].back_opacity = 0
      @sprites["textbox"] = pbCreateMessageWindow
      pbSetSystemFont(@sprites["textbox"].contents)
      @sprites["option"] = Window_PokemonOption.new(
        @options, 0, @sprites["title"].y + @sprites["title"].height - 16, Graphics.width,
        Graphics.height - (@sprites["title"].y + @sprites["title"].height - 16) - @sprites["textbox"].height
      )
      @sprites["option"].viewport = @viewport
      @sprites["option"].visible  = true
      # Get the values of each option
      @options.length.times { |i|  @sprites["option"].setValueNoRefresh(i, @options[i].get || 0) }
      @sprites["option"].refresh
      pbChangeSelection
      pbDeactivateWindows(@sprites)
      pbFadeInAndShow(@sprites) { pbUpdate }
    end
  
    def pbChangeSelection
      hash = @hashes[@sprites["option"].index]
      # Call selected option's "on_select" proc (if defined)
      @sprites["textbox"].letterbyletter = false
      hash["on_select"]&.call(self) if hash
      # Set descriptive text
      description = ""
      if hash
        if hash["description"].is_a?(Proc)
          description = hash["description"].call
        elsif !hash["description"].nil?
          description = _INTL(hash["description"])
        end
      else
        description = _INTL("Close the screen.")
      end
      @sprites["textbox"].text = description
    end
  
    def pbOptions
      pbActivateWindow(@sprites, "option") {
        index = -1
        loop do
          Graphics.update
          Input.update
          pbUpdate
          if @sprites["option"].index != index
            pbChangeSelection
            index = @sprites["option"].index
          end
          @options[index].set(@sprites["option"][index], self) if @sprites["option"].value_changed
          if Input.trigger?(Input::BACK)
            # Added DiscordRPC handling conditions
            if defined?(DiscordRPC)
              $PokemonSystem.discordrpc == 0 ? DiscordRPC.start : DiscordRPC.end
            end
            break
          elsif Input.trigger?(Input::USE)
            if @sprites["option"].index == @options.length
              if defined?(DiscordRPC)
                $PokemonSystem.discordrpc == 0 ? DiscordRPC.start : DiscordRPC.end
              end
              break
            end
          end
        end
      }
    end
  
    def pbEndScene
      pbPlayCloseMenuSE
      pbFadeOutAndHide(@sprites) { pbUpdate }
      # Set the values of each option, to make sure they're all set
      @options.length.times do |i|
        @options[i].set(@sprites["option"][i], self)
      end
      pbDisposeMessageWindow(@sprites["textbox"])
      pbDisposeSpriteHash(@sprites)
      pbUpdateSceneMap
      @viewport.dispose
    end
  
    def pbUpdate
      pbUpdateSpriteHash(@sprites)
    end
  end
  
  #===============================================================================
  #
  #===============================================================================
  class PokemonIntroOptionScreen
    def initialize(scene)
      @scene = scene
    end
  
    def pbStartScreen(in_load_screen = false)
      @scene.pbStartScene(in_load_screen)
      @scene.pbOptions
      @scene.pbEndScene
    end
  end

#===============================================================================
# Intro Options Menu commands
#===============================================================================
  MenuHandlers.add(:intro_options, :text_highlighting, {
    "name"        => _INTL("Text Highlighting"),
    "order"       => 10,
    "type"        => EnumOption,
    "parameters"  => [_INTL("On"), _INTL("Off")],
    "description" => _INTL("Choose whether important text is highlighted in distinct colours."),
    "get_proc"    => proc { next $PokemonGlobal.texthighlighting },
    "set_proc"    => proc { |value, _scene| $PokemonGlobal.texthighlighting = value }
  })

  MenuHandlers.add(:intro_options, :discordrpc, {
  "name"        => _INTL("Discord Activity"),
  "order"       => 20,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether you would like your play session data to be outputted to Discord."),
  "condition"   => proc { next defined?(DiscordAppID) && DiscordAppID && !$joiplay},
  "get_proc"    => proc { next $PokemonSystem.discordrpc },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.discordrpc = value }
})

  MenuHandlers.add(:intro_options, :difficulty, {
    "name"        => _INTL("Difficulty"),
    "order"       => 30,
    "type"        => EnumOption,
    "parameters"  => [_INTL("Easy"), _INTL("Normal"), _INTL("Hard")],
    "description" => _INTL("Choose the difficulty you'd like to play on."),
    "get_proc"    => proc { next $PokemonGlobal.difficulty },
  
    "set_proc"    => proc { |value, _scene| 
      $PokemonGlobal.difficulty = value 
      pbSet(400, value)
    }
  })

 MenuHandlers.add(:intro_options, :level_cap, {
    "name"        => _INTL("Level Cap"),
    "order"       => 40,
    "type"        => EnumOption,
    "parameters"  => [_INTL("Soft"), _INTL("Hard")],
    "description" => _INTL("Choose the level cap type you'd like to use."),
    "get_proc"    => proc { next $PokemonGlobal.levelcap },
    "set_proc"    => proc { |value, _scene| $PokemonGlobal.levelcap = value }
  })

  # DemICE
MenuHandlers.add(:intro_options, :damage_variance, {
  "name"        => _INTL("Damage Variance"),
  "order"       => 50,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether moves should have a random damage variance or not."),
  "get_proc"    => proc { next $PokemonGlobal.damage_variance },
  "set_proc"    => proc { |value, _scene| $PokemonGlobal.damage_variance = value }
})

# DemICE
MenuHandlers.add(:intro_options, :bag_ban, {
  "name"        => _INTL("Ban Bag In Battle"),
  "order"       => 60,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether both sides should be banned from using bag items in Trainer Battles."),
  "get_proc"    => proc { next $PokemonGlobal.bag_ban },
  "set_proc"    => proc { |value, _scene| $PokemonGlobal.bag_ban = value }
})