#===============================================================================
#
#===============================================================================
class PokemonSystem
  attr_accessor :textspeed
  attr_accessor :battlescene
  attr_accessor :battlestyle
  attr_accessor :sendtoboxes
  attr_accessor :givenicknames
  attr_accessor :frame
  attr_accessor :textskin
  attr_accessor :screensize
  attr_accessor :language
  attr_accessor :runstyle
  attr_accessor :bgmvolume
  attr_accessor :sevolume
  attr_accessor :textinput
  attr_accessor :autosave
  attr_accessor :discordrpc

  def initialize
    @textspeed        = 1     # Text speed (0=slow, 1=normal, 2=fast)
    @battlescene      = 0     # Battle effects (animations) (0=on, 1=off)
    @battlestyle      = 1     # Battle style (0=switch, 1=set)
    @sendtoboxes      = 0     # Send to Boxes (0=manual, 1=automatic)
    @givenicknames    = 0     # Give nicknames (0=give, 1=don't give)
    @frame            = 0     # Default window frame (see also Settings::MENU_WINDOWSKINS)
    @textskin         = 0     # Speech frame
    @screensize       = (Settings::SCREEN_SCALE * 2).floor - 1   # 0=half size, 1=full size, 2=full-and-a-half size, 3=double size
    @language         = 0     # Language (see also Settings::LANGUAGES in script PokemonSystem)
    @runstyle         = 0     # Default movement speed (0=walk, 1=run)
    @bgmvolume        = 100   # Volume of background music and ME
    @sevolume         = 100   # Volume of sound effects
    @textinput        = $joiplay ? 0 : 1     # Text input mode (0=cursor, 1=keyboard)
    @autosave         = 0     # Autosave (0=on, 1=off)
    @discordrpc       = 1     # DiscordRPC (0=on, 1=off)
  end
end

class PokemonGlobalMetadata
  attr_accessor :texthighlighting
  attr_accessor :difficulty
  attr_accessor :levelcap
  attr_accessor :damage_variance # DemICE
  attr_accessor :bag_ban # DemICE

  alias options_initialize initialize
  def initialize
    options_initialize
    @texthighlighting = 0     # Text highlighting (0=on, 1=off)
    @difficulty       = 1     # Difficulty (0=easy, 1=normal, 2=hard)
    @levelcap         = 1     # Level cap (0=soft, 1=hard)
    @damage_variance  = 0     # Damage Variance (0=on, 1=off)
    @bag_ban  = 1     # Damage Variance (0=on, 1=off)
  end
end

#===============================================================================
#
#===============================================================================
module PropertyMixin
  attr_reader :name

  def get
    return @get_proc&.call
  end

  def set(*args)
    @set_proc&.call(*args)
  end
end

#===============================================================================
#
#===============================================================================
class EnumOption
  include PropertyMixin
  attr_reader :values

  def initialize(name, values, get_proc, set_proc)
    @name     = name
    @values   = values.map { |val| _INTL(val) }
    @get_proc = get_proc
    @set_proc = set_proc
  end

  def next(current)
    index = current + 1
    index = @values.length - 1 if index > @values.length - 1
    return index
  end

  def prev(current)
    index = current - 1
    index = 0 if index < 0
    return index
  end
end

#===============================================================================
#
#===============================================================================
class NumberOption
  include PropertyMixin
  attr_reader :lowest_value
  attr_reader :highest_value

  def initialize(name, range, get_proc, set_proc)
    @name = name
    case range
    when Range
      @lowest_value  = range.begin
      @highest_value = range.end
    when Array
      @lowest_value  = range[0]
      @highest_value = range[1]
    end
    @get_proc = get_proc
    @set_proc = set_proc
  end

  def next(current)
    index = current + @lowest_value
    index += 1
    index = @lowest_value if index > @highest_value
    return index - @lowest_value
  end

  def prev(current)
    index = current + @lowest_value
    index -= 1
    index = @highest_value if index < @lowest_value
    return index - @lowest_value
  end
end

#===============================================================================
#
#===============================================================================
class SliderOption
  include PropertyMixin
  attr_reader :lowest_value
  attr_reader :highest_value

  def initialize(name, range, get_proc, set_proc)
    @name          = name
    @lowest_value  = range[0]
    @highest_value = range[1]
    @interval      = range[2]
    @get_proc      = get_proc
    @set_proc      = set_proc
  end

  def next(current)
    index = current + @lowest_value
    index += @interval
    index = @highest_value if index > @highest_value
    return index - @lowest_value
  end

  def prev(current)
    index = current + @lowest_value
    index -= @interval
    index = @lowest_value if index < @lowest_value
    return index - @lowest_value
  end
end

#===============================================================================
# Main options list
#===============================================================================
class Window_PokemonOption < Window_DrawableCommand
  attr_reader :value_changed

  SEL_NAME_BASE_COLOR    = Color.new(192, 120, 0)
  SEL_NAME_SHADOW_COLOR  = Color.new(248, 176, 80)
  SEL_VALUE_BASE_COLOR   = Color.new(248, 48, 24)
  SEL_VALUE_SHADOW_COLOR = Color.new(248, 136, 128)

  def initialize(options, x, y, width, height)
    @options = options
    @values = []
    @options.length.times { |i| @values[i] = 0 }
    @value_changed = false
    super(x, y, width, height)
  end

  def [](i)
    return @values[i]
  end

  def []=(i, value)
    @values[i] = value
    refresh
  end

  def setValueNoRefresh(i, value)
    @values[i] = value
  end

  def itemCount
    return @options.length + 1
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    sel_index = self.index
    # Draw option's name
    optionname = (index == @options.length) ? _INTL("Close") : @options[index].name
    optionwidth = rect.width * 9 / 20
    pbDrawShadowText(self.contents, rect.x, rect.y, optionwidth, rect.height, optionname,
                     (index == sel_index) ? SEL_NAME_BASE_COLOR : self.baseColor,
                     (index == sel_index) ? SEL_NAME_SHADOW_COLOR : self.shadowColor)
    return if index == @options.length
    # Draw option's values
    case @options[index]
    when EnumOption
      if @options[index].values.length > 1
        totalwidth = 0
        @options[index].values.each do |value|
          totalwidth += self.contents.text_size(value).width
        end
        spacing = (rect.width - rect.x - optionwidth - totalwidth) / (@options[index].values.length - 1)
        spacing = 0 if spacing < 0
        xpos = optionwidth + rect.x
        ivalue = 0
        @options[index].values.each do |value|
          pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                           (ivalue == self[index]) ? SEL_VALUE_BASE_COLOR : self.baseColor,
                           (ivalue == self[index]) ? SEL_VALUE_SHADOW_COLOR : self.shadowColor)
          xpos += self.contents.text_size(value).width
          xpos += spacing
          ivalue += 1
        end
      else
        pbDrawShadowText(self.contents, rect.x + optionwidth, rect.y, optionwidth, rect.height,
                         optionname, self.baseColor, self.shadowColor)
      end
    when NumberOption
      value = _INTL("Type {1}/{2}", @options[index].lowest_value + self[index],
                    @options[index].highest_value - @options[index].lowest_value + 1)
      xpos = optionwidth + (rect.x * 2)
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       SEL_VALUE_BASE_COLOR, SEL_VALUE_SHADOW_COLOR, 1)
    when SliderOption
      value = sprintf(" %d", @options[index].highest_value)
      sliderlength = rect.width - rect.x - optionwidth - self.contents.text_size(value).width
      xpos = optionwidth + rect.x
      self.contents.fill_rect(xpos, rect.y - 2 + (rect.height / 2), sliderlength, 4, self.baseColor)
      self.contents.fill_rect(
        xpos + ((sliderlength - 8) * (@options[index].lowest_value + self[index]) / @options[index].highest_value),
        rect.y - 8 + (rect.height / 2),
        8, 16, SEL_VALUE_BASE_COLOR
      )
      value = sprintf("%d", @options[index].lowest_value + self[index])
      xpos += (rect.width - rect.x - optionwidth) - self.contents.text_size(value).width
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       SEL_VALUE_BASE_COLOR, SEL_VALUE_SHADOW_COLOR)
    else
      value = @options[index].values[self[index]]
      xpos = optionwidth + rect.x
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       SEL_VALUE_BASE_COLOR, SEL_VALUE_SHADOW_COLOR)
    end
  end

  def update
    oldindex = self.index
    @value_changed = false
    super
    dorefresh = (self.index != oldindex)
    if self.active && self.index < @options.length
      if Input.repeat?(Input::LEFT)
        self[self.index] = @options[self.index].prev(self[self.index])
        dorefresh = true
        @value_changed = true
      elsif Input.repeat?(Input::RIGHT)
        self[self.index] = @options[self.index].next(self[self.index])
        dorefresh = true
        @value_changed = true
      end
    end
    refresh if dorefresh
  end
end

#===============================================================================
# Options main screen
#===============================================================================
class PokemonOption_Scene
  attr_reader :sprites
  attr_reader :in_load_screen

  def pbStartScene(in_load_screen = false)
    @in_load_screen = in_load_screen
    # Get all options
    @options = []
    @hashes = []
    MenuHandlers.each_available(:options_menu) do |option, hash, name|
      @options.push(
        hash["type"].new(name, hash["parameters"], hash["get_proc"], hash["set_proc"])
      )
      @hashes.push(hash)
    end
    if !@in_load_screen
      MenuHandlers.each_available(:options_menu_in_game) do |option, hash, name|
        @options.insert(
          (hash["order"] / 10),
          hash["type"].new(name, hash["parameters"], hash["get_proc"], hash["set_proc"])
        )
        @hashes.insert((hash["order"] / 10), hash)
      end
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
class PokemonOptionScreen
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
# Options Menu commands
#===============================================================================
MenuHandlers.add(:options_menu, :bgm_volume, {
  "name"        => _INTL("Music Volume"),
  "order"       => 10,
  "type"        => SliderOption,
  "parameters"  => [0, 100, 5],   # [minimum_value, maximum_value, interval]
  "description" => _INTL("Adjust the volume of the background music."),
  "get_proc"    => proc { next $PokemonSystem.bgmvolume },
  "set_proc"    => proc { |value, scene|
    next if $PokemonSystem.bgmvolume == value
    $PokemonSystem.bgmvolume = value
    next if scene.in_load_screen || $game_system.playing_bgm.nil?
    playingBGM = $game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgm_resume(playingBGM)
  }
})

MenuHandlers.add(:options_menu, :se_volume, {
  "name"        => _INTL("SE Volume"),
  "order"       => 20,
  "type"        => SliderOption,
  "parameters"  => [0, 100, 5],   # [minimum_value, maximum_value, interval]
  "description" => _INTL("Adjust the volume of sound effects."),
  "get_proc"    => proc { next $PokemonSystem.sevolume },
  "set_proc"    => proc { |value, _scene|
    next if $PokemonSystem.sevolume == value
    $PokemonSystem.sevolume = value
    if $game_system.playing_bgs
      $game_system.playing_bgs.volume = value
      playingBGS = $game_system.getPlayingBGS
      $game_system.bgs_pause
      $game_system.bgs_resume(playingBGS)
    end
    pbPlayCursorSE
  }
})

MenuHandlers.add(:options_menu, :text_speed, {
  "name"        => _INTL("Text Speed"),
  "order"       => 30,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Slow"), _INTL("Normal"), _INTL("Fast")],
  "description" => _INTL("Choose the speed at which text appears."),
  "on_select"   => proc { |scene| scene.sprites["textbox"].letterbyletter = true },
  "get_proc"    => proc { next $PokemonSystem.textspeed },
  "set_proc"    => proc { |value, scene|
    next if value == $PokemonSystem.textspeed
    $PokemonSystem.textspeed = value
    MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
    # Display the message with the selected text speed to gauge it better.
    scene.sprites["textbox"].textspeed      = MessageConfig.pbGetTextSpeed
    scene.sprites["textbox"].letterbyletter = true
    scene.sprites["textbox"].text           = scene.sprites["textbox"].text
  }
})

MenuHandlers.add(:options_menu_in_game, :text_highlighting, {
  "name"        => _INTL("Text Highlighting"),
  "order"       => 40,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether important text is highlighted in distinct colours."),
  "get_proc"    => proc { next $PokemonGlobal.texthighlighting },
  "set_proc"    => proc { |value, _scene| $PokemonGlobal.texthighlighting = value }
})

MenuHandlers.add(:options_menu, :autosave, {
  "name"        => _INTL("Autosave"),
  "order"       => 40,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether you would like the game to save automatically."),
  "get_proc"    => proc { next $PokemonSystem.autosave },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.autosave = value }
})

MenuHandlers.add(:options_menu, :discordrpc, {
  "name"        => _INTL("Discord Activity"),
  "order"       => 40,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether you would like your play session data to be outputted to Discord."),
  "condition"   => proc { next defined?(DiscordAppID) && DiscordAppID && !$joiplay},
  "get_proc"    => proc { next $PokemonSystem.discordrpc },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.discordrpc = value }
})

MenuHandlers.add(:options_menu_in_game, :difficulty, {
  "name"        => _INTL("Difficulty"),
  "order"       => 50,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Easy"), _INTL("Normal"), _INTL("Hard")],
  "description" => _INTL("Choose the difficulty you'd like to play on."),
  "get_proc"    => proc { next $PokemonGlobal.difficulty },

  "set_proc"    => proc { |value, _scene| 
    $PokemonGlobal.difficulty = value 
    pbSet(400, value)
  }
})

MenuHandlers.add(:options_menu_in_game, :level_cap, {
  "name"        => _INTL("Level Cap"),
  "order"       => 50,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Soft"), _INTL("Hard")],
  "description" => _INTL("Choose the level cap type you'd like to use."),
  "get_proc"    => proc { next $PokemonGlobal.levelcap },
  "set_proc"    => proc { |value, _scene| 
    $PokemonGlobal.levelcap = value 
  }
})

MenuHandlers.add(:options_menu, :battle_animations, {
  "name"        => _INTL("Battle Effects"),
  "order"       => 60,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether you wish to see move animations in battle."),
  "get_proc"    => proc { next $PokemonSystem.battlescene },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.battlescene = value }
})

MenuHandlers.add(:options_menu, :battle_style, {
  "name"        => _INTL("Battle Style"),
  "order"       => 70,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Switch"), _INTL("Set")],
  "description" => _INTL("Choose whether you can switch Pokémon when an opponent's Pokémon faints."),
  "condition"   => proc { next pbGet(400) != 2 },
  "get_proc"    => proc { next $PokemonSystem.battlestyle },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.battlestyle = value }
})

# DemICE
MenuHandlers.add(:options_menu_in_game, :damage_variance, {
  "name"        => _INTL("Damage Variance"),
  "order"       => 80,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether moves should have a random damage variance or not."),
  "get_proc"    => proc { next $PokemonGlobal.damage_variance },
  "set_proc"    => proc { |value, _scene| $PokemonGlobal.damage_variance = value }
})

# DemICE
MenuHandlers.add(:options_menu_in_game, :bag_ban, {
  "name"        => _INTL("Ban Bag In Battle"),
  "order"       => 90,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether both sides are allowed to use bag items in Trainer Battles."),
  "get_proc"    => proc { next $PokemonGlobal.bag_ban },
  "set_proc"    => proc { |value, _scene| $PokemonGlobal.bag_ban = value }
})

MenuHandlers.add(:options_menu, :movement_style, {
  "name"        => _INTL("Default Movement"),
  "order"       => 100,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Walking"), _INTL("Running")],
  "description" => _INTL("Choose your movement speed. Hold Back while moving to move at the other speed."),
  "condition"   => proc { next $player&.has_running_shoes },
  "get_proc"    => proc { next $PokemonSystem.runstyle },
  "set_proc"    => proc { |value, _sceme| $PokemonSystem.runstyle = value }
})

MenuHandlers.add(:options_menu, :send_to_boxes, {
  "name"        => _INTL("Send to Boxes"),
  "order"       => 110,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Manual"), _INTL("Automatic")],
  "description" => _INTL("Choose whether caught Pokémon are sent to your Boxes when your party is full."),
  "condition"   => proc { next Settings::NEW_CAPTURE_CAN_REPLACE_PARTY_MEMBER },
  "get_proc"    => proc { next $PokemonSystem.sendtoboxes },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.sendtoboxes = value }
})

MenuHandlers.add(:options_menu, :give_nicknames, {
  "name"        => _INTL("Give Nicknames"),
  "order"       => 120,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Give"), _INTL("Don't give")],
  "description" => _INTL("Choose whether you can give a nickname to a Pokémon when you obtain it."),
  "get_proc"    => proc { next $PokemonSystem.givenicknames },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.givenicknames = value }
})

MenuHandlers.add(:options_menu, :text_input_style, {
  "name"        => _INTL("Text Entry"),
  "order"       => 130,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Cursor"), _INTL("Keyboard")],
  "description" => _INTL("Choose how you want to enter text."),
  "condition"   => proc { next !$joiplay},
  "get_proc"    => proc { next $PokemonSystem.textinput },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.textinput = value }
})

MenuHandlers.add(:options_menu, :screen_size, {
  "name"        => _INTL("Screen Size"),
  "order"       => 140,
  "type"        => EnumOption,
  "parameters"  => [_INTL("S"), _INTL("M"), _INTL("L"), _INTL("XL"), _INTL("Full")],
  "description" => _INTL("Choose the size of the game window."),
  "condition"   => proc { next !$joiplay},
  "get_proc"    => proc { next [$PokemonSystem.screensize, 4].min },
  "set_proc"    => proc { |value, _scene|
    next if $PokemonSystem.screensize == value
    $PokemonSystem.screensize = value
    pbSetResizeFactor($PokemonSystem.screensize)
  }
})
