#===============================================================================
# **                                Ocarina                                   **
#                                 by Polectron
#===============================================================================
class Flute

  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999

    @sprites["menubg"]=Sprite.new(@viewport)
    @sprites["menubg"].bitmap=RPG::Cache.picture("flute")
    @sprites["menubg"].x=0
    @sprites["menubg"].z=0
    pbInitRafaTextSystem
    textos3=[]

    textos3.push([_INTL(""),192,30,false,@baseColor,@shadowColor])

    #textos3.push([_INTL("TEXTO"),X,Y,false,baseColor,shadowColor])

    pbDrawTextPositions(@overlay3,textos3) # PRINT IT ON THE SCREEN

  end

  def pbInitRafaTextSystem # START THE TEXT SYSTEM
     @sprites["overlay3"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
     @sprites["overlay3"].z = 99999
     @overlay3=@sprites["overlay3"].bitmap
     @sprites["overlay3"].zoom_x=1
     @sprites["overlay3"].zoom_y=1
     @sprites["overlay3"].bitmap.clear
     @baseColor=Color.new(255, 255, 255) # Font Colour
     @shadowColor=Color.new(42,42,42) # Shadow Colour
     pbSetSystemFont(@sprites["overlay3"].bitmap)
  end

  def pbEndScene # Ending...
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose if @viewport
  end

  def pbUpdate(n,i)
    @xcount=0
    @posible1=0
    @posible2=0
    @posible3=0
    total = 0
    count = 0
    correct = 0
    play= []
    songs = [
      ["UP","RIGHT","RIGHT","DOWN","LEFT","LEFT"],
      ["LEFT","LEFT","DOWN","RIGHT","RIGHT","DOWN"],
      ["DOWN","DOWN","RIGHT","RIGHT","UP","RIGHT"],
      ["UP","RIGHT","RIGHT","DOWN"],
      ["UP","LEFT","RIGHT","LEFT"],
      ["UP","UP","RIGHT","LEFT"],
      ["LEFT","DOWN","RIGHT","DOWN"],
      ["LEFT","DOWN","RIGHT","LEFT"],
      ["UP","RIGHT","RIGHT","DOWN","LEFT","DOWN","DOWN","RIGHT","RIGHT","UP","RIGHT"],
      ["LEFT","DOWN","DOWN","DOWN","LEFT","RIGHT","DOWN","RIGHT","UP","RIGHT"]
      ]
    loop do
      Graphics.update
      Input.update
      if !songs[n]
        pbMessage(_INTL("Song #{n} doesn't exist."))
        break
      end
      #Features here#
      if total < songs[n].length #number of 'digits' per combination, a couple of changes could make each combination have a different length
        if Input.trigger?(Input::UP)#What happens if we press UP
          play.push('UP')
          total += 1
          @sprites[total]=Sprite.new(@viewport)
          @sprites[total].bitmap=RPG::Cache.picture("key_UP")
          @sprites[total].x=40*total
          @sprites[total].y=180
          @sprites[total].z=1
        end
        if Input.trigger?(Input::DOWN)#What happens if we press DOWN
          play.push('DOWN')
          total += 1
          @sprites[total]=Sprite.new(@viewport)
          @sprites[total].bitmap=RPG::Cache.picture("key_DOWN")
          @sprites[total].x=40*total
          @sprites[total].y=180
          @sprites[total].z=1
        end
        if Input.trigger?(Input::LEFT)#What happens if we press LEFT
          play.push('LEFT')
          total += 1
          @sprites[total]=Sprite.new(@viewport)
          @sprites[total].bitmap=RPG::Cache.picture("key_LEFT")
          @sprites[total].x=40*total
          @sprites[total].y=180
          @sprites[total].z=1
        end
        if Input.trigger?(Input::RIGHT)#What happens if we press RIGHT
          play.push('RIGHT')
          total += 1
          @sprites[total]=Sprite.new(@viewport)
          @sprites[total].bitmap=RPG::Cache.picture("key_RIGHT")
          @sprites[total].x=40*total
          @sprites[total].y=180
          @sprites[total].z=1
        end
        if Input.trigger?(Input::BACK)#If we press the X it asks us if we want to exit
          command=pbMessage(_INTL("Cancel?"),[
            _INTL("Yes"),_INTL("No")
          ],-1)
          if command==0 # Read
            break
          end
        end
      else
        while count < songs[n].length #the list of 'digits' in the answer and the pattern is traversed to check that it is correct
          if play[count] == songs[n][count]
            correct += 1
          end
          count += 1
        end
        if correct == songs[n].length #when the loop ends, if the number of hits (correct) is equal to the number of 'digits' the answer is correct
          pbMessage(_INTL("Correct!"))
          $game_switches[i] = true
          break
        else #otherwise the answer is wrong
          pbMessage(_INTL("Incorrect."))
          break
        end
      end
    end
  end
    ################
end #Close the class

class FluteScene
  def initialize(scene,n,i)
    @scene=scene
    @n = n
    @i = i
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbUpdate(@n, @i)
    @scene.pbEndScene
  end
end

def pbCallFlute(n, i) #the script is called, 'n' and 'i' are numeric values
  scene=Flute.new
  screen=FluteScene.new(scene, n, i)
  screen.pbStartScreen
end
