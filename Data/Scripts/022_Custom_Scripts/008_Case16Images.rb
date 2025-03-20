#==============================================================================
# * Case 16 Images
#------------------------------------------------------------------------------
# Shows a scene with the Case 16 Images.
# Display with:
#      pbEventScreen(Case16Images)
#==============================================================================
class Case16Images < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    addImage(0, 0, "Graphics/Pictures/Kalvin's Letter")
    Graphics.transition
    pbSEPlay("Battle Ball Shake") 
    # Go to next screen when user presses USE
    onCTrigger.set(method(:pbOnScreenEnd))
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
