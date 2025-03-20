#===============================================================================
#
#===============================================================================
class PokegearButton < Sprite
  attr_reader :index
  attr_reader :name
  attr_reader :selected

  TEXT_BASE_COLOR = Color.new(248, 248, 248)
  TEXT_SHADOW_COLOR = Color.new(40, 40, 40)

  def initialize(command, x, y, viewport = nil)
    super(viewport)
    @image = command[0]
    @name  = command[1]

    @selected = false
    if $player.female? && pbResolveBitmap(sprintf("Graphics/Pictures/Pokegear/icon_button_f"))
      @button = AnimatedBitmap.new("Graphics/Pictures/Pokegear/icon_button_f")
    elsif pbResolveBitmap(sprintf("Graphics/Pictures/Pokegear/icon_button_" + @image))
      @button = AnimatedBitmap.new("Graphics/Pictures/Pokegear/icon_button_" + @image)
    else
      @button = AnimatedBitmap.new("Graphics/Pictures/Pokegear/icon_button")
    end
    @contents = BitmapWrapper.new(@button.width - 30, @button.height + 100)
    self.bitmap = @contents
    self.x = x 
    self.y = y - (@button.height / 2)
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def dispose
    @button.dispose
    @contents.dispose
    super
  end

  def selected=(val)
    oldsel = @selected
    @selected = val
    refresh if oldsel != val
  end

  def refresh
    self.bitmap.clear
    rect = Rect.new(0, 0, (@button.width / 2), @button.height)
    rect.x = @button.width / 2 if @selected
    self.bitmap.blt(0, 0, @button.bitmap, rect)
    textpos = [
      [@name, (rect.width / 2), rect.height, 2, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]
    ]
    pbDrawTextPositions(self.bitmap, textpos)
    imagepos = [
      [sprintf("Graphics/Pictures/Pokegear/icon_" + @image), 32, 10]
    ]
    pbDrawImagePositions(self.bitmap, imagepos)
  end
end

#===============================================================================
#
#===============================================================================
class Player < Trainer
  attr_accessor :phone_theme

  alias phone_theme_initialize initialize
  def initialize(name, trainer_type)
    phone_theme_initialize(name, trainer_type)
    @phone_theme = 1
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokegear_Scene
  attr_accessor :theme

  def pbUpdate
    @commands.length.times do |i|
      @sprites["button#{i}"].selected = (i == @index)
    end
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(commands)
    @commands = commands
    @index = 0
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @theme = $player.phone_theme.nil? ? 1 : $player.phone_theme
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    if $player.female? && pbResolveBitmap(sprintf("Graphics/Pictures/Pokegear/bg_f"))
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg_f")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg_#{@theme}")
    end
    @commands.length.times do |i|
      @sprites["button#{i}"] = PokegearButton.new(@commands[i], 70, 0, @viewport)
      button_width = @sprites["button#{i}"].bitmap.width / 1.33
      button_height = @sprites["button#{i}"].bitmap.height / 2
      @sprites["button#{i}"].x = 132 + ((i % 2) * button_width)
      @sprites["button#{i}"].y = 52 + (button_height * (i / 2)) 
    end
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbChangeBackground(themee)
    alpha = 0
    Graphics.update
    self.update
    timeTaken = Graphics.frame_rate * 4 / 10
    alphaDiff = (255.0 / timeTaken).ceil
    timeTaken.times do
      alpha += alphaDiff
      Graphics.update
      Input.update
      @sprites["background"].color = Color.new(248, 248, 248, alpha)
      self.update
    end
    @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg_#{theme}")
    (Graphics.frame_rate / 10).times do
      Graphics.update
      Input.update
      self.update
    end
    timeTaken.times do
      alpha -= alphaDiff
      Graphics.update
      Input.update
      @sprites["background"].color = Color.new(248, 248, 248, alpha)
      self.update
    end
  end

  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = @index
        break
      elsif Input.trigger?(Input::UP)
        pbPlayCursorSE if @commands.length > 1
        @index -= 2
        @index = @commands.length - 1 - (@index % 2) if @index < 0
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE if @commands.length > 1
        @index += 2
        @index = (@index % 2) if @index >= @commands.length
      elsif Input.trigger?(Input::LEFT)
        pbPlayCursorSE if @commands.length > 1
        @index -= 1
        @index = @commands.length - 1 if @index < 0
      elsif Input.trigger?(Input::RIGHT)
        pbPlayCursorSE if @commands.length > 1
        @index += 1
        @index = 0 if @index >= @commands.length
      end
    end
    return ret
  end

  def pbShowCommands(commands, index = 0)
    ret = -1
    cmdwindow = Window_CommandPokemon.new(commands)
    cmdwindow.viewport = @viewport
    cmdwindow.visible  = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    pbBottomRight(cmdwindow)
    cmdwindow.index = index
    loop do
      Graphics.update
      Input.update
      cmdwindow.update
      if Input.trigger?(Input::BACK)
        ret = -1
        break
      elsif Input.trigger?(Input::USE)
        ret = cmdwindow.index
        break
      end
      self.update
    end
    cmdwindow.dispose
    Input.update
    return ret
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    dispose
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokegearScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    # Get all commands
    command_list = []
    commands = []
    MenuHandlers.each_available(:pokegear_menu) do |option, hash, name|
      command_list.push([hash["icon_name"] || "", name])
      commands.push(hash)
    end
    @scene.pbStartScene(command_list)
    # Main loop
    end_scene = false
    loop do
      choice = @scene.pbScene
      if choice < 0
        end_scene = true
        break
      end
      break if commands[choice]["effect"].call(@scene)
    end
    @scene.pbEndScene if end_scene
  end
end

#===============================================================================
#
#===============================================================================
MenuHandlers.add(:pokegear_menu, :map, {
  "name"      => _INTL("Map"),
  "icon_name" => "map",
  "order"     => 10,
  "effect"    => proc { |menu|
    pbFadeOutIn {
      scene = PokemonRegionMap_Scene.new(-1, false)
      screen = PokemonRegionMapScreen.new(scene)
      ret = screen.pbStartScreen
      if ret
        $game_temp.fly_destination = ret
        menu.dispose
        next 99999
      end
    }
    next $game_temp.fly_destination
  }
})

MenuHandlers.add(:pokegear_menu, :phone, {
  "name"      => _INTL("Phone"),
  "icon_name" => "phone",
  "order"     => 20,
  "condition" => proc { next $PokemonGlobal.phoneNumbers && $PokemonGlobal.phoneNumbers.length > 0 },
  "effect"    => proc { |menu|
    pbFadeOutIn { PokemonPhoneScene.new.start }
    next false
  }
})

MenuHandlers.add(:pokegear_menu, :quests, {
  "name"      =>  _INTL("Quests"),
  "icon_name" => "quests",
  "order"     => 30,
  "condition" => proc { next hasAnyQuests? },
  "effect"    => proc { |menu|
    pbFadeOutIn {
      scene = QuestList_Scene.new
      screen = QuestList_Screen.new(scene)
      screen.pbStartScreen
    }
    next false
  }
})

MenuHandlers.add(:pokegear_menu, :jukebox, {
  "name"      => _INTL("Jukebox"),
  "icon_name" => "jukebox",
  "order"     => 40,
  "effect"    => proc { |menu|
    pbFadeOutIn {
      scene = PokemonJukebox_Scene.new
      screen = PokemonJukeboxScreen.new(scene)
      screen.pbStartScreen
    }
    next false
  }
})

MenuHandlers.add(:pokegear_menu, :themes, {
  "name"      => _INTL("Wallpaper"),
  "icon_name" => "themes",
  "order"     => 50,
  "effect"    => proc { |menu|
    command = 0
    loop do
      command = menu.pbShowCommands([_INTL("Lugia"),
                                     _INTL("Space"),
                                     _INTL("Lafayette"),
                                     _INTL("Flannel"),
                                     _INTL("Serenity"),
                                     _INTL("Cancel")], command)
      # Account for whether or not commands break
      break if (command == -1) || (command == 5) || (command == menu.theme - 1)
      $player.phone_theme = (command + 1)
      menu.theme = (command + 1)
      menu.pbChangeBackground(menu.theme)
      break
    end
  }
})

=begin 

MenuHandlers.add(:pokegear_menu, :fame_checker, {
  "name"      => _INTL("Profiles"),
  "icon_name" => "profiles",
  "order"     => 50,
  "effect"    => proc { |menu|
    next FameChecker.startFameChecker ? true : false
  }
})

=end 