#===============================================================================
#
#===============================================================================
class PokemonJukebox_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(commands)
    @commands = commands
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/jukeboxbg")
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL(""), 2, -18, 128, 64, @viewport
    )
    @sprites["header"].baseColor   = Color.new(248, 248, 248)
    @sprites["header"].shadowColor = Color.new(0, 0, 0)
    @sprites["header"].windowskin  = nil
    @sprites["commands"] = Window_CommandPokemon.newWithSize(
      @commands, 24, 92, 460, 224, @viewport
    )
    @sprites["commands"].windowskin = nil
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        break
      elsif Input.trigger?(Input::USE)
        ret = @sprites["commands"].index
        break
      end
    end
    return ret
  end

  def pbSetCommands(newcommands, newindex)
    @sprites["commands"].commands = (!newcommands) ? @commands : newcommands
    @sprites["commands"].index    = newindex
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonJukeboxScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    commands = []
    cmdTurnOff = -1
    Dir.chdir("Audio/BGM/") {
      Dir.glob("*.ogg") { |f| commands.push(f) }
      Dir.glob("*.wav") { |f| commands.push(f) }
      Dir.glob("*.mid") { |f| commands.push(f) }
      Dir.glob("*.midi") { |f| commands.push(f) }
    }
    commands.map! { |f| f.chomp(File.extname(f)) }
    commands.uniq!
    commands.sort! { |a, b| a.downcase <=> b.downcase }
    commands[cmdTurnOff = commands.length] = _INTL("Stop")
    commands[cmdExit = commands.length]    = _INTL("Exit")
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
      if cmd < 0 || cmdExit >= 0 && cmd == cmdExit
        pbPlayCloseMenuSE
        break
      elsif cmdTurnOff >= 0 && cmd == cmdTurnOff
        pbPlayDecisionSE
        $game_system.setDefaultBGM(nil)
        pbBGMPlay(pbResolveAudioFile($game_map.bgm_name, $game_map.bgm.volume, $game_map.bgm.pitch))
        $PokemonMap.whiteFluteUsed = false if $PokemonMap
        $PokemonMap.blackFluteUsed = false if $PokemonMap
      else   # Exit
        pbPlayDecisionSE
        $game_system.setDefaultBGM(commands[cmd])
        $PokemonMap.whiteFluteUsed = false if $PokemonMap
        $PokemonMap.blackFluteUsed = false if $PokemonMap
      end
    end
    @scene.pbEndScene
  end
end
