module Input

  def self.update
    update_KGC_ScreenCapture
    if trigger?(Input::F8)
      pbScreenCapture
    end
    if $CanToggle && trigger?(Input::AUX1)  #remap your Q button on the F1 screen to change your speedup switch
      $GameSpeed += 2
      $GameSpeed = 0 if $GameSpeed >= SPEEDUP_STAGES.size
      gametitle=System.game_title
      pbSetWindowText(gametitle +" | Speed: x" + ($GameSpeed+1).to_s) unless $joiplay
    end
  end
end

SPEEDUP_STAGES = [1,2,3,4,5]
$GameSpeed = 0
$frame = 0
$CanToggle = true

module Graphics
  class << Graphics
    alias fast_forward_update update
  end

  def self.update
    $frame += 1
    return unless $frame % SPEEDUP_STAGES[$GameSpeed] == 0
    fast_forward_update
    $frame = 0
  end
end
