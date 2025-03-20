#==============================================================================
# * Case 13 Images
#------------------------------------------------------------------------------
# Shows a scene with the Case 13 Images.
# Display with:
#      pbEventScreen(Case13Images)
#==============================================================================
class Case13Images < EventScene
    def initialize(viewport = nil)
      super
      Graphics.freeze
      @current_screen = 1
      @images = []
      @image_screens = []

      addImageForScreen(1, 0, 0, "Graphics/Pictures/Newspaper_1")

      addImageForScreen(2, 0, 0, "Graphics/Pictures/Newspaper_2")
  
      addImageForScreen(3, 0, 0, "Graphics/Pictures/Newspaper_3")
  
      set_up_screen(@current_screen)
      Graphics.transition
      # Go to next screen when user presses USE
      onCTrigger.set(method(:pbOnScreenEnd))
    end
  
    def addImageForScreen(number, x, y, filename)
      @images.push(addImage(x, y, filename))
      @image_screens.push(number)
      @picturesprites[@picturesprites.length - 1].opacity = 0
    end
  
    def set_up_screen(number)
      @image_screens.each_with_index do |screen, i|
        @images[i].moveOpacity((screen == number) ? 10 : 0, 10, (screen == number) ? 255 : 0)
      end
      pictureWait   # Update event scene with the changes
      pbSEPlay("Battle Ball Shake") 
    end
  
    def pbOnScreenEnd(scene, *args)
      last_screen = @image_screens.max
      if @current_screen >= last_screen
        # End scene
        $game_temp.background_bitmap = Graphics.snap_to_bitmap
        Graphics.freeze
        @viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
        Graphics.transition(8, "fadetoblack")
        $game_temp.background_bitmap.dispose
        scene.dispose
      else
        # Next screen
        @current_screen += 1
        onCTrigger.clear
     #   pbSEPlay("Battle Ball Shake") 
        set_up_screen(@current_screen)
        onCTrigger.set(method(:pbOnScreenEnd))
      end
    end
  end
  