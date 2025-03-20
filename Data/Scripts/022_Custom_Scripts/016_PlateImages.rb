#==============================================================================
# * Arceus Plate Images
#------------------------------------------------------------------------------
# Shows a scene with the Arceus Plate Images.
# Display with:
#      pbEventScreen(PlateX)
#==============================================================================
#Blank Plate
#==============================================================================
class PlateBlank < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Blank")
    Graphics.transition
    pbMessage(_INTL("Three beings whose power can hold both time and space fixed."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Flame Plate
#==============================================================================
class PlateFlame < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Flame")
    Graphics.transition
    pbMessage(_INTL("The power of defeated giants infuses this Plate."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Splash Plate
#==============================================================================
class PlateSplash < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Splash")
    Graphics.transition
    pbMessage(_INTL("The rightful bearer of a Plate draws from the Plate it holds."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Zap Plate
#==============================================================================
class PlateZap < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Zap")
    Graphics.transition
    pbMessage(_INTL("The third being raged, raining down bolts of anger."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Meadow Plate
#==============================================================================
class PlateMeadow < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Meadow")
    Graphics.transition
    pbMessage(_INTL("The powers of Plates are shared among Pokémon."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Icicle Plate
#==============================================================================
class PlateIcicle < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Icicle")
    Graphics.transition
    pbMessage(_INTL("Two beings of time and space set free from the Original One."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Fist Plate
#==============================================================================
class PlateFist < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Fist")
    Graphics.transition
    pbMessage(_INTL("The rift is born of disorder on the other side of this world."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Toxic Plate
#==============================================================================
class PlateToxic < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Toxic")
    Graphics.transition
    pbMessage(_INTL("The rules of time and space change within the opposite world."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Earth Plate
#==============================================================================
class PlateEarth < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Earth")
    Graphics.transition
    pbMessage(_INTL("When the universe was created, its shards became this Plate."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Sky Plate
#==============================================================================
class PlateSky < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Sky")
    Graphics.transition
    pbMessage(_INTL("The being poured the remains of its power into stone and buried it deep."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Mind Plate
#==============================================================================
class PlateMind < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Mind")
    Graphics.transition
    pbMessage(_INTL("The Original One breathed alone before the universe came."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Insect Plate
#==============================================================================
class PlateInsect < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Insect")
    Graphics.transition
    pbMessage(_INTL("Where all creation was born, that is the being's place of origin."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Stone Plate
#==============================================================================
class PlateStone < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Stone")
    Graphics.transition
    pbMessage(_INTL("It gathers power from the Plates, listening for the flute's song."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Spooky Plate
#==============================================================================
class PlateSpooky < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Spooky")
    Graphics.transition
    pbMessage(_INTL("The other side of this world was given by the Original One to its raging third."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Draco Plate
#==============================================================================
class PlateDraco < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Draco")
    Graphics.transition
    pbMessage(_INTL("Three beings were born to bind time and space."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Dread Plate
#==============================================================================
class PlateDread < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Dread")
    Graphics.transition
    pbMessage(_INTL("Two make matter, and three make spirit, shaping the world."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Iron Plate
#==============================================================================
class PlateIron < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Iron")
    Graphics.transition
    pbMessage(_INTL("That which fills the other side of the world can shape the rage and mold it."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Pixie Plate
#==============================================================================
class PlatePixie < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Pixie")
    Graphics.transition
    pbMessage(_INTL("The Original One is in all things. The Original One is nowhere at all."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Legend Plate
#==============================================================================
class PlateLegend < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Legend")
    Graphics.transition
    pbMessage(_INTL("From all creations, over all creations, does the Original One watch over all."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
#Unknown Plate
#==============================================================================
class PlateUnknown < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Plate_Unknown")
    Graphics.transition
    pbMessage(_INTL("The Original One will see those who collect all these plates."))
    # Go to next screen when user presses EXIT
    onBTrigger.set(method(:pbOnScreenEnd)) #Ekat Note: Used to be C, we'll *C* if this works. Hahahaha. I hope Michael doesn't notice my bad pun in the comments. 
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
