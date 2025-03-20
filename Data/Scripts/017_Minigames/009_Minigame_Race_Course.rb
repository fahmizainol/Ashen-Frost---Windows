#===============================================================================
# Racecourse(minigame) by bo4p5687
#===============================================================================
#
# How to use:
#  call script: pbRaceGame
#  
#===============================================================================
#
# To this script works, put it above main.
#
#===============================================================================
#===============================================================================
#------------------------------------------------------------------------------#
# Here, you can change numbers
#------------------------------------------------------------------------------#
# Name of graphics: %w{Name1 Name2 Name3 Namex}
CANDIDAT = %w{RAPIDASH STANTLER NOSEPASS GASTRODON}
CANDIDAT_ID = %w{078 234 299 423}
NUMBER_RACEGAME = 
[
{
# Number announcement, graphics's name => [x,y]
# x,y: coordinate of the graphic
"1" => [162,71],
"2" => [162,71],
"3" => [162,71]
},
# Name of graphics: %w{Name1 Name2 Name3 Namex}
%w{Number1 Number2 Number3 Number4},
# [x,y]: position number before play
[13,88],
# y value: change after race (+),ex: 88+75
75
]
FIRST_SCREEN_RACEGAME =
# Name of graphics: %w{Name1 Name2 Name3 Namex}
%w{Screen Play Quit Select},
# [x,y] of "above" graphics
[
[0,0],
[220,226],
[220,286],
[170,232,60] # [x,y,i]: y' = y + i 
]
SECOND_SCREEN_RACEGAME = 
# Name of graphics: %w{Name1 Name2 Name3 Namex}
%w{Choice Title},
# [x,y] of "above" graphics
[
[0,0],
[0,0]
]
COIN_RACEGAME = 
{
# Image's name => Coin (number)
"Coin1" => 1,
"Coin2" => 12,
"Coin3" => 5,
"Coin4" => 17,
"Coin5" => 7,
"Coin6" => 24
}
POSITION_COIN_RACEGAME =
[
# [x,y]; x,y: coordinate of the graphic
[20,114],
[271,114],
[20,204],
[271,204],
[20,294],
[271,294]
]
OPACITY_COIN_RACEGAME = 
[
# Opacity [don't choose, choose]
[155,255],
[155,255],
[155,255],
[155,255],
[155,255],
[155,255]
]
SCREEN_CHOICE_POSITION_POKE_RACEGAME = 
[
# [x,y]; x,y: coordinate of the graphic
[120,17],
[322,17],
[120,207],
[322,207]
]
SCREEN_CHOICE_OPACITY_POKE_RACEGAME = 
[
# Opacity [don't choose, choose]
[155,255],
[155,255],
[155,255],
[155,255]
]
# Graphic's name, [x,y]: coordinate of the graphic (first), distance between 2 choices, 
# visible bar when play.
CHOOSE_BAR_RACEGAME = ["Choose", [0,78], 74, true] 
# Position pokemon before race: [x,y]: above, y: distance between 2 pokemon
POSITION_PKM_RACEGAME = [[400,51],75]
CONTINUE_SCREEN_RACEGAME = 
{
# continue screen's name => [x,y] 
# x,y: coordinate of the graphic 
"ScreenContinue" => [0,0],
"Select" => [143,172,110] # [x,y,i]: y' = y + i 
}
#------------------------------------------------------------------------------#
# Don't change below
#------------------------------------------------------------------------------#

class RaceGame
  
  def initialize
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @viewport1=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport1.z=99998
    @viewport2=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport2.z=99997
    @viewport3=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport3.z=99999
    @sprites = {}
    @coin = {}
    @animation = 0
    @range = [0,0,0,0]
    @finish_course =[false,false,false,false]
    @rank_count = [0,0,0,0]
    @marked = [false,false,false,false]
    @win = nil
    @time = 0
    @process = 0
    @select = true; @selecttwo =0; @selectcoin = 0; @choose = 0; @check = true
    @continue = true
    @exit = false
  end
  
#------------------------------------------------------------------------------#
# Draw graphics
#------------------------------------------------------------------------------#

  def drawScene
    # Grass
    @sprites["grass"] = AnimatedPlane.new(@viewport1)
    @sprites["grass"].bitmap = Bitmap.new("Graphics/Pictures/Racecourse/Grass")
    # Scene
    @sprites["scene"] = Sprite.new(@viewport1)
    @sprites["scene"].bitmap = Bitmap.new("Graphics/Pictures/Racecourse/Racetrack")
    @sprites["scene"].x = 0
    @sprites["scene"].y = 0
    @sprites["scene"].src_rect.x = 500
    @sprites["scene"].src_rect.y = 0
  end
  
  def draw_coin_box
    @sprites["coinbox"] = Sprite.new(@viewport3)
    @sprites["coinbox"].bitmap = Bitmap.new("Graphics/Pictures/Racecourse/CoinBox")
    @sprites["coinbox"].x = 0
    @sprites["coinbox"].y = 0
    @sprites["coinbox"].visible = false
  end
  
  def coin_box
    @coin = Sprite.new(@viewport3)
    @coin.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @coin.bitmap.font.size = 88
    textposition = []
    textposition.push([_INTL("{1}",$player.coins.to_s),@sprites["coinbox"].bitmap.width - 64,204,true,Color.new(226,223,223),Color.new(0,0,0)])
    pbDrawTextPositions(@coin.bitmap,textposition)
  end
  
  def draw_choice_first
    (0...FIRST_SCREEN_RACEGAME[0].size).each {|i|
    @sprites["#{FIRST_SCREEN_RACEGAME[0][i]}"] = Sprite.new(@viewport2)
    @sprites["#{FIRST_SCREEN_RACEGAME[0][i]}"].bitmap = Bitmap.new("Graphics/Pictures/Racecourse/#{FIRST_SCREEN_RACEGAME[0][i]}")
    @sprites["#{FIRST_SCREEN_RACEGAME[0][i]}"].x = FIRST_SCREEN_RACEGAME[1][i][0]
    @sprites["#{FIRST_SCREEN_RACEGAME[0][i]}"].y = FIRST_SCREEN_RACEGAME[1][i][1]
    }
  end

  def draw_choice_second
    (0...SECOND_SCREEN_RACEGAME[0].size).each {|i|
    @sprites["#{SECOND_SCREEN_RACEGAME[0][i]}"] = Sprite.new(@viewport2)
    @sprites["#{SECOND_SCREEN_RACEGAME[0][i]}"].bitmap = Bitmap.new("Graphics/Pictures/Racecourse/#{SECOND_SCREEN_RACEGAME[0][i]}")
    @sprites["#{SECOND_SCREEN_RACEGAME[0][i]}"].x = SECOND_SCREEN_RACEGAME[1][i][0]
    @sprites["#{SECOND_SCREEN_RACEGAME[0][i]}"].y = SECOND_SCREEN_RACEGAME[1][i][1]
    }
  end
  
  def draw_continue
    (0...CONTINUE_SCREEN_RACEGAME.size).each {|i|
    @sprites["Ctn #{CONTINUE_SCREEN_RACEGAME.keys[i]}"] = Sprite.new(@viewport3)
    @sprites["Ctn #{CONTINUE_SCREEN_RACEGAME.keys[i]}"].bitmap = Bitmap.new("Graphics/Pictures/Racecourse/#{CONTINUE_SCREEN_RACEGAME.keys[i]}")
    @sprites["Ctn #{CONTINUE_SCREEN_RACEGAME.keys[i]}"].x = CONTINUE_SCREEN_RACEGAME.values[i][0]
    @sprites["Ctn #{CONTINUE_SCREEN_RACEGAME.keys[i]}"].y = CONTINUE_SCREEN_RACEGAME.values[i][1]
    }
  end
  
  def draw_choice_poke
    (0...CANDIDAT.size).each {|i|
    @sprites["poke#{i}"] = Sprite.new(@viewport2)
    if File.exist?("Graphics/Pokemon/Front/#{CANDIDAT[i]}.png")
      @sprites["poke#{i}"].bitmap = Bitmap.new("Graphics/Pokemon/Front/#{CANDIDAT[i]}")
    else
      @sprites["poke#{i}"].bitmap = Bitmap.new("Graphics/Pokemon/#{CANDIDAT[i]}")
    end
    @sprites["poke#{i}"].x = SCREEN_CHOICE_POSITION_POKE_RACEGAME[i][0]
    @sprites["poke#{i}"].y = SCREEN_CHOICE_POSITION_POKE_RACEGAME[i][1]
    @sprites["poke#{i}"].opacity = SCREEN_CHOICE_OPACITY_POKE_RACEGAME[i][0]
    }
  end
  
  def draw_coin
    @sprites["coin"] = Sprite.new(@viewport2)
    @sprites["coin"].bitmap = Bitmap.new("Graphics/Pictures/Racecourse/ScreenCoin")
    @sprites["coin"].x = 0; @sprites["coin"].y = 0
    (0...COIN_RACEGAME.size).each {|i|
    @sprites["#{COIN_RACEGAME.keys[i]}"] = Sprite.new(@viewport2)
    @sprites["#{COIN_RACEGAME.keys[i]}"].bitmap = Bitmap.new("Graphics/Pictures/Racecourse/#{COIN_RACEGAME.keys[i]}")
    @sprites["#{COIN_RACEGAME.keys[i]}"].x = POSITION_COIN_RACEGAME[i][0]
    @sprites["#{COIN_RACEGAME.keys[i]}"].y = POSITION_COIN_RACEGAME[i][1]
    @sprites["#{COIN_RACEGAME.keys[i]}"].opacity = OPACITY_COIN_RACEGAME[i][0]
    }
  end

  def draw_poke
    (0...CANDIDAT_ID.size).each {|i|
    if @selecttwo == i
      (0...CANDIDAT_ID.size).each {|j|
      @sprites["player#{i} #{j}"] = Sprite.new(@viewport)
      @sprites["player#{i} #{j}"].bitmap = Bitmap.new("Graphics/Characters/#{CANDIDAT_ID[i]}")
      @sprites["player#{i} #{j}"].zoom_x = 1.5
      @sprites["player#{i} #{j}"].zoom_y = 1.5
      @sprites["player#{i} #{j}"].src_rect.width = @sprites["player#{i} #{j}"].bitmap.width/4
      @sprites["player#{i} #{j}"].src_rect.height = @sprites["player#{i} #{j}"].bitmap.height/4
      @sprites["player#{i} #{j}"].src_rect.x = 0
      @sprites["player#{i} #{j}"].src_rect.y = @sprites["player#{i} #{j}"].src_rect.height
      @sprites["player#{i} #{j}"].x = POSITION_PKM_RACEGAME[0][0]
      @sprites["player#{i} #{j}"].y = POSITION_PKM_RACEGAME[0][1] + POSITION_PKM_RACEGAME[1]*j }
    end }
  end
  
  def draw_announcement
    (0...NUMBER_RACEGAME[0].size).each {|i|
    @sprites["announ #{NUMBER_RACEGAME[0].keys[NUMBER_RACEGAME[0].size-1-i]}"] = Sprite.new(@viewport1)
    @sprites["announ #{NUMBER_RACEGAME[0].keys[NUMBER_RACEGAME[0].size-1-i]}"].bitmap = Bitmap.new("Graphics/Pictures/Racecourse/#{NUMBER_RACEGAME[0].keys[NUMBER_RACEGAME[0].size-1-i]}")
    @sprites["announ #{NUMBER_RACEGAME[0].keys[NUMBER_RACEGAME[0].size-1-i]}"].x = NUMBER_RACEGAME[0].values[i][0]
    @sprites["announ #{NUMBER_RACEGAME[0].keys[NUMBER_RACEGAME[0].size-1-i]}"].y = NUMBER_RACEGAME[0].values[i][1]
    @sprites["announ #{NUMBER_RACEGAME[0].keys[NUMBER_RACEGAME[0].size-1-i]}"].visible = false
    pbWait(0.5)
    @sprites["announ #{NUMBER_RACEGAME[0].keys[NUMBER_RACEGAME[0].size-1-i]}"].visible = true
    pbSEPlay("Battle ball drop")
    pbWait(0.5)
    pbDisposeSprite(@sprites,"announ #{NUMBER_RACEGAME[0].keys[NUMBER_RACEGAME[0].size-1-i]}") }
    pbSEPlay("GUI sel buzzer")
  end
  
  def choice
    @sprites["#{CHOOSE_BAR_RACEGAME[0]}"] = Sprite.new(@viewport3)
    @sprites["#{CHOOSE_BAR_RACEGAME[0]}"].bitmap = Bitmap.new("Graphics/Pictures/Racecourse/#{CHOOSE_BAR_RACEGAME[0]}")
    @sprites["#{CHOOSE_BAR_RACEGAME[0]}"].x = CHOOSE_BAR_RACEGAME[1][0]
    @sprites["#{CHOOSE_BAR_RACEGAME[0]}"].y = CHOOSE_BAR_RACEGAME[1][1]
  end
  
  # Rank number
  def number
	(0...CANDIDAT.size).each{|j|
    (0...NUMBER_RACEGAME[1].size).each {|i|
    @sprites["#{NUMBER_RACEGAME[1][i]} #{j}"] = Sprite.new(@viewport1)
    @sprites["#{NUMBER_RACEGAME[1][i]} #{j}"].bitmap = Bitmap.new("Graphics/Pictures/Racecourse/#{NUMBER_RACEGAME[1][i]}")
    @sprites["#{NUMBER_RACEGAME[1][i]} #{j}"].x = NUMBER_RACEGAME[2][0]
    @sprites["#{NUMBER_RACEGAME[1][i]} #{j}"].y = NUMBER_RACEGAME[2][1]
    @sprites["#{NUMBER_RACEGAME[1][i]} #{j}"].visible = false
    }}
  end
  
#------------------------------------------------------------------------------#
# Play 
#------------------------------------------------------------------------------#

  #Start
  def pbStart
    if $bag.quantity(:COINCASE) <= 0
      pbMessage(_INTL("It's a Racecourse Game."))
    else
      if $player.coins == 0
        pbMessage(_INTL("\\CNYou don't have enough Coins to play!"))
      else
        # Draw scene (first)
        draw_choice_first
        loop do
          update_ingame # Update graphics, input
          break if @exit
          in_loop_progress
        end
      end
    end
    pbEndScene
  end
  
  def in_loop_progress
    case @process
    when 0
      if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        if @select
          @select = false
          @sprites["#{FIRST_SCREEN_RACEGAME[0][3]}"].y = FIRST_SCREEN_RACEGAME[1][3][1] + FIRST_SCREEN_RACEGAME[1][3][2]
        else
          @select = true
          @sprites["#{FIRST_SCREEN_RACEGAME[0][3]}"].y = FIRST_SCREEN_RACEGAME[1][3][1]
        end
      end
      if Input.trigger?(Input::C)
        # Dispose images
        dispose
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        if @select 
          # Draw scene
          draw_choice_second
          draw_choice_poke
          # Set poke's opacity before choice
          select_two_after_choice
          # Next
          @process = 1
        else
          # Exit
          @exit = true
        end
      end
    when 1
      if Input.trigger?(Input::DOWN)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        if (CANDIDAT.size) %2 == 0
          @selecttwo += (CANDIDAT.size)/2 
          if @selecttwo %2 == 0
            @selecttwo -= (CANDIDAT.size) if @selecttwo >= (CANDIDAT.size)
          else
            @selecttwo -= (CANDIDAT.size) if @selecttwo > (CANDIDAT.size)
          end
        else
          @selecttwo -= (CANDIDAT.size+1)/2
          @selecttwo = (CANDIDAT.size-1)/2 if @selecttwo == (CANDIDAT.size-1)/2
          if @selecttwo %2 == 0
            @selecttwo -= (CANDIDAT.size)+1 if @selecttwo > (CANDIDAT.size)
          else
            @selecttwo -= (CANDIDAT.size)-1 if @selecttwo >= (CANDIDAT.size)
          end
        end        
        # Set opacity
        select_two_after_choice
      end
      if Input.trigger?(Input::UP)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        if (CANDIDAT.size)%2 == 0
          @selecttwo -= (CANDIDAT.size)/2 
          if @selecttwo %2 == 0
            @selecttwo = (CANDIDAT.size)-2 if @selecttwo < 0
          else
            @selecttwo = (CANDIDAT.size)-1 if @selecttwo < 1
          end
        else
          @selecttwo -= (CANDIDAT.size+1)/2
          @selecttwo = (CANDIDAT.size-1)/2 if @selecttwo == (CANDIDAT.size-1)/2
          if @selecttwo %2 == 0
            @selecttwo = (CANDIDAT.size)-1 if @selecttwo < 0
          else
            @selecttwo = (CANDIDAT.size)-2 if @selecttwo < 1
          end
        end
        # Set opacity
        select_two_after_choice
      end
      if Input.trigger?(Input::RIGHT)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        @selecttwo += 1
        @selecttwo = 0 if @selecttwo == (CANDIDAT.size)
        # Set opacity
        select_two_after_choice
      end
      if Input.trigger?(Input::LEFT)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        @selecttwo -= 1
        @selecttwo = (CANDIDAT.size)-1 if @selecttwo < 0
        # Set opacity
        select_two_after_choice
      end
      if Input.trigger?(Input::C)
        # Dispose images
        dispose
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        # Draw
        draw_coin
        draw_coin_box
        # Set coin's opacity before choice
        select_coin_after_choice
        @process = 2
      end
    when 2
      if Input.trigger?(Input::DOWN)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        if (POSITION_COIN_RACEGAME.size) %2 == 0
          @selectcoin += (POSITION_COIN_RACEGAME.size)/2 
          if @selectcoin %2 == 0
            @selectcoin -= (POSITION_COIN_RACEGAME.size) if @selectcoin >= (POSITION_COIN_RACEGAME.size)
          else
            @selectcoin -= (POSITION_COIN_RACEGAME.size) if @selectcoin > (POSITION_COIN_RACEGAME.size)
          end
        else
          @selectcoin -= (POSITION_COIN_RACEGAME.size+1)/2
          @selectcoin = (POSITION_COIN_RACEGAME.size-1)/2 if @selectcoin == (POSITION_COIN_RACEGAME.size-1)/2
          if @selectcoin %2 == 0
            @selectcoin -= (POSITION_COIN_RACEGAME.size)+1 if @selectcoin > (POSITION_COIN_RACEGAME.size)
          else
            @selectcoin -= (POSITION_COIN_RACEGAME.size)-1 if @selectcoin >= (POSITION_COIN_RACEGAME.size)
          end
        end
        # Set coin
        select_coin_after_choice
      end
      if Input.trigger?(Input::UP)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        if (POSITION_COIN_RACEGAME.size)%2 == 0
          @selectcoin -= (POSITION_COIN_RACEGAME.size)/2 
          if @selectcoin %2 == 0
            @selectcoin = (POSITION_COIN_RACEGAME.size)-2 if @selectcoin < 0
          else
            @selectcoin = (POSITION_COIN_RACEGAME.size)-1 if @selectcoin < 1
          end
        else
          @selectcoin -= (POSITION_COIN_RACEGAME.size+1)/2
          @selectcoin = (POSITION_COIN_RACEGAME.size-1)/2 if @selectcoin == (POSITION_COIN_RACEGAME.size-1)/2
          if @selectcoin %2 == 0
            @selectcoin = (POSITION_COIN_RACEGAME.size)-1 if @selectcoin < 0
          else
            @selectcoin = (POSITION_COIN_RACEGAME.size)-2 if @selectcoin < 1
          end
        end
        # Set coin
        select_coin_after_choice
      end
      if Input.trigger?(Input::RIGHT)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        @selectcoin += 1
        @selectcoin = 0 if @selectcoin == (POSITION_COIN_RACEGAME.size)
        # Set coin
        select_coin_after_choice
      end
      if Input.trigger?(Input::LEFT)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        @selectcoin -= 1
        @selectcoin = ((POSITION_COIN_RACEGAME.size)-1) if @selectcoin < 0
        # Set coin
        select_coin_after_choice
      end
      if Input.trigger?(Input::A)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        if @check
          @sprites["coinbox"].visible = true
          coin_box
          @check = false
        else
          @sprites["coinbox"].visible = false
          @coin.visible = false
          @coin.bitmap.clear
          @check = true
        end
      end
      if Input.trigger?(Input::B)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        if !@check
          @exit = true
        end
      end
      if Input.trigger?(Input::C)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        # Calc coin
        if $player.coins < COIN_RACEGAME.values[@selectcoin] || $player.coins == 0
          pbMessage(_INTL("You don't have enough Coins!"))
        else
          $player.coins -= COIN_RACEGAME.values[@selectcoin]
          #Dispose images
          dispose
          # Draw
          draw_poke
          drawScene
          choice
          # Position bar
          choose_bar_visible
          @process = 3
        end
      end
    when 3
      if Input.trigger?(Input::DOWN)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        @choose += 1
        @choose = 0 if @choose == (CANDIDAT.size)
        # Position bar
        choose_bar_visible
      end
      if Input.trigger?(Input::UP)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        @choose -= 1
        @choose = (CANDIDAT.size)-1 if @choose < 0
        # Position bar
        choose_bar_visible
      end
      if Input.trigger?(Input::C)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        if CHOOSE_BAR_RACEGAME[3] 
          @sprites["#{CHOOSE_BAR_RACEGAME[0]}"].visible = true
        else
          # Dispose sprite "bar"
          pbDisposeSprite(@sprites,"#{CHOOSE_BAR_RACEGAME[0]}")
        end
        # Draw and display
        draw_announcement
        @process = 4
      end
    when 4
      # Play and next process
      play
    when 5
      # Order pokemon
      define_order
    when 6
      if @choose == @win
        coin_plus_or_minus 
      else
        pbMessage(_INTL("\\wuYou lose!"))
      end
      # Dispose
      dispose
      # Draw
      draw_continue
      @process = 7
    when 7
      if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        if @continue 
          @sprites["Ctn #{CONTINUE_SCREEN_RACEGAME.keys[1]}"].y = CONTINUE_SCREEN_RACEGAME.values[1][1] + CONTINUE_SCREEN_RACEGAME.values[1][2]
          @continue = false
        else
          @sprites["Ctn #{CONTINUE_SCREEN_RACEGAME.keys[1]}"].y = CONTINUE_SCREEN_RACEGAME.values[1][1]
          @continue = true
        end
      end
      if Input.trigger?(Input::C)
        pbSEPlay("SE_Select1")
        pbSEPlay("SE_Select2")
        if @continue
          if $player.coins == 0
            pbMessage(_INTL("You don't have enough Coins to play!"))
          else
            # Dispose
            dispose
            # Draw scene (first)
            draw_choice_first
            # Reset 
            reset_all
          end
        else
          @exit = true
        end
      end
    end
  end
  
  def select_two_after_choice
    (0...CANDIDAT.size).each{|i|
    @sprites["poke#{i}"].opacity = SCREEN_CHOICE_OPACITY_POKE_RACEGAME[i][0]
    @sprites["poke#{@selecttwo}"].opacity = SCREEN_CHOICE_OPACITY_POKE_RACEGAME[@selecttwo][1] if i == @selecttwo
    }
  end
  
  def select_coin_after_choice
    (0...COIN_RACEGAME.size).each {|i|
    @sprites["#{COIN_RACEGAME.keys[i]}"].opacity = OPACITY_COIN_RACEGAME[i][0]
    @sprites["#{COIN_RACEGAME.keys[i]}"].opacity = OPACITY_COIN_RACEGAME[@selectcoin][1] if i == @selectcoin
    }
  end
  
  def choose_bar_visible
    (0...CANDIDAT.size).each {|i| @sprites["#{CHOOSE_BAR_RACEGAME[0]}"].y = CHOOSE_BAR_RACEGAME[1][1] + CHOOSE_BAR_RACEGAME[2]*@choose}
  end
  
  def candidat_animation(plus=nil,number=0,condition=false,condition_x=0)
    (0...CANDIDAT.size).each {|i| 
    if @selecttwo == i
      (0...CANDIDAT.size).each {|j|
      @sprites["player#{i} #{j}"].src_rect.x += @sprites["player#{i} #{j}"].src_rect.width
      @sprites["player#{i} #{j}"].src_rect.x = 0  if @sprites["player#{i} #{j}"].src_rect.x >= @sprites["player#{i} #{j}"].bitmap.width
      if !condition
        @sprites["player#{i} #{j}"].x += number if plus
        @sprites["player#{i} #{j}"].x -= number if !plus
      elsif condition && @sprites["player#{i} #{j}"].x <= condition_x
        @sprites["player#{i} #{j}"].x += number if plus
        @sprites["player#{i} #{j}"].x -= number if !plus
      end}
    end}
  end
  
  def move_candidat(plus_num=0,minus_num=0,condition_x=0)
    (0...CANDIDAT.size).each {|i| 
    if @selecttwo == i
      (0...CANDIDAT.size).each {|j|
      @sprites["player#{i} #{j}"].x += plus_num
		  @sprites["player#{i} #{j}"].x -= minus_num if @sprites["player#{i} #{j}"].x > condition_x && @range_sort_uniq[0] == @range[j]}
    end}
  end
  
  def check_finish(number=0,define=false)
    (0...CANDIDAT.size).each {|i| 
    if @selecttwo == i
      (0...CANDIDAT.size).each {|j|
      @finish_course[j] = true if !(@finish_course[j]) && @sprites["player#{i} #{j}"].x <= number
      if define
        if @sprites["player#{i} #{j}"].x >= 0 
          @rank_count[j] += number - @sprites["player#{i} #{j}"].x 
        elsif @sprites["player#{i} #{j}"].x < 0
          @rank_count[j] += number*2 - @sprites["player#{i} #{j}"].x 
        end
      end}
    end}
  end
  
  def scene_move(grass=0,scene=0)
    @sprites["grass"].ox += grass
		@sprites["scene"].src_rect.x -= scene
  end
  
  def play
    @animation += 1
    # Animation
    @animation = 0 if @animation == 3 
    @time += 1
    # Begin
    if @time < 500
      if @sprites["scene"].src_rect.x > 340
        candidat_animation(false,4) if @animation%3 == 0
        scene_move(4,1)
      elsif @sprites["scene"].src_rect.x <= 340
        candidat_animation if @animation%2 == 0
        scene_move(7)
        (0...@range.size).each{|i| @range[i] = rand(20)}
        @range_sort_uniq = @range.sort.reverse
        @range_sort_uniq.uniq!
        move_candidat(2,8,200) unless @range_sort_uniq.size != @range.size
      end
    # Middle
    elsif @time >= 500 && @time < 600
      candidat_animation if @animation%2 == 0
      scene_move(5)
    elsif @time >= 600 && @time < 1000
      candidat_animation if @animation%3 == 0
      scene_move(7)
      (0...@range.size).each{|i| @range[i] = rand(10)}
      @range_sort_uniq = @range.sort.reverse
      @range_sort_uniq.uniq!
      move_candidat(2,10,200) unless @range_sort_uniq.size != @range.size
    # End
    elsif @time >= 1000
      if @sprites["scene"].src_rect.x > 0
        candidat_animation(true,2,true,700) if @animation%2 == 0
        scene_move(4,2)
      elsif @sprites["scene"].src_rect.x == 0
        candidat_animation(false,2,true,700) if @animation%2 == 0
        # Stop course
        check_finish(110)
        if !(@finish_course.include? false)
          # Draw number rank
          number
          # Define order (number = number 'above')
          check_finish(110,true)
          @process = 5 
        end
      end
    end
  end
  
  def visible_order
    (0...CANDIDAT.size).each{|i|
    (0...@rank_sort_uniq.size).each{|j|
    if @rank_sort_uniq[j] == @rank_count[i] && !@marked[i]  
      @sprites["#{NUMBER_RACEGAME[1][j]} #{i}"].visible = true 
      @sprites["#{NUMBER_RACEGAME[1][j]} #{i}"].y = NUMBER_RACEGAME[2][1] + NUMBER_RACEGAME[3]*i
      @marked[i] = true
      @win = i if j==0 && @rank_sort_uniq.size == CANDIDAT.size
    end
    }}
  end
  
  def define_order
    @rank_sort_uniq = @rank_count.sort.reverse
    # Delete same number
    @rank_sort_uniq.uniq!
    visible_order
    pbWait(0.625)
    @process = 6
  end
  
  def coin_plus_or_minus
    (0...COIN_RACEGAME.size).each{|i| 
    if @selectcoin == i 
      $player.coins += COIN_RACEGAME.values[i]*2
      pbMEPlay("Slots win")
      pbMessage(_INTL("\\wuYou've won {1} Coins!", COIN_RACEGAME.values[i]*2))
    end }
  end
  
  def reset_all
    @animation = 0
    @range = [0,0,0,0]
    @finish_course =[false,false,false,false]
    @rank_count = [0,0,0,0]
    @marked = [false,false,false,false]
    @win = nil
    @time = 0
    @select = true; @selecttwo =0; @selectcoin = 0; @choose = 0; @check = true
    @continue = true
    @process = 0
  end
  
  def dispose
    pbDisposeSpriteHash(@sprites)
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end
  
  def update_ingame
    Graphics.update
    Input.update
    self.update
  end
  
  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end

end

def pbRaceGame
  a = []
  (0...CANDIDAT.size).each {|i| 
  if !File.exist?("Graphics/Characters/#{CANDIDAT_ID[i]}.png")
    a.push false
  else
    a.push true
  end
  }
  if a.include? false
    pbMessage(_INTL("You don't have the sprites. Please add these!"))
  else
    scene=RaceGame.new
    scene.pbStart
  end
end