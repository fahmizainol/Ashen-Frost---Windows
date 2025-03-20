#===============================================================================
# 
#                             Main Handler function
# 
#===============================================================================

class CaseUI
  attr_reader :value

  def initialize(picking = false, case_num = $PokemonGlobal.case_num)
    @picking = picking
    @case_num = case_num
    @value = nil
    if @picking
      scene = CaseUI_Evidence.new(@case_num, true)
      @value = scene.value
    elsif @case_num == 1
      scene = CaseUI_Evidence.new(@case_num)
    else
      scene = CaseUI_Menu_Scene.new(@case_num - 1)
      screen = CaseUI_Menu_Screen.new(scene)
      screen.pbStartScreen
    end 
  end
end


  #===============================================================================
  #
  #===============================================================================
class CaseUI_Menu_Screen

  def initialize(scene)
    @scene = scene
  end
  
  def pbStartScreen
    @scene.pbStartScene
    loop do
      cmd = @scene.pbScene
      if cmd == nil || cmd < 0
        pbPlayCloseMenuSE
        break
      elsif cmd.between?(1,  $PokemonGlobal.case_num) || cmd.between?(50, 52)
        scene = CaseUI_Evidence.new(cmd)
      else   # Exit
        pbPlayCloseMenuSE
        break
      end
    end
    @scene.pbEndScene
  end
end
  
#===============================================================================
#
#===============================================================================
class CaseUI_Menu_Scene
  TEXT_BASE_COLOR   = MessageConfig::DARK_TEXT_MAIN_COLOR
  TEXT_SHADOW_COLOR = MessageConfig::DARK_TEXT_SHADOW_COLOR

  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbStartScene
    # Determines what menu to open
    @main = true
    # Main Quests - set order - less of a pain
    @main_cases = []
    for i in 0.. $PokemonGlobal.case_num - 1
      @main_cases[i] = _INTL(get_case_names(i + 1))
    end
    @main_cases[@main_cases.length] = _INTL("Exit")
    # Side Cases - set based on whether or not unlocked
    @side_cases = []
    for num in  $PokemonGlobal.side_case
      @side_cases[ $PokemonGlobal.side_case.index(num)] = _INTL(get_case_names(num))
    end
    @side_cases[@side_cases.length] = _INTL("Exit")
    @viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(_INTL("Main Cases"), 92, 6, 172, 64, @viewport)
    @sprites["header"].baseColor   = TEXT_BASE_COLOR
    @sprites["header"].shadowColor = TEXT_SHADOW_COLOR
    @sprites["header"].windowskin  = nil
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Evidence/UI/case_menu_1")
    # Case list
    @sprites["casewindow"] = Window_CommandPokemon.newWithSize(@main_cases, 12, 62, 490, 320, @viewport)
    @sprites["casewindow"].index       = @menu_index
    @sprites["casewindow"].baseColor   = TEXT_BASE_COLOR
    @sprites["casewindow"].shadowColor = TEXT_SHADOW_COLOR
    @sprites["casewindow"].windowskin  = nil
    # Show left and right arrows for side cases
    if  $PokemonGlobal.side_case.length > 0 
      @sprites["leftarrow"]=AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
      @sprites["leftarrow"].play
      @sprites["leftarrow"].x = -4
      @sprites["leftarrow"].y=Graphics.height / 2 - 20
      @sprites["rightarrow"]=AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
      @sprites["rightarrow"].play
      @sprites["rightarrow"].x=Graphics.width - 38
      @sprites["rightarrow"].y=Graphics.height / 2 - 20
    end
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
  
  def get_case_names(int)
    case_names = {
      # Main Cases
      1  => "Case One: Safety First",
      2  => "Case Two: Man's Greatest Vice",
      3  => "Case Three: Missing the Point",
      4  => "Case Four: May Flowers",
      5  => "Case Five: Lu3",
      6  => "Case Six: Lafayette, Lonardo, Palermo",
      7  => "Case Seven: Phantom Threads",
      8  => "Case Eight: Bee Meri",
      9  => "Case Nine: Sunglow",
      10 => "Case Ten: Cascade Capers",
      11 => "Case Eleven: Trebel in Paradise",
      12 => "Case Twelve: Meanwhile with Mordecai",
      13 => "Case Thirteen: Verrine's Advocate",
      14 => "Case Fourteen: Pearls of Wisdom",
      15 => "Case Fifteen: Nautical Nonsense",
      16 => "Case Sixteen: Lost and Found",
      17 => "Case Seventeen: Whispers of the Desert",
      18 => "Case Eighteen: Teacher's Pet",
      19 => "Case Nineteen: Starry Soirée", 
      20 => "Case Twenty: End of the Line",
      # Side Cases
      50 => "The River's Base",
      51 => "Detective Mr. Fluffy",
      52 => "The Desert Rider"
    }
    return case_names[int]
  end

  def switch_menu
    # Method for switching between main case and
    # side case menu
    if @main
      # Switch image
      @sprites["background"].setBitmap("Graphics/Evidence/UI/case_menu_2")
      # Change cases and update index
      @sprites["casewindow"].commands = @side_cases
      @sprites["casewindow"].index = 0
      # Switch header
      @sprites["header"].text = _INTL("Side Cases")
      # Switch variable
      @main = false
    else
      # Switch image
      @sprites["background"].setBitmap("Graphics/Evidence/UI/case_menu_1")
      # Change cases and update index
      @sprites["casewindow"].commands = @main_cases
      @sprites["casewindow"].index = 0
      # Switch header
      @sprites["header"].text = _INTL("Main Cases")
      # Switch variable
      @main = true
    end
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
        ret = @main ? @sprites["casewindow"].index + 1 :  $PokemonGlobal.side_case[@sprites["casewindow"].index]
        break
      elsif (Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)) &&  $PokemonGlobal.side_case.length > 0
        switch_menu
      end
    end
    return ret
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end 
end 

#===============================================================================
# Evidence UI Handler
#===============================================================================
class CaseUI_Evidence
  attr_reader :value

  def initialize(case_num, picking = false)
    showBlk
    @picking = picking
    @value = nil
    @case_num = case_num
    @index = 0
    @top_index = 0
    @evidence_data = Evidence.compiledData()
    @evidence_count = 0
    # Add evidence counter
    @evidence_data.each do |name, data|
      @evidence_count += 1 if data[:Case].include?(@case_num) 
    end
    @evidence = []
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = SpriteHash.new
    @sprites["bg"] = DynamicSprite.new(@viewport)
    @sprites["bg"].bitmap = Bitmap.new("Graphics/Evidence/UI/evidence_menu")
    @sprites["bg"].set_cell(Graphics.width, Graphics.height)
    @sprites["list"] = SpriteHash.new
    @sprites["up"] = Sprite.new(@viewport)
    @sprites["up"].bmp("Graphics/Evidence/UI/list_arrow")
    @sprites["up"].angle = 180
    @sprites["up"].x = 356 + @sprites["up"].bmp.width
    @sprites["up"].y = 116
    @sprites["up"].z = 1
    @sprites["down"] = Sprite.new(@viewport)
    @sprites["down"].bmp("Graphics/Evidence/UI/list_arrow")
    @sprites["down"].x = 356
    @sprites["down"].y = Graphics.height - 26
    @sprites["down"].z = 1
    @sprites["npcbox"] = Sprite.new(@viewport)
    @sprites["npcbox"].bmp("Graphics/Evidence/UI/box_icon")
    @sprites["npcbox"].x = 416
    @sprites["npcbox"].y = 256
    @sprites["npc"] = Sprite.new(@viewport)
    @sprites["npc"].x = @sprites["npcbox"].x + 4
    @sprites["npc"].y = @sprites["npcbox"].y + 2
    # Draw text for Evidence found
    @sprites["found"] = Window_UnformattedTextPokemon.newWithSize(_INTL(""), 334, 2, 172, 64, @viewport)
    @sprites["found"].baseColor   = Color.new(0,0,19)
    @sprites["found"].shadowColor = Color.new(176,176,176)
    @sprites["found"].windowskin  = nil
    @sprites["found"].z = 1
=begin
    @sprites["evbox"] = Sprite.new(@viewport)
    @sprites["evbox"].bmp("Graphics/Evidence/UI/box_icon")
    @sprites["evbox"].x = 450
    @sprites["evbox"].y = 2
    @sprites["ev"] = Sprite.new(@viewport)
    @sprites["ev"].x = @sprites["evbox"].x + 6
    @sprites["ev"].y = @sprites["evbox"].y + 6
=end
    @sprites["examine"] = Sprite.new(@viewport)
    @sprites["examine"].bmp("Graphics/Evidence/UI/box_examine")
    @sprites["examine"].x = 390
    @sprites["examine"].y = 76
    if @picking
      @sprites["present"] = Sprite.new(@viewport)
      @sprites["present"].bmp("Graphics/Evidence/UI/box_present")
      @sprites["present"].x = 390
      @sprites["present"].y = 156
    end
    draw_list
    hideBlk
    main
  end

  def draw_list
    @sprites["list"].dispose
    y = 0
    # boxbmp = RPG::Cache.load_bitmap("Graphics/Evidence/UI/", "box_small")
    @evidence.clear
    $PokemonGlobal.evidence.each do |name, map|
      data = @evidence_data[name]
      @evidence << name if data[:Case].include?(@case_num)
    end
    @sprites["up"].visible = false
    @sprites["down"].visible = false
    @sprites["examine"].visible = false
    @sprites["npc"].bmp.dispose if @sprites["npc"].bmp
    # @sprites["ev"].bmp.dispose if @sprites["ev"].bmp
    for i in 0...4
      real_index = @top_index + i
      break if real_index >= @evidence.size
      selected = real_index == @top_index + @index
      intname = @evidence[real_index]
      data = @evidence_data[intname]
      @sprites["list"][i] = Sprite.new(@viewport)
      @sprites["list"][i].y = y
      @sprites["list"][i].bmp(384, selected ? 384 : 32)
      pbSetSystemFont(@sprites["list"][i].bmp)
      textpos = []
      if selected
      #  4.times { |j| @sprites["list"][i].bmp.blt(0,j*32,boxbmp,Rect.new(0,0,boxbmp.width,boxbmp.height)) }
      #  largebox = RPG::Cache.load_bitmap("Graphics/Evidence/UI/", "box_large")
      #  @sprites["list"][i].bmp.blt(0,128,largebox,Rect.new(0,0,largebox.width,largebox.height))
      #  largebox.dispose
        arrow = RPG::Cache.load_bitmap("Graphics/Evidence/UI/","arrow")
        @sprites["list"][i].bmp.blt(356, 12, arrow, Rect.new(0,0,arrow.width,arrow.height))
        arrow.dispose
        textpos << [data[:Name], 164, 26, 2, Color.new(0,0,19), Color.new(176, 176, 176)]
        textpos << ["Obtained: " +  $PokemonGlobal.evidence.find { |ev, map| ev == intname }[1], 24, 100, 0,
            Color.new(0,0,19),Color.new(176,176,176)]
        textpos << ["For: " + data[:Use], 24, 160, 0,
            Color.new(0,0,19),Color.new(176,176,176)]
        drawTextEx(@sprites["list"][i].bmp,
            24, 228, 354, 0, data[:Description], Color.new(0,0,19), Color.new(176,176,176)
        )
        @sprites["npc"].bmp("Graphics/Evidence/Icons/#{intname.to_s.downcase}")
=begin
        if data[:Testimony]
          @sprites["ev"].bmp("Graphics/Evidence/UI/icon_testimony")
        else
          @sprites["ev"].bmp("Graphics/Evidence/UI/icon_clue")
        end
=end
        @sprites["examine"].visible = !data[:Testimony]
        @sprites["found"].text = _INTL("Found: #{@evidence.count}/#{@evidence_count}")
        y += 384
     #  else
     #   textpos << [data[:Name],6,0,0,Color.new(0,0,19),Color.new(176,176,176)]
     #   y += 32 # EKAT BOOKMARK
      
      end
      pbDrawTextPositions(@sprites["list"][i].bmp, textpos)
    end
  #  boxbmp.dispose
    @sprites["up"].visible = @top_index + @index > 0
    @sprites["down"].visible = @top_index + @index < @evidence.size - 1
  end

  def examine_evidence
    blk = Sprite.new(@viewport)
    blk.bmp(-1,-1)
    blk.bmp.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0,0,0))
    blk.opacity = 0
    blk.z = 1
    img = Sprite.new(@viewport)
    img.bmp("Graphics/Evidence/Clues/" + @evidence[@top_index + @index].to_s.downcase)
    img.opacity = 0
    img.z = 1
    32.times { Graphics.update; Input.update; update; blk.opacity += 8 }
    32.times { Graphics.update; Input.update; img.opacity += 8 }
    until Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
      Graphics.update
      Input.update
    end
    32.times { Graphics.update; Input.update; img.opacity -= 8 }
    32.times { Graphics.update; Input.update; update; blk.opacity -= 8 }
  end

  def main
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::BACK)
      if Input.press?(Input::ACTION) && !@evidence.empty?
        if !@evidence_data[@evidence[@top_index + @index]][:Testimony]
          examine_evidence
        end
      end
      if Input.trigger?(Input::USE)
        if @picking
          if !@evidence.empty?
            @value = @evidence[@top_index + @index]
          end
          break
        end
      end
      if Input.trigger?(Input::DOWN)
        if @index == 2 && @top_index + 4 < @evidence.size
          @top_index += 1
          draw_list
        elsif @top_index + @index < @evidence.size - 1
          @index += 1
          draw_list
        end
      end
      if Input.trigger?(Input::UP)
        if @index == 1 && @top_index > 0
          @top_index -= 1
          draw_list
        elsif @index > 0
          @index -= 1
          draw_list
        end
      end
      update
    end
    dispose
  end

  def update
    @i ||= 0
    mps = 3
    if @i % mps == 0
      case @i / mps
      when 1,2,3
        @sprites["up"].y -= 1
        @sprites["down"].y += 1
      when 4,5,6,7,8,9
        @sprites["up"].y += 1
        @sprites["down"].y -= 1
      when 10,11,12
        @sprites["up"].y -= 1
        @sprites["down"].y += 1
      end
    end
    @i = 0 if @i == 12 * mps
    @i += 1
  end
  
  def dispose
    showBlk
    @sprites.dispose
    @viewport.dispose
    hideBlk
  end
end

  