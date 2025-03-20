module Settings
    #====================================================================================
    #=============================== Tip Cards Settings =================================
    #====================================================================================
    
        #--------------------------------------------------------------------------------
        #  Set the default background for tip cards.
        #  The files are located in Graphics/Pictures/Tip Cards
        #--------------------------------------------------------------------------------  
        TIP_CARDS_DEFAULT_BG            = "bg"

        #--------------------------------------------------------------------------------
        #  If set to true, if only one group is shown when calling pbRevisitTipCardsGrouped,
        #  the group header will still appear. Otherwise, the header won't appear.
        #--------------------------------------------------------------------------------  
        TIP_CARDS_SINGLE_GROUP_SHOW_HEADER = false

        #--------------------------------------------------------------------------------
        #  If set to true, when the player uses the SPECIAL control, a list of all
        #  groups available to view will appear for the player to jump to one.
        #--------------------------------------------------------------------------------  
        TIP_CARDS_GROUP_LIST = true

        #--------------------------------------------------------------------------------
        #  Set the default text colors
        #--------------------------------------------------------------------------------  
        TIP_CARDS_TEXT_MAIN_COLOR       = Color.new(80, 80, 88)
        TIP_CARDS_TEXT_SHADOW_COLOR     = Color.new(160, 160, 168)

        #--------------------------------------------------------------------------------
        #  Set the sound effect to play when showing, dismissing, and switching tip cards.
        #  For TIP_CARDS_SWITCH_SE, set to nil to use the default cursor sound effect.
        #--------------------------------------------------------------------------------  
        TIP_CARDS_SHOW_SE               = "GUI menu open"
        TIP_CARDS_DISMISS_SE            = "GUI menu close"
        TIP_CARDS_SWITCH_SE             = nil

        #--------------------------------------------------------------------------------
        #  Define your tips in this hash. The :EXAMPLE describes what some of the 
        #  parameters do.
        #--------------------------------------------------------------------------------  
        TIP_CARDS_CONFIGURATION = {
            :EXAMPLE => { # ID of the tip
                    # Required Settings
                    :Title => _INTL("Example Tip"),
                    :Text => _INTL("This is the text of the tip. You can include formatting."),
                    # Optional Settings
                    :Image => "example", # An image located in Graphics/Pictures/Tip Cards/Images
                    :ImagePosition => :Top, # Set to :Top, :Bottom, :Left, or :Right.
                        # If not defined, it will place wider images to :Top, and taller images to :Left.
                    :Background => "bg2", # A replacement background image located in Graphics/Pictures/Tip Cards
                    :YAdjustment => 0, # Adjust the vertical spacing of the tip's text (in pixels)
                    :HideRevisit => true # Set to true if you don't want the player to see the tip again when revisiting seen tips.
            },
            :TEXTLOG => {
                :Title => _INTL("Text Log"),
                :Text => _INTL("Pokémon Ashen Frost has a built-in text log. You can review recent conversations by pressing the <c2=0999367C><b>Scroll Up/A</b></c2> button."),
                :Image => "textlog",
                :Background => "bg2"
            },
            :QUICKSAVE => {
                :Title => _INTL("Quicksave"),
                :Text => _INTL("You can open the quicksave menu by pressing the <c2=0999367C><b>AUX2/F</b></c2> button."),
                :Image => "quicksave",
                :Background => "bg2"
            },
            :EVALLOC1 => {
                :Title => _INTL("EV Allocation"),
                :Text => _INTL("You can manually allocate EVs by pressing the <c2=0999367C><b>USE</b></c2> button."),
                :Image => "evalloc",
                :Background => "bg2"
            },
            :EVALLOC2 => {
                :Title => _INTL("EV Allocation"),
                :Text => _INTL("EV pool and EV cap-per-stat increase with every level up to a maximum of <c2=0999367C>512 and 252</c2>, respectively."),
                :Image => "evalloc",
                :Background => "bg2"
            },
            :EVALLOC3 => {
                :Title => _INTL("EV Allocation"),
                :Text => _INTL("EVs are automatically increased in the <c2=0999367C>two stats with the most EVs</c2> every time a level is gained."),
                :Image => "evalloc",
                :Background => "bg2"
            },
            :EVALLOC4 => {
                :Title => _INTL("EV Allocation"),
                :Text => _INTL("Attack and Sp. Attack share the same EV <c2=0999367C>without taking away from the overall EV count</c2>. This improves the viability of mixed attackers."),
                :Image => "evalloc",
                :Background => "bg2"
            },
            :MOVEREMIND => {
                :Title => _INTL("Remembering Moves"),
                :Text => _INTL("You can remember all previously known <c2=0999367C>non-level 1</c2> moves by pressing the <c2=0999367C><b>ACTION/Z</b></c2> button."),
                :Image => "moveremind",
                :Background => "bg2"
            },
            :TUTORNET => {
                :Title => _INTL("Tutor.net"),
                :Text => _INTL("All TMs and Move Tutors can be accessed through the Tutor.net app. This can be found in your <c2=0999367C>phone menu</c2>."),
                :Image => "tutornet",
                :Background => "bg2"
            },
        }

        TIP_CARDS_GROUPS = {
            :EVALLOC => {
                :Title => _INTL("EV Allocation"),
                :Tips => [:EVALLOC1, :EVALLOC2, :EVALLOC3, :EVALLOC4]
            },
            :GAMEBASICS => {
                :Title => _INTL("Game Basics"),
                :Tips => [:TEXTLOG, :QUICKSAVE]
            }
        }

end