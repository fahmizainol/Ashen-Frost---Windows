############################
# QoL Tutorials by DemICE
############################

class PokemonSystem
    attr_accessor :qol_tutorials

    alias qol_tutorials_initialize initialize
    def initialize
        qol_tutorials_initialize
        reset_tutorials
    end
    
    def reset_tutorials
        @qol_tutorials = {
            :battle_ui      => false,
            :quicksave      => false,
            :ev_alloc       => false,
            :mixed_evs      => false,
            :move_remind    => false,
            :hall_of_fame   => false,
            :bag_sorting    => false
        } 
    end

end


def pbBattleUITutorial
    pbTutorialWindow(
      _INTL("M button: Select a battler to view its typing, stat changes, and active effects.\nN button: View the effectiveness of your moves against the opponents and general information about the moves.")
    )
end

def pbQuickSaveTutorial
    pbTutorialWindow(
      _INTL("You can Quick Save by pressing the AUX2 button \nDefault: F.")
    )
end

def pbBagSortingTutorial
    pbTutorialWindow(
      _INTL("You can sort items alphabetically by pressing the AUX2 button \nDefault: F.")
    )
end

def pbEVAllocTutorial
    pbTutorialWindow(
      _INTL("You can manually allocate EVs by pressing the USE button.\nDefault: C, Space.\nEV pool and EV cap per stat increase with every level up to a maximum of 512 and 252 respectively.\nEVs are automatically increased in the two stats with the most EVs every time a level is gained.")
    )
end

def pbMixedEvsTutorial
    pbTutorialWindow(
      _INTL("Attack and Special Attack share the same EV without taking away from the overall EV count. This helps mixed attackers be more viable. ")
    )
end

def pbMoveRemindTutorial
    pbTutorialWindow(
      _INTL("You can remember moves known beforehand, or that have been attempted to be learned, by pressing the ACTION button.\nDefault: Shift, Z.")
    )
end


def pbHallOfFameTutorial
    pbTutorialWindow(
      _INTL("You can toggle between general Hall of Fame information and Pokemon-Specific information with the ACTION button (default: Z, Shift).")
    )
end

def pbQolTutorials(entry="")
    if $PokemonSystem.qol_tutorials.nil?
        $PokemonSystem.reset_tutorials
    end
    if entry == "BattleUI" && !$PokemonSystem.qol_tutorials[:battle_ui]
        pbBattleUITutorial 
        $PokemonSystem.qol_tutorials[:battle_ui]=true
    end
    if entry == "QuickSave" && !$PokemonSystem.qol_tutorials[:quicksave]
        pbQuickSaveTutorial 
        $PokemonSystem.qol_tutorials[:quicksave]=true
    end
    if entry == "BagSorting" && !$PokemonSystem.qol_tutorials[:bag_sorting]
        pbBagSortingTutorial 
        $PokemonSystem.qol_tutorials[:bag_sorting]=true
    end
    if entry == "EVAlloc" && !$PokemonSystem.qol_tutorials[:ev_alloc]
        pbEVAllocTutorial 
        $PokemonSystem.qol_tutorials[:ev_alloc]=true
    end
    if entry == "MixedEVs" && !$PokemonSystem.qol_tutorials[:mixed_evs]
        pbMixedEvsTutorial 
        $PokemonSystem.qol_tutorials[:mixed_evs]=true
    end
    if entry == "MoveRemind" && !$PokemonSystem.qol_tutorials[:move_remind]
        pbMoveRemindTutorial 
        $PokemonSystem.qol_tutorials[:move_remind]=true
    end
    if entry == "HallOfFame" && !$PokemonSystem.qol_tutorials[:hall_of_fame]
        pbHallOfFameTutorial 
        $PokemonSystem.qol_tutorials[:hall_of_fame]=true
    end
end

def pbTutorialWindow(text, scene = nil)
    window = Window_AdvancedTextPokemon.new(text)
    window.width = Graphics.width
    window.x     = 0#Graphics.width - window.width
    window.y     = (Graphics.height - window.height)/2
    window.z     = 99999
    pbPlayDecisionSE
    pbWait(5)
    loop do
      Graphics.update
      Input.update
      window.update
      scene&.pbUpdate
      break if Input.trigger?(Input::USE)
    end
    window.dispose
  end
