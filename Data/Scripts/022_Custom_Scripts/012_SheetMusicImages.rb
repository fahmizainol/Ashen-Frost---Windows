#==============================================================================
# * Sheet Music Images
#------------------------------------------------------------------------------
# Shows a scene with the Case 14 Images.
# Display with:
#      pbEventScreen(SongX)
#==============================================================================
#Blue Song
#==============================================================================
class SongBlue < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/AA_Blue")
    Graphics.transition
    pbSEPlay("Battle Ball Shake") 
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat NOte: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
  end

  def pbOnScreenEnd(scene, *args)
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    Graphics.freeze
    @viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
    Graphics.transition(8, "fadetoblack")
    $game_temp.background_bitmap.dispose
    scene.dispose
  end
end
#==============================================================================
#Green Song
#==============================================================================
class SongGreen < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/AA_Green")
    Graphics.transition
    pbSEPlay("Battle Ball Shake") 
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) 
  end

  def pbOnScreenEnd(scene, *args)
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    Graphics.freeze
    @viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
    Graphics.transition(8, "fadetoblack")
    $game_temp.background_bitmap.dispose
    scene.dispose
  end
end
#==============================================================================
#Orange Song 
#==============================================================================
class SongOrange < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/AA_Orange")
    Graphics.transition
    pbSEPlay("Battle Ball Shake") 
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) 
  end

  def pbOnScreenEnd(scene, *args)
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    Graphics.freeze
    @viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
    Graphics.transition(8, "fadetoblack")
    $game_temp.background_bitmap.dispose
    scene.dispose
  end
end
#==============================================================================
# Red Song 
#==============================================================================
class SongRed < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/AA_Red")
    Graphics.transition
    pbSEPlay("Battle Ball Shake") 
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) 
  end

  def pbOnScreenEnd(scene, *args)
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    Graphics.freeze
    @viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
    Graphics.transition(8, "fadetoblack")
    $game_temp.background_bitmap.dispose
    scene.dispose
  end
end
#==============================================================================
# Yellow Song
#==============================================================================
class SongYellow < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/AA_Yellow")
    Graphics.transition
    pbSEPlay("Battle Ball Shake") 
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd))
  end

  def pbOnScreenEnd(scene, *args)
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    Graphics.freeze
    @viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
    Graphics.transition(8, "fadetoblack")
    $game_temp.background_bitmap.dispose
    scene.dispose
  end
end
#==============================================================================
# Configuration A
#==============================================================================
class Pianoconfig_A < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Pianoconfig_A")
    Graphics.transition
    pbSEPlay("Battle Ball Shake") 
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) 
  end

  def pbOnScreenEnd(scene, *args)
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    Graphics.freeze
    @viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
    Graphics.transition(8, "fadetoblack")
    $game_temp.background_bitmap.dispose
    scene.dispose
  end
end
#==============================================================================
# Configuration B
#==============================================================================
class Pianoconfig_B < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Pianoconfig_B")
    Graphics.transition
    pbSEPlay("Battle Ball Shake") 
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) 
  end

  def pbOnScreenEnd(scene, *args)
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    Graphics.freeze
    @viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
    Graphics.transition(8, "fadetoblack")
    $game_temp.background_bitmap.dispose
    scene.dispose
  end
end
#==============================================================================
# Configuration C
#==============================================================================
class Pianoconfig_C < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Pianoconfig_C")
    Graphics.transition
    pbSEPlay("Battle Ball Shake") 
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) 
  end

  def pbOnScreenEnd(scene, *args)
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    Graphics.freeze
    @viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
    Graphics.transition(8, "fadetoblack")
    $game_temp.background_bitmap.dispose
    scene.dispose
  end
end
#==============================================================================
# Configuration D
#==============================================================================
class Pianoconfig_D < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Pianoconfig_D")
    Graphics.transition
    pbSEPlay("Battle Ball Shake") 
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) 
  end

  def pbOnScreenEnd(scene, *args)
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    Graphics.freeze
    @viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
    Graphics.transition(8, "fadetoblack")
    $game_temp.background_bitmap.dispose
    scene.dispose
  end
end
#==============================================================================
# Configuration 8
#==============================================================================
class Pianoconfig_8 < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Pianoconfig_8")
    Graphics.transition
    pbSEPlay("Battle Ball Shake") 
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) 
  end

  def pbOnScreenEnd(scene, *args)
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    Graphics.freeze
    @viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
    Graphics.transition(8, "fadetoblack")
    $game_temp.background_bitmap.dispose
    scene.dispose
  end
end