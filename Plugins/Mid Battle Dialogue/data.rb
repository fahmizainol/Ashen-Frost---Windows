#DON'T DELETE THIS LINE
module DialogueModule


# Format to add new stuff here
# Name = data
#
# To set in a script command
# BattleScripting.setInScript("condition",:Name)
# The ":" is important

#  Joey_TurnStart0 = {"text"=>"Hello","bar"=>true}
#  BattleScripting.set("turnStart0",:Joey_TurnStart0)

                  
##############Custom#########################################################################################
##############General########################################################################################     
  Midlife= Proc.new{|battle|
      battle.pbAnimation(:HOWL,battle.battlers[1],battle.battlers[0])
      pbMessage(_INTL("{1} is starting to get mad!",battle.battlers[1].name))
      battle.battlers[0].pbResetStatStages
      battle.battlers[1].pbResetStatStages
      battle.battlers[1].pbRaiseStatStage(:ATTACK,1,battle.battlers[1])
      battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,1,battle.battlers[1])
      }
  
  Quartlife=Proc.new{|battle|
      battle.pbAnimation(:HOWL,battle.battlers[1],battle.battlers[0])
      pbMessage(_INTL("{1} is in pain!",battle.battlers[1].name))
      battle.battlers[0].pbResetStatStages
      battle.battlers[1].pbResetStatStages
      battle.battlers[1].pbRaiseStatStage(:ATTACK,2,battle.battlers[1])
      battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,2,battle.battlers[1])
      battle.battlers[0].pbLowerStatStage(:SPECIAL_ATTACK,2,battle.battlers[0])
      battle.battlers[0].pbLowerStatStage(:ATTACK,2,battle.battlers[0])
      }

  Enrage=Proc.new{|battle|
      battle.pbAnimation(:HOWL,battle.battlers[1],battle.battlers[0])
      pbMessage(_INTL("{1} rages!",battle.battlers[1].name))
      battle.battlers[0].pbResetStatStages
      battle.battlers[1].pbResetStatStages
      battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,6,battle.battlers[1])
      battle.battlers[1].pbRaiseStatStage(:ATTACK,6,battle.battlers[1])
      battle.battlers[1].pbRaiseStatStage(:SPEED,6,battle.battlers[1])
      }

##############Test########################################"
  Tform=Proc.new{|battle|
    battle.scene.appearBar
    battle.pbCommonAnimation("MegaEvolution",battle.battlers[1],nil)
    battle.battlers[1].pbChangeForm(1,"blablabla")
    battle.battlers[1].name="BIG BOY" #if you need to change their name, you can
    pbMessage("The boss reached their final form!")
    battle.scene.pbRefresh
    battle.scene.disappearBar
    }
  Tcall=Proc.new{|battle|
    battle.pbCallForHelp(battle.battlers[1])
    }
#===============================================================================
# Battle Roulette mid-battle handler
#===============================================================================
    BattleRoulette = Proc.new { |battle|
        case $game_variables[401]
        # Frostbite - Enemy/Player
        when 2
            battler = $game_switches[421] ? battle.battlers[0] : battle.battlers[1]
            battler.pbFrostbite if battler.pbCanFrostbite?(battler.pbDirectOpposing(true), false)
        # Poisoned - Player/Enemy
        when 3
            battler = $game_switches[421] ? battle.battlers[1] : battle.battlers[0]
            battler.pbPoison if battler.pbCanPoison?(battler.pbDirectOpposing(true), false)
        # Burned - Enemy/Player 
        when 4
            battler = $game_switches[421] ? battle.battlers[0] : battle.battlers[1]
            battler.pbBurn if battler.pbCanBurn?(battler.pbDirectOpposing(true), false)
        # Truant - Player/Enemy
        when 6
            battler = $game_switches[421] ? battle.battlers[1] : battle.battlers[0]
            battler.ability = :TRUANT
        # Paralysis - Enemy/Player 
        when 7
            battler = $game_switches[421] ? battle.battlers[0] : battle.battlers[1]
            battler.pbParalyze if battler.pbCanParalyze?(battler.pbDirectOpposing(true), false)
        # Perish Song - Neutral
        when 8
            # Set up battle effect for all Pokemon
            battle.pbPriority.each do |battler|
                battler.effects[PBEffects::PerishSong]     = 4
                battler.effects[PBEffects::NoRetreat]      = true
            end
            battle.pbDisplay(_INTL("All Pokémon will faint in three turns and can no longer escape!"))
        # Stealth Rock - Player/Enemy    
        when 9
            battler = $game_switches[421] ? battle.battlers[1] : battle.battlers[0]
            battle.pbAnimation(:STEALTHROCK, battler.pbDirectOpposing(true), battler)
            battler.pbOwnSide.effects[PBEffects::StealthRock] = true
            battle.pbDisplay(_INTL("Pointed stones float in the air around {1}!",
                battler.pbTeam(true)))
        # Leech Seed - Enemy/Player
        when 10
            battler = $game_switches[421] ? battle.battlers[0] : battle.battlers[1]
            battle.pbAnimation(:LEECHSEED, battler.pbDirectOpposing(true), battler)
            battler.effects[PBEffects::LeechSeed] = battler.pbDirectOpposing(true).index
            battle.pbDisplay(_INTL("{1} was seeded!", battler.pbThis))
        # Explosion - initialization
        when 12
            $game_switches[192] = true
        end
    }

#===============================================================================
# Maractus mid-battle text
#===============================================================================
    Marac1 = Proc.new{ |battle|
        battle.scene.appearBar
        # Maractus Quiz 1
        while true
            pbSEPlay("Stare")
            cmd = pbMessage(_INTL("It is staring."), [_INTL("Stare back."), _INTL("Try to run!")])
            case cmd
            when 0
                pbSEPlay("Saint3")
                pbMessage(_INTL("\\xn[Maractus]Blink!"))
                break
            when 1
                pbSEPlay("Paralyze3")
                pbMessage(_INTL("\\xn[Mordecai]My legs don't want to move!"))
            end
        end
        # Maractus Quiz 2
        while true
            pbSEPlay("Wring out")
            cmd = pbMessage(_INTL("It is wiggling around."), [_INTL("Wave at it."), _INTL("Breakdance!")])
            case cmd
            when 0
                pbSEPlay("Voltorb Flip point")
                pbMessage(_INTL("It waves back."))
                break
            when 1
                pbSEPlay("Blow5")
                pbMessage(_INTL("\\xn[Mordecai][Trips]"))
                # Maractus noise
                pbSEPlay("Wring out")
                pbMessage(_INTL("It is wiggling around faster."))
            end
        end
        # Maractus Quiz 3
        while true
            pbSEPlay("Darkness6")
            cmd = pbMessage(_INTL("It is making a weird noise."), [_INTL("Imitate it."), _INTL("Scream!")])
            case cmd
            when 0
                pbSEPlay("Voltorb Flip level down")
                pbMessage(_INTL("\\xn[Mordecai]Was that, uh, duo we, dowewwew? Or ew uh, whoo whoo who whoo?"))
                # He is now annoyed!
                pbSEPlay("buzzer")
                pbMessage(_INTL("It is unamused."))
            when 1
                pbMessage(_INTL("AAAAAAAAAAAAAAAAAAAAAAAAA!"))
                break
            end
        end
        # Make bar disappear
        battle.scene.disappearBar
        # End the battle with no result!
        pbMessage(_INTL("It was subdued!"))
        battle.decision = 3
        battle.scene.disappearBar
    }

#===============================================================================
 #Snowy Ninja Attacks
#===============================================================================

#Casino District
NinjaOmar=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Ninja Todd]Prepare for an ultra freezy attack!"))
    battle.scene.disappearBar
    if battle.battlers[0].pbCanFreeze?(battle.battlers[1],false)
        battle.battlers[0].pbFreeze
    else
        pbMessage(_INTL("\\xn[Ninja Todd]Uh, why aren't you freezing?"))
    end
    battle.scene.pbHideOpponent
}

#Café District
NinjaKai=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Ninja Kai] Hah! Let's see you dodge this snowball!"))
    pbMessage(_INTL("\\xn[\\PN]Uh, quite easily."))
    cmd = pbMessage(_INTL("\\xn[\\PN](Should I throw one back?)"), [_INTL("Yes!"),_INTL("No!")])
    case cmd
    when 0
        pbMessage(_INTL("\\xn[Ninja Kai]Hey!"))
        battle.scene.disappearBar
        if battle.battlers[1].pbCanFreeze?(battle.battlers[0],false)
            battle.battlers[1].pbFreeze
        else
            pbMessage(_INTL("\\xn[Ninja Kai]Hah! You really thought you could freeze MY Pokémon?"))
        end
    when 1
        battle.scene.disappearBar
    end
    battle.scene.pbHideOpponent
}

#Glacial Park
NinjaYasu=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Ninja Yasu]Hah! Let's see you dodge this snowball!"))
    pbMessage(_INTL("\\xn[\\PN]Uh, quite easily."))
    cmd = pbMessage(_INTL("\\xn[\\PN](Should I throw one back?)"), [_INTL("Yes!"),_INTL("No!")])
    case cmd
    when 0
        pbMessage(_INTL("\\xn[Ninja Yasu]Hey!"))
        battle.scene.disappearBar
        if battle.battlers[1].pbCanFreeze?(battle.battlers[0],false)
            battle.battlers[1].pbFreeze
        else
            pbMessage(_INTL("\\xn[Ninja Yasu]Hah! You really thought you could freeze MY Pokémon?"))
        end
    when 1
        battle.scene.disappearBar
    end
    battle.scene.pbHideOpponent
}

#Glacial Park 
NinjaShoji=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Ninja Jet]Come, let us blend into the snow!"))
    battle.scene.disappearBar
    battle.battlers[1].pbRaiseStatStage(:EVASION,1,battle.battlers[0]) if battle.battlers[1].pbCanRaiseStatStage?(:EVASION)
    battle.scene.pbHideOpponent
}

#Docks
NinjaJet=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Ninja Jet]Retreat, back into the snow!"))
    battle.scene.disappearBar
    battle.battlers[1].pbUseMoveSimple(:PROTECT, battle.battlers[0])
    battle.scene.pbHideOpponent
}

#===============================================================================
#Leafy Ninja Attacks
#===============================================================================

    #Okane Slums 
    NinjaRai=Proc.new{|battle|
        battle.scene.pbShowOpponent(0)
        battle.scene.appearBar
        pbMessage(_INTL("\\xn[Ninja Rai]Get ready for some garbage juice!"))
        pbMessage(_INTL("\\xn[\\PN]Sorry, I'm kind of immune to the smell of garbage."))
        cmd = pbMessage(_INTL("\\xn[\\PN](Should I throw this moldy onion I have at him?)"), [_INTL("Throw it!"),_INTL("No way!")])
        case cmd
        when 0
            pbMessage(_INTL("\\xn[Ninja Rai] Ewwww!"))
            battle.scene.disappearBar
            if battle.battlers[1].pbCanPoison?(battle.battlers[0],false)
                battle.battlers[1].pbPoison
            else
                pbMessage(_INTL("\\xn[Ninja Rai]That's pretty gross! But I don't think it'll poison my Pokémon."))
            end
        when 1
            battle.scene.disappearBar
        end
        battle.scene.pbHideOpponent
    }

    #Mt. Trebel Base
    NinjaCorey=Proc.new{|battle|
        battle.scene.pbShowOpponent(0)
        battle.scene.appearBar
        pbMessage(_INTL("\\xn[Ninja Corey]No, it won't end here!"))
        battle.scene.disappearBar
        battle.battlers[1].pbUseMoveSimple(:INGRAIN, battle.battlers[0])
        battle.scene.pbHideOpponent
    }

    #Aurora Marketplace
    NinjaShi=Proc.new{|battle|
        battle.scene.pbShowOpponent(0)
        battle.scene.appearBar
        pbMessage(_INTL("\\xn[Ninja Shi]Wah! No fair!"))
        pbMessage(_INTL("Ninja Shi tried to use his Super Leaf Clan Kick!"))
        pbMessage(_INTL("...It's not very effective."))
        pbMessage(_INTL("\\xn[\\PN]Be a good sport! Don't try kicking people... At least without a good reason!"))
        battle.scene.disappearBar
        battle.scene.pbHideOpponent
    }

    #Route One
    NinjaBenji=Proc.new{|battle|
        battle.scene.pbShowOpponent(0)
        battle.scene.appearBar
        pbMessage(_INTL("\\xn[Ninja Benji]Let's see how you like leaf juice!"))
        battle.scene.disappearBar
        if battle.battlers[0].pbCanPoison?(battle.battlers[1],false)
            battle.battlers[0].pbPoison
        else
            pbMessage(_INTL("\\xn[Ninja Benji]Hey! You're suppoesd to be poisoned!"))
            pbMessage(_INTL("\\xn[\\PN]Heh. Guess my Pokémon's been taking lessons from a friend."))
            pbMessage(_INTL("\\xn[\\PN](Thanks, Luciano.)"))
        end
        battle.scene.pbHideOpponent
    }

    #===============================================================================
    #Police Officer Attacks (As Mordecai in Case 12)
    #===============================================================================

    OfficerSand=Proc.new{|battle|
        battle.scene.pbShowOpponent(0)
        battle.scene.appearBar
        pbMessage(_INTL("\\xn[\\PN] Pocket sand!"))
        battle.pbAnimation(:SANDATTACK,battle.battlers[0],battle.battlers[1])
        pbMessage(_INTL("\\xn[Officer] My eyes!!"))
        cmd = pbMessage(_INTL("\\xn[\\PN](Let's high tail it outta' here!)"), [_INTL("Skedaddle!"),_INTL("Teach him a lesson!")])
        case cmd
        when 0
            # Make bar disappear
             battle.scene.disappearBar
             # End the battle with no result!
             battle.scene.pbHideOpponent
             pbMessage(_INTL("Ran away!"))
             battle.decision = 1
        when 1
            battle.scene.disappearBar
            battle.battlers[1].pbLowerStatStage(:EVASION,1,battle.battlers[0]) if battle.battlers[0].pbCanLowerStatStage?(:EVASION)
            battle.scene.pbHideOpponent
        end
    }

    #===============================================================================
    #Punk Girls and Guys (As Mordecai)
    #===============================================================================

    #Beacon Rooftop
    PunkBradey=Proc.new{|battle|
        battle.scene.pbShowOpponent(0)
        battle.scene.appearBar
        # Play animation and inflict Perish Song
        cmd = pbMessage(_INTL("\\xn[Punk Bradey]Eh heh heh... Wanna' listen to my latest mixtape?"), [_INTL("Heck yeah!"),_INTL("I prefer electro-polka.")])
        case cmd
        when 0
            battle.pbAnimation(:PERISHSONG,battle.battlers[1],battle.battlers[0])
            pbMessage(_INTL("{1} has three turns to live and cannot escape!", battle.battlers[0].pbThis))
            pbMessage(_INTL("\\xn[\\PN] Meep! {1}, forgive me!", battle.battlers[0].pbThis))
            battle.battlers[0].effects[PBEffects::PerishSong]     = 4
            battle.battlers[0].effects[PBEffects::NoRetreat]      = true
        when 1
            pbMessage(_INTL("\\xn[Punk Bradey] ...Ok."))
        end
        battle.scene.disappearBar
        battle.scene.pbHideOpponent
    }

    #Aurora Downs
    PunkMaddox=Proc.new{|battle|
        battle.scene.pbShowOpponent(0)
        battle.scene.appearBar
        pbMessage(_INTL("\\xn[Punk Maddox]Think you're PREPARED?"))
        pbMessage(_INTL("\\xn[\\PN]Why are YOU talking LIKE that?"))
        pbMessage(_INTL("\\xn[Punk Maddox]..."))
        battle.battlers[0].pbLowerStatStage(:ATTACK,1,battle.battlers[0]) if battle.battlers[0].pbCanLowerStatStage?(:ATTACK)
        battle.battlers[0].pbLowerStatStage(:SPECIAL_ATTACK,1,battle.battlers[0]) if battle.battlers[0].pbCanLowerStatStage?(:SPECIAL_ATTACK)
        pbMessage(_INTL("\\xn[\\PN] Meep!"))
        battle.scene.disappearBar
        battle.scene.pbHideOpponent
    }

    #Aurora Downs
    PunkXander1=Proc.new{|battle|
         battle.scene.pbShowOpponent(0)
         battle.scene.appearBar
         pbMessage(_INTL("\\xn[Punk Xander]And you know what else is whack?"))
         pbMessage(_INTL("\\xn[\\PN]What?"))
         pbMessage(_INTL("\\xn[Punk Xander]This!"))
         pbMessage(_INTL("A substitute appeared in front of {1}!", battle.battlers[1].name))
         battle.battlers[1].effects[PBEffects::Substitute]   = [battle.battlers[1].totalhp / 4, 1].max
         pbMessage(_INTL("\\xn[\\PN]No fair! That really is wack!"))
         battle.scene.disappearBar
         battle.scene.pbHideOpponent
    }

    PunkXander2=Proc.new{|battle|
        battle.scene.pbShowOpponent(0)
        battle.scene.appearBar
        pbMessage(_INTL("\\xn[\\PN]Let's see how you like a dose of pocket sand!"))
        battle.pbAnimation(:SANDATTACK,battle.battlers[1],battle.battlers[0])
        battle.scene.disappearBar
        battle.battlers[1].pbLowerStatStage(:EVASION,1,battle.battlers[0]) if battle.battlers[0].pbCanLowerStatStage?(:EVASION)
        pbMessage(_INTL("\\xn[Punk Xander]It's wack, it's wack!"))
        battle.scene.pbHideOpponent
    }

    #===============================================================================
    #Fighting Mordecai (Hotel District)
    #===============================================================================
    
    MordecaiHotel=Proc.new{|battle|
        battle.scene.pbShowOpponent(0)
        battle.scene.appearBar
        pbMessage(_INTL("\\xn[Mordecai] Snipsnaps, no!"))
        pbMessage(_INTL("Mordecai jumped in front of the attack!"))
        pbSEPlay("Battle damage weak")
        pbMessage(_INTL("\\xn[\\PN] KID!"))
        pbMessage(_INTL("\\xn[Mordecai] Oww..."))
        pbMessage(_INTL("\\xn[\\PN] DON'T DO THAT AGAIN!"))
        pbMessage(_INTL("\\xn[Mordecai] You were gonna' hurt Snipsnaps!"))
=begin
        cmd = pbMessage(_INTL("\\xn[\\PN](Geeze, maybe I should just stop things before they get out of hand)"), [_INTL("It's for the best."),_INTL("Eh, he'll be fine.")])
        case cmd
        when 0
            # Make bar disappear
            battle.scene.disappearBar
            # End the battle with no result!
            battle.scene.pbHideOpponent
            pbMessage(_INTL("\\xn[\\PN] Enough."))
            battle.decision = 1
        when 1
=end
            battle.scene.disappearBar
            battle.scene.pbHideOpponent
        #end
    }

    #===============================================================================
    #Fighting Adamant (Dreepy Battle)
    #===============================================================================
    
    Dreepy=Proc.new{|battle|
        battle.scene.appearBar
        # Change sprite
        TrainerDialogue.changeTrainerSprite("DREEPY_ANGRY",battle.scene)
        battle.scene.pbShowOpponent(0)
        pbMessage(_INTL("Chomp!"))
        pbSEPlay("Battle damage weak")
        battle.scene.pbHideOpponent
        TrainerDialogue.changeTrainerSprite("ADAMANT",battle.scene)
        battle.scene.pbShowOpponent(0)
        pbMessage(_INTL("\\xn[???] GRAH! STUPID DREEPY!"))
        battle.scene.pbHideOpponent
        TrainerDialogue.changeTrainerSprite("DREEPY_LAUGHING",battle.scene)
        battle.scene.pbShowOpponent(0)
        Pokemon.play_cry(:DREEPY) 
        # Adamant gets distracted, Pokémon gets confused and evasion lowered
        pbMessage(_INTL("The pain of the bite distracted him!"))
        battle.scene.pbHideOpponent
        TrainerDialogue.changeTrainerSprite("ADAMANT",battle.scene)
        battle.scene.pbShowOpponent(0)
        pbMessage(_INTL("\\xn[???]Use, uh- No wait..."))
        battle.scene.disappearBar
        # Yes, you get a free extra evasion decrease if his mon's already confused. 
        # In the rare circumstance that his mon is both confused and at the lowest possible evasion level, well, you're SOL. Sorry. 
        if battle.battlers[1].pbCanConfuse?(battle.battlers[0], false)
            battle.battlers[1].pbConfuse
            battle.battlers[1].pbLowerStatStage(:ACCURACY, 1, battle.battlers[0]) if battle.battlers[1].pbCanLowerStatStage?(:ACCURACY)
        else
            battle.battlers[1].pbLowerStatStage(:ACCURACY, 2, battle.battlers[0]) if battle.battlers[1].pbCanLowerStatStage?(:ACCURACY) 
        end
        
        battle.scene.pbHideOpponent
    }

#===============================================================================
#Shiny Trainers
#===============================================================================

 #Confusion Version
 Shiny1=Proc.new{|battle|
    battle.scene.appearBar
    pbSEPlay("Shiny")
    pbMessage(_INTL("A blinding light shone!"))
    battle.scene.disappearBar
    if battle.battlers[0].pbCanConfuse?(battle.battlers[1],false)
        battle.battlers[0].pbConfuse
    else
        pbMessage(_INTL("But nothing happened!"))
    end
    battle.scene.disappearBar
}

#Increase player's accuracy version
Shiny2=Proc.new{|battle|
    battle.scene.appearBar
    pbSEPlay("Shiny")
    pbMessage(_INTL("\\xn[\\PN]The distinctive colours made it easier for {1} to follow it!", battle.battlers[0].pbThis))
    battle.scene.disappearBar
    battle.battlers[0].pbRaiseStatStage(:ACCURACY, 1, battle.battlers[0]) if battle.battlers[0].pbCanRaiseStatStage?(:ACCURACY)
}

#===============================================================================
# Francis Battle (VS Mordecai in Case 19)
#===============================================================================
FrancisQ1=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    cmd = pbMessage(_INTL("\\xn[Francis]Question time! What's Priya's favourite colour?"), [_INTL("Blue!"),_INTL("Purple!")])
    case cmd
    when 0
        pbMessage(_INTL("\\xn[Francis]Actually, Priya mostly wears royal blue because it best suits her complexion! Her real favourite colour is purple!"))
        pbMessage(_INTL("\\xn[Francis]She takes her costuming advice from Sammy very seriously, ever since-"))
        pbMessage(_INTL("\\xn[\\PN]Boring!"))
        battle.scene.disappearBar
        if battle.battlers[0].pbCanSleep?(battle.battlers[0],false)
            battle.battlers[0].pbSleep
        else
            pbMessage(_INTL("\\xn[\\PN]Boring!"))
        end
    when 1
        pbMessage(_INTL("\\xn[Francis]Hrmph. That's right. But you don't know as much as I do about Priya!"))
        battle.scene.disappearBar
        battle.battlers[0].pbRaiseStatStage(:ATTACK,1,battle.battlers[0]) if battle.battlers[0].pbCanRaiseStatStage?(:ATTACK)
        battle.battlers[0].pbRaiseStatStage(:SPECIAL_ATTACK,1,battle.battlers[0]) if battle.battlers[0].pbCanRaiseStatStage?(:SPECIAL_ATTACK)
        battle.battlers[0].pbRaiseStatStage(:SPEED,1,battle.battlers[0]) if battle.battlers[0].pbCanRaiseStatStage?(:SPEED)
    end
    battle.scene.pbHideOpponent
}

FrancisQ2=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    cmd = pbMessage(_INTL("\\xn[Francis]Question! How many plays has Priya been in that were directed by Sean Lafayette?"), [_INTL("5"),_INTL("3"),_INTL("10"),_INTL("7")])
    case cmd
    when 3
        pbMessage(_INTL("\\xn[Francis]...Rrr... How do you know... That?!"))
        battle.scene.disappearBar
        battle.battlers[1].pbLowerStatStage(:DEFENSE,1,battle.battlers[1]) if battle.battlers[1].pbCanLowerStatStage?(:DEFENSE)
        battle.battlers[1].pbLowerStatStage(:SPECIAL_DEFENSE,1,battle.battlers[1]) if battle.battlers[1].pbCanLowerStatStage?(:SPECIAL_DEFENSE)
    else
        pbMessage(_INTL("\\xn[Francis]Wah ha ha! WRONG!"))
        battle.scene.disappearBar
    end
    battle.scene.pbHideOpponent
}

FrancisQ3=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Francis]You'll NEVER guess this one. TRUE or FALSE"))
    cmd = pbMessage(_INTL("\\xn[Francis]Priya secretly longs to play the lead in 'I Want to Be Your Canary!'"), [_INTL("Tralse!"),_INTL("What's a canary?"),_INTL("Flue"),_INTL("True!")])
    case cmd
    when 0
        pbMessage(_INTL("\\xn[Francis]T-Tralse? H-how could you know she loves the playwright Tralse..."))
        pbMessage(_INTL("\\xn[Francis]It's not FAIR! I'M HER BIGGEST FAN, NOT YOU!"))
        battle.scene.disappearBar
        battle.battlers[1].pbUseMoveSimple(:EXPLOSION, battle.battlers[0])
    else
        pbMessage(_INTL("\\xn[Francis]Heehee, hooho!"))
        battle.scene.disappearBar
    end
    battle.scene.pbHideOpponent
}

#===============================================================================
# Lonardo Casino - Dealers
#===============================================================================

    Dealer=Proc.new{|battle|
        battle.scene.pbShowOpponent(0)
        battle.scene.appearBar
        pbMessage(_INTL("\\xn[Dealer]Distraction!"))
        battle.scene.disappearBar
        battle.pbAnimation(:PAYDAY, battle.battlers[1], battle.battlers[0])
        battle.pbLowerHP(battle.battlers[1], 4) #Removes 1/4 of its total hp
        battle.field.effects[PBEffects::PayDay] += 5 * battle.battlers[1].level
        battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
        battle.scene.pbHideOpponent
        # Faint check
        battle.battlers[1].pbItemHPHealCheck
        battle.battlers[1].pbFaint if battle.battlers[1].fainted?
    }

#===============================================================================
# Sylvester II - "How many times do we have to teach you this lesson old man?"
#===============================================================================

#These are for the Denial District fight

SylII1=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("Sylvester II prayed deeply..."))
    battle.scene.disappearBar
    if battle.battlers[1].attack > battle.battlers[1].spatk
        battle.battlers[1].pbRaiseStatStage(:ATTACK,1, battle.battlers[1])
    else
        battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,1, battle.battlers[1]) 
    end
    battle.scene.pbHideOpponent
}

SylII2=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[\\PN]I'm a Lafayette too, old man. Watch this!"))
    pbMessage(_INTL("Sylvester prayed deeply..."))
    battle.scene.disappearBar
    if battle.battlers[0].attack > battle.battlers[0].spatk
        battle.battlers[0].pbRaiseStatStage(:ATTACK, 1, battle.battlers[0])
    else
        battle.battlers[0].pbRaiseStatStage(:SPECIAL_ATTACK, 1, battle.battlers[0]) 
    end
    pbMessage(_INTL("\\xn[\\PN](Wow, I can't believe that actually worked.)"))
    battle.scene.pbHideOpponent
}

SylII3=Proc.new{|battle|
    battle.scene.appearBar
    # Change sprite
    battle.pbCommonAnimation("MegaEvolution", battle.battlers[1])
    battle.battlers[1].pbChangeForm(1, nil)
    battle.scene.sprites["pokemon_1"].setPokemonBitmapSpecies(battle.battlers[1].pokemon,:MOLTRES, false)
    # Display message and use move
    pbMessage(_INTL("{1} answered Sylvester II's prayers! It used {2}!", GameData::Species.get(:MOLTRES).name, GameData::Move.get(:FIERYWRATH).name))
    battle.scene.appearDatabox
    battle.battlers[1].pbChangeForm(0, nil)
    battle.battlers[1].pbUseMoveSimple(:FIERYWRATH, battle.battlers[1].pbDirectOpposing.index)
    battle.scene.disappearBar
}

SylII4=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("Sylvester II prayed deeply..."))
    battle.scene.disappearBar
    battle.battlers[1].pbRecoverHP(battle.battlers[1].totalhp - battle.battlers[1].hp)
    battle.battlers[1].pbCureStatus(false)
    battle.pbDisplay(_INTL("{1}'s HP was restored.", battle.battlers[1].pbThis))
    battle.scene.pbHideOpponent
}

#These are for the Northallow Grove fight

SylIIA=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    cmd = pbMessage(_INTL("\\xn[Sylvester II]Do you believe in ghosts?"), [_INTL("Well, I'm looking at one."),_INTL("You're a hallucination, old man.")])
    case cmd
    when 0
        pbMessage(_INTL("\\xn[Sylvester II]So there are believers after all..."))
        pbMessage(_INTL("\\xn[\\PN]Oh, I believe alright. Believe that you're a total cretin."))
        pbMessage(_INTL("\\xn[Sylvester II]Heeheehee... So you can see that white hand on your shoulder."))
    else
        pbMessage(_INTL("\\xn[\\PN]You're not a ghost in the traditional sense."))
        pbMessage(_INTL("\\xn[\\PN]Rather, ghost Pokémon merely use the memories of their victims and those near by to create realistic illusions."))
        pbMessage(_INTL("\\xn[\\PN]You can't do me any true harm."))
        pbMessage(_INTL("\\xn[Sylvester II]Heeheehee... That white hand on your shoulder, then, it's not real."))
    end
    pbMessage(_INTL("\\xn[\\PN]Huh?"))
    pbSEPlay("Blow1")
    pbMessage(_INTL("\\xn[\\PN]OW!"))
    pbMessage(_INTL("\\xn[Sylvester II]Believe in me now, disappointment?!"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

SylIIB=Proc.new{|battle|
    next if battle.battlers[0].fainted?
    battle.scene.appearBar
    battle.scene.pbShowOpponent(0)
    # Play animation and inflict curse
    battle.pbAnimation(:PERISHSONG, battle.battlers[0].pbDirectOpposing(true), battle.battlers[0])
    pbMessage(_INTL("\\xn[Sylvester II]Honteux! Traître!"))
    pbMessage(_INTL("\\w[battle]Sylvester II hissed a murderous dirge! {1} has three turns to live and cannot escape!", battle.battlers[0].pbThis))
    battle.battlers[0].effects[PBEffects::PerishSong]     = 4
    battle.battlers[0].effects[PBEffects::NoRetreat]      = true
    pbMessage(_INTL("\\xn[\\PN]How original."))
    battle.scene.pbHideOpponent
    battle.scene.disappearBar
}

SylIIC=Proc.new{|battle|
    next if battle.battlers[0].fainted?
    battle.scene.appearBar
    battle.scene.pbShowOpponent(0)
    # Play animation and inflict curse
    battle.pbAnimation(:CURSE, battle.battlers[0].pbDirectOpposing(true), battle.battlers[0])
    pbMessage(_INTL("\\xn[Sylvester II]Filthy wastrel! Your line ends here!"))
    pbMessage(_INTL("\\w[battle]Sylvester II laid a curse on {1}!", battle.battlers[0].pbThis))
    battle.battlers[0].effects[PBEffects::Curse] = true
    pbMessage(_INTL("\\xn[\\PN]Rude."))
    battle.scene.pbHideOpponent
    battle.scene.disappearBar
}

#===============================================================================
# Mordecai vs the Bandit - Morove Wilds
#===============================================================================

Bandit1=Proc.new{|battle|
    battle.scene.appearBar
    pbMessage(_INTL("Fearow zapped back, through the bars of the cage!"))
    battle.scene.disappearBar
    battle.pbAnimation(:THUNDERSHOCK,battle.battlers[0],battle.battlers[1])
    battle.pbLowerHP(battle.battlers[1], 4)
    pbMessage(_INTL("\\xn[\\PN]Show him who's boss, Fearow!"))
    # Faint check
    battle.battlers[1].pbItemHPHealCheck
    battle.battlers[1].pbFaint if battle.battlers[1].fainted?
}

Bandit2=Proc.new{|battle|
    battle.scene.appearBar
    pbMessage(_INTL("Fearow zapped back, through the bars of the cage!"))
    battle.scene.disappearBar
    battle.pbAnimation(:CHARGE,battle.battlers[0],battle.battlers[0])
    battle.battlers[0].pbRecoverHP(battle.battlers[0].totalhp - battle.battlers[0].hp)
    battle.battlers[1].pbCureStatus(false)
    battle.pbDisplay(_INTL("{1} was recharged by the zap!", battle.battlers[0].pbThis))
    pbMessage(_INTL("\\xn[\\PN]Thanks for the boost, Fearow!"))
}

#===============================================================================
# Mordecai Cheering Fearow on (Leo Fight, Sawyer Fight, etc.)
#===============================================================================

#Entering a battle 
Fearow1=Proc.new{|battle|
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[\\PN]Show 'em what you're made of, Fearow!"))
    battle.scene.disappearBar
    battle.battlers[0].pbRaiseStatStage(:ATTACK, 1, battle.battlers[0])
    #battle.battlers[0].pbRaiseStatStage(:SPECIAL_ATTACK,1,battle.battlers[0])
}

#For low HP 
Fearow2=Proc.new{|battle|
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[\\PN]Hang in there, buddy!"))
    battle.scene.disappearBar
    battle.battlers[0].effects[PBEffects::Endure] = true
    pbMessage(_INTL("Fearow braced itself to endure another hit!"))
}

#For taking high damage
Fearow3=Proc.new{|battle|
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[\\PN]Ouch! You ok Fearow?"))
    Pokemon.play_cry(:ZAPDOS) 
    battle.scene.disappearBar
    battle.battlers[0].effects[PBEffects::LaserFocus] = 2
    pbMessage(_INTL("Mordecai's concern for Fearow increased its determination!"))
}

#===============================================================================
# IV Trainers
#===============================================================================

#HP
IVHP=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[HPerina]Watch out!"))
    battle.scene.disappearBar
    battle.battlers[1].pbRecoverHP(battle.battlers[1].totalhp - battle.battlers[1].hp)
    battle.battlers[1].pbCureStatus(false)
    battle.pbDisplay(_INTL("{1}'s HP was restored.", battle.battlers[1].pbThis))
    battle.scene.pbHideOpponent
}

#Attack 
IVAtk=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Attackernan]Watch out!"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
    battle.battlers[1].pbRaiseStatStage(:ATTACK,1,battle.battlers[1])
}

#Special Attack 
IVSpAtk=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Specialattackelle]Watch out!"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
    battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,1,battle.battlers[1])
}

#Defense
IVDef=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Defensiano]Watch out!"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
    battle.battlers[1].pbRaiseStatStage(:DEFENSE,1,battle.battlers[1])
}

#Special Defense
IVSpDef=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Specialdefenssa]Watch out!"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
    battle.battlers[1].pbRaiseStatStage(:SPECIAL_DEFENSE,1,battle.battlers[1])
}

#Speed
IVSpeed=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Specialdefenssa]Watch out!"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
    battle.battlers[1].pbRaiseStatStage(:SPEED,1,battle.battlers[1])
}

#===============================================================================
# Denial Denizens
#===============================================================================

#Summon Sun
Denial1=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Denial Denizen]La, la la~!"))
    pbMessage(_INTL("The Denial Denizen sang a song of sun!"))
    battle.pbStartWeather(battle.battlers[1],:Sun)
    battle.scene.disappearBar
    battle.scene.pbHideOpponent

}

#Restore HP by building a sandcastle
Denial2=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Denial Denizen]La, la la~!"))
    pbMessage(_INTL("\\xn[Denial Denizen]Time for a break to build a sandcastle~!"))
    battle.scene.disappearBar
    battle.battlers[1].pbRecoverHP(battle.battlers[1].totalhp - battle.battlers[1].hp)
    battle.battlers[1].pbCureStatus(false)
    battle.pbDisplay(_INTL("{1}'s HP was restored.", battle.battlers[1].pbThis))
    battle.scene.pbHideOpponent
}

#===============================================================================
# Leo in the Crypt
#===============================================================================

#After the first round
Leo1=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Leo]Opening with that? You never fail to be predictable, Syl."))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

#Small damage
Leo2=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Leo]Really? That's what you're going for?"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

#Syl's Pokémon faints
Leo3=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Leo]Think! Don't let yourself get distracted."))
    pbMessage(_INTL("\\xn[\\PN]Save your chirping for the hockey games. I can hardly think."))
    pbMessage(_INTL("\\xn[Leo]Exactly."))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

#===============================================================================
# Corrupt Doctor
#===============================================================================

#After the first round
Doctor1=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[\\PN]Who put you up to this? Why are you playing along?!"))
    pbMessage(_INTL("\\xn[Doctor]..."))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

#Attack selection with the second round
Doctor2=Proc.new{|battle|
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Luciano]*hack* *cough* *wheeze*"))
    pbMessage(_INTL("\\xn[Luciano]...Rose. Help him."))
    Pokemon.play_cry(:CACTURNE) 
    battle.pbAnimation(:TOXICSPIKES,battle.battlers[0],battle.battlers[1])
    battle.battlers[0].pbOpposingSide.effects[PBEffects::ToxicSpikes] += 1
    battle.scene.disappearBar
}

#After the third round
Doctor3=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[\\PN]It's overkill, it's torture!"))
    pbMessage(_INTL("\\xn[Doctor]...They wanted him to suffer."))
    pbMessage(_INTL("\\xn[\\PN]Making an example out of him? And for WHAT?"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

#Attack selection with the fourth round
Doctor4=Proc.new{|battle|
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Luciano]*hack* *cough* *wheeze*"))
    pbMessage(_INTL("\\xn[Luciano]...Rose... Rose..."))
    Pokemon.play_cry(:CACTURNE) 
    pbWait(0.125)
    pbSEPlay("Battle throw")
    battle.pbLowerHP(battle.battlers[1], 4) #Removes 1/4 of its total hp
    pbMessage(_INTL("Rose threw a Sticky Barb at the enemy!"))
    battle.scene.disappearBar
    # Faint check
    battle.battlers[1].pbItemHPHealCheck
    battle.battlers[1].pbFaint if battle.battlers[1].fainted?
}

#Last Pokémon
Doctor5=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[\\PN]Answer me!"))
    pbMessage(_INTL("\\xn[Doctor]..."))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}


#===============================================================================
# Lafayette Gangster Battles (Both of Severn's Stories)
#===============================================================================

Lafayette1=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("The Lafayette prayed deeply..."))
    variable = rand(1..5)
        case variable 
        when 1 #Nothing
             pbMessage(_INTL("But nobody answered..."))
             battle.scene.disappearBar
        when 2 #Does some damage
            Pokemon.play_cry(:MOLTRES, 0, 100, 60) 
            pbMessage(_INTL("But Moltres is displeased with him..."))
            battle.scene.disappearBar
            battle.pbAnimation(:OVERHEAT, battle.battlers[1], battle.battlers[1])
            battle.pbLowerHP(battle.battlers[1], 4) #Removes 1/4 of its total hp
            # Faint check
            battle.battlers[1].pbItemHPHealCheck
            battle.battlers[1].pbFaint if battle.battlers[1].fainted?
        when 3 # Sets the Holy Inferno weather 
            pbMessage(_INTL("But Moltres is furious with him..."))
            battle.scene.disappearBar
            battle.pbStartWeather(battle.battlers[1], :HolyInferno)
            Pokemon.play_cry(:MOLTRES, 0, 100, 60) 
        when 4 # Burns 
            Pokemon.play_cry(:MOLTRES, 0, 100, 60) 
            pbMessage(_INTL("But Moltres has seen his sins..."))
            battle.scene.disappearBar
            battle.battlers[1].pbBurn if battle.battlers[1].pbCanBurn?(battle.battlers[0], false)
        when 5 #Heal Block
            Pokemon.play_cry(:MOLTRES,0,100,60) 
            pbMessage(_INTL("But Moltres knows his prayers are selfish..."))
            battle.scene.disappearBar
            battle.pbAnimation(:HEALBLOCK, battle.battlers[1], battle.battlers[1])
            battle.battlers[1].effects[PBEffects::HealBlock] = 5 
            battle.pbDisplay(_INTL("{1} can no longer heal!", battle.battlers[1].pbThis))
        end
    battle.scene.pbHideOpponent
}

#===============================================================================
# Lustrous Case 14 Fight
#===============================================================================

#Low HP
LustrousHP=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Lustrous]How do you save a dying pirate?"))
    pbMessage(_INTL("\\xn[Lustrous]CPAAAAAR!"))
    battle.scene.disappearBar
    battle.battlers[1].pbRecoverHP(battle.battlers[1].totalhp - battle.battlers[1].hp)
    battle.battlers[1].pbCureStatus(false)
    battle.pbDisplay(_INTL("{1}'s HP was restored.", battle.battlers[1].pbThis))
    battle.scene.pbHideOpponent
}

#Attack - Turn 0
LustrousAtk=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Lustrous]How much did the pirate pay for his peg and hook?"))
    pbMessage(_INTL("\\xn[Lustrous]An arm and a leg!"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
    battle.battlers[1].pbRaiseStatStage(:ATTACK,1,battle.battlers[1])
}

#Special Attack - When player deals small damage
LustrousSpAtk=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Lustrous]To err is human."))
    pbMessage(_INTL("\\xn[Lustrous]To arr is pirate!"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
    battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,1,battle.battlers[1])
}

#Defense - When player deals Big Damage
LustrousDef=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Lustrous]How do you save a dying pirate?"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
    battle.battlers[1].pbRaiseStatStage(:DEFENSE,1,battle.battlers[1])
}

#Special Defense - When at half HP
LustrousSpDef=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Lustrous]What’s the difference between a pirate and a cranberry farmer?"))
    pbMessage(_INTL("\\xn[Lustrous]A pirate buries his treasure, but a cranberry farmer treasures his berries!"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
    battle.battlers[1].pbRaiseStatStage(:SPECIAL_DEFENSE,1,battle.battlers[1])
}

#Speed - If player recalls their Pokémon
LustrousSpeed=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Lustrous]Where can you find a pirate who has lost his wooden legs?"))
    pbMessage(_INTL("\\xn[Lustrous]Right where ye left him!"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
    if battle.battlers[1].pbHasMoveFunction?("StartSlowerBattlersActFirst")
        battle.battlers[1].pbLowerStatStage(:SPEED,1,battle.battlers[1])
    else
        battle.battlers[1].pbRaiseStatStage(:SPEED,1,battle.battlers[1])
    end
}

#===============================================================================
# Low-Level Gangster Effects
#===============================================================================

#Attack selection with the second round
GangsterTruant=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Gangster]Gah! Stupid, worthless-!"))
    battle.battlers[1].ability = :TRUANT #Ekat Note: Doesn't work
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

#Limegate Park - Girl with the books quest
GangsterBook=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbSEPlay("Battle throw")
    pbMessage(_INTL("The gangster throws an encyclopedia!"))
    pbSEPlay("Battle damage normal")
    battle.scene.disappearBar
    battle.pbLowerHP(battle.battlers[0], 4) #Removes 1/4 of its total hp
    battle.scene.pbHideOpponent
    # Faint check
    battle.battlers[0].pbItemHPHealCheck
    battle.battlers[0].pbFaint if battle.battlers[0].fainted?
}

#Outdoors - throws a snowball
GangsterSnowball=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbSEPlay("Battle throw")
    pbMessage(_INTL("The gangster throws a snowball!"))
    random_line = rand(1..2)
    case random_line 
    when 1
        pbSEPlay("Battle damage normal")
        battle.scene.disappearBar
        battle.pbLowerHP(battle.battlers[0], 4) #Removes 1/4 of its total hp
        battle.scene.pbHideOpponent
        # Faint check
        battle.battlers[0].pbItemHPHealCheck
        battle.battlers[0].pbFaint if battle.battlers[0].fainted?
    when 2 
        pbMessage(_INTL("But it missed!"))
        # Throw snowball back
        cmd = pbMessage(_INTL("\\xn[\\PN](Should I throw one back?)"), [_INTL("Yes!"),_INTL("No!")])
        case cmd
        when 0
            pbMessage(_INTL("\\xn[Gangster]No fair!"))
            battle.scene.disappearBar
            if battle.battlers[1].pbCanFreeze?(battle.battlers[0], false)
                battle.battlers[1].pbFreeze
            else
                pbMessage(_INTL("But it missed!"))
                battle.scene.disappearBar
            end
        when 1
            battle.scene.disappearBar
        end
    end
    battle.scene.pbHideOpponent
}

#Knife - Gangster
GangsterKnife=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("The Gangster takes out a knife!"))
    random_line = rand(1..6)
    case random_line 
    when 1 #Lowers Enemy's Attack
      #  battle.battlers[0].pbLowerStatStage(:SPEED,2,battle.battlers[0]) if battle.battlers[0].pbCanLowerStatStage?(:SPEED)
        pbMessage(_INTL("Sylvester brandishes his own knife in return!"))
        pbMessage(_INTL("\\xn[\\PN]Two can play at this game."))
        pbMessage(_INTL("\\xn[Gangster]W-whoa! Play nice!"))
        battle.scene.disappearBar
        battle.battlers[1].pbLowerStatStage(:ATTACK,2,battle.battlers[0]) if battle.battlers[1].pbCanLowerStatStage?(:ATTACK)
    when 2 #Lowers Enemy's Special Attack
       # battle.battlers[0].pbLowerStatStage(:ATTACK,2,battle.battlers[0]) if battle.battlers[0].pbCanLowerStatStage?(:ATTACK)
        pbMessage(_INTL("Sylvester brandishes his own knife in return!"))
        pbMessage(_INTL("\\xn[\\PN]Now you're really ticking me off."))
        pbMessage(_INTL("\\xn[Gangster]..."))
        battle.scene.disappearBar
        battle.battlers[1].pbLowerStatStage(:SPECIAL_ATTACK,2,battle.battlers[0]) if battle.battlers[1].pbCanLowerStatStage?(:SPECIAL_ATTACK)
    when 3 #Lowers Player's Defense
        pbMessage(_INTL("\\xn[\\PN]Gah, where'd I put my knife?"))
        battle.scene.disappearBar
        battle.battlers[0].pbLowerStatStage(:DEFENSE,2,battle.battlers[1]) if battle.battlers[0].pbCanLowerStatStage?(:DEFENSE)
    when 4 #Lowers Player's Special Defense
        pbMessage(_INTL("\\xn[\\PN]Gah, where'd I put my knife?"))
        battle.scene.disappearBar
        battle.battlers[0].pbLowerStatStage(:SPECIAL_DEFENSE,2,battle.battlers[1]) if battle.battlers[0].pbCanLowerStatStage?(:SPECIAL_DEFENSE)
    when 5 #Raises Attack (Out of Spite)
        pbMessage(_INTL("\\xn[\\PN]Get out of my way."))
        pbMessage(_INTL("\\xn[Gangster]No, I don't think I will."))
        battle.scene.disappearBar
        battle.battlers[1].pbRaiseStatStage(:ATTACK,1,battle.battlers[1]) if battle.battlers[1].pbCanRaiseStatStage?(:ATTACK)
    when 6 #Raises Defense (Out of Spite)
        pbMessage(_INTL("\\xn[\\PN]Uh, shoo?"))
        pbMessage(_INTL("\\xn[Gangster]You don't scare me, Lafayette!"))
        battle.scene.disappearBar
        battle.battlers[1].pbRaiseStatStage(:DEFENSE,1,battle.battlers[1]) if battle.battlers[1].pbCanRaiseStatStage?(:DEFENSE)
    end
    battle.scene.pbHideOpponent
}

GangsterBurger=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Gangster]Ah, at times like this, it calls for a snack break!"))
    cmd = pbMessage(_INTL("\\xn[Gangster]Here, want one of my extra burgers?"), [_INTL("Let's eat!"),_INTL("I'm good.")])
    case cmd
    when 0
        pbMessage(_INTL("\\xn[Gangster]Enjoy!"))
        battle.scene.disappearBar
        battle.battlers[1].pbRecoverHP(battle.battlers[1].totalhp - battle.battlers[1].hp)
        battle.battlers[1].pbCureStatus(false)
        battle.pbDisplay(_INTL("{1}'s HP was restored.", battle.battlers[1].pbThis))
        battle.battlers[0].pbRecoverHP(battle.battlers[0].totalhp - battle.battlers[0].hp)
        battle.battlers[0].pbCureStatus(false)
        battle.pbDisplay(_INTL("{1}'s HP was restored.", battle.battlers[0].pbThis))
        battle.scene.pbHideOpponent
    when 1
        pbMessage(_INTL("\\xn[Gangster]Fine, {1} and I will eat them!", battle.battlers[1].pbThis))
        battle.scene.disappearBar
        battle.battlers[1].pbRecoverHP(battle.battlers[1].totalhp - battle.battlers[1].hp)
        battle.battlers[1].pbCureStatus(false)
        battle.pbDisplay(_INTL("{1}'s HP was restored.", battle.battlers[1].pbThis))
        battle.pbAnimation(:REST, battle.battlers[1], battle.battlers[1])
        battle.battlers[1].pbSleep if battle.battlers[1].pbCanSleep?(battle.battlers[0], false) 
        pbMessage(_INTL("\\xn[Gangster]Oh no, the food coma is setting in!"))
    end
    battle.scene.pbHideOpponent
}

#Lonardo Warehouse
GangsterWhine=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Mafioso]Ugh, I change my mind, this is a total waste of my time."))
    pbMessage(_INTL("\\xn[\\PN]Hey! But you're the one who challenged me!"))
    pbMessage(_INTL("\\xn[Mafioso]Yeah, because it's the International Rule of Trainer Engagement!"))
    pbMessage(_INTL("\\xn[\\PN]Oh, so you'll follow that rule, but you're willing to break the law working for the Lonardos?"))
    pbMessage(_INTL("\\xn[Mafioso]That's apples and oranges, bruh! This fight isn't paying me a nice salary!"))
    cmd = pbMessage(_INTL("\\xn[\\PN](He doesn't want to fight, should I end the battle here?)"), [_INTL("Let's call it a wrap."),_INTL("Back to work, slacker! Fight me!")])
    case cmd
    when 0
        # Make bar disappear
         pbMessage(_INTL("\\xn[Mafioso]Huh, end things here? Fine with me!"))
         battle.scene.disappearBar
         # End the battle
         battle.scene.pbHideOpponent
         battle.decision = 1
    when 1
        pbMessage(_INTL("\\xn[Mafioso]*groan*"))
        battle.scene.disappearBar
        battle.scene.pbHideOpponent
    end
}

#Thief
GangsterThief=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    battle.pbAnimation(:THIEF,battle.battlers[1],battle.battlers[0])
    pbMessage(_INTL("\\xn[Gangster]Yoink!"))
    battle.scene.disappearBar
    battle.battlers[1].pbUseMoveSimple(:THIEF, battle.battlers[0]) #Ekat Note: Doesn't work
    battle.scene.pbHideOpponent
}

#Fling
GangsterFling=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    battle.pbAnimation(:FLING,battle.battlers[1],battle.battlers[0])
    pbMessage(_INTL("\\xn[Gangster]Bonk!"))
    battle.scene.disappearBar
    battle.battlers[1].pbUseMoveSimple(:FLING, battle.battlers[0]) #Ekat Note: Doesn't work
    battle.scene.pbHideOpponent
}

#===============================================================================
# Mafioso-Level Gangster Effects
#===============================================================================

#SS. Suosirg
MafiosoThrowingKnife=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("The mafioso sends out a throwing knife!"))
    pbSEPlay("Battle damage normal")
    battle.scene.disappearBar
    battle.pbLowerHP(battle.battlers[0], 4) #Removes 1/4 of its total hp
    battle.scene.pbHideOpponent
    # Faint check
    battle.battlers[0].pbItemHPHealCheck
    battle.battlers[0].pbFaint if battle.battlers[0].fainted?
}

#Various negative effects that can happen in the Smuggling Tunnels and B2 of the SS. Suosirg
MafiosoCage=Proc.new{|battle|
    battle.scene.appearBar
    poke_effect = rand(1..5)
    case poke_effect 
    when 1 # Screech
        pbMessage(_INTL("Pokémon screech from behind the bars of their cages!"))
        battle.scene.disappearBar
        battle.battlers[1].pbLowerStatStage(:DEFENSE,2,battle.battlers[1]) if battle.battlers[1].pbCanLowerStatStage?(:DEFENSE)
    when 2 # Growl
        pbMessage(_INTL("Pokémon growl from behind the bars of their cages!"))
        battle.scene.disappearBar
        battle.battlers[1].pbLowerStatStage(:ATTACK,1,battle.battlers[1]) if battle.battlers[1].pbCanLowerStatStage?(:DEFENSE)         
    when 3 # Attacks
        pbMessage(_INTL("A Pokémon lashes out between the bars of its cage!"))
        battle.scene.disappearBar
        battle.pbAnimation(:TACKLE,battle.battlers[1], battle.battlers[1])
        battle.pbLowerHP(battle.battlers[1], 4) #Removes 1/4 of its total hp
        # Faint check
        battle.battlers[1].pbItemHPHealCheck
        battle.battlers[1].pbFaint if battle.battlers[1].fainted?
    when 4 # Poisons
        pbMessage(_INTL("A Pokémon lashes out between the bars of its cage!"))
        battle.scene.disappearBar
        battle.pbAnimation(:TOXIC,battle.battlers[1],battle.battlers[1])
        battle.battlers[1].pbPoison if battle.battlers[1].pbCanPoison?(battle.battlers[1], false) 
    when 5 # Burns 
        pbMessage(_INTL("A Pokémon lashes out between the bars of its cage!"))
        battle.scene.disappearBar
        battle.pbAnimation(:WILLOWISP,battle.battlers[1],battle.battlers[1])
        battle.battlers[1].pbBurn if battle.battlers[1].pbCanBurn?(battle.battlers[1], false)
    end
}

#Pool Hall 
MafiosoCue=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("The mafioso charges forwards with a pool cue!"))
    pbSEPlay("Battle damage normal")
    battle.scene.disappearBar
    battle.pbLowerHP(battle.battlers[0], 4) #Removes 1/4 of its total hp
    battle.scene.pbHideOpponent
     # Faint check
    battle.battlers[0].pbItemHPHealCheck
    battle.battlers[0].pbFaint if battle.battlers[0].fainted?
}

MafiosoDrinking=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Mafioso]Hey, buddy, don't be so- *hic* uptight!"))
    cmd = pbMessage(_INTL("\\xn[Mafioso]It's happy hour! Have a drink with me!"), [_INTL("Cheers!"),_INTL("I'm good.")])
    case cmd
    when 0
        pbMessage(_INTL("\\xn[Mafioso]Cheers!"))
        battle.scene.disappearBar
        battle.battlers[1].pbRecoverHP(battle.battlers[1].totalhp - battle.battlers[1].hp)
        battle.battlers[1].pbCureStatus(false)
        battle.pbDisplay(_INTL("{1}'s HP was restored.", battle.battlers[1].pbThis))
        battle.battlers[0].pbRecoverHP(battle.battlers[0].totalhp - battle.battlers[0].hp)
        battle.battlers[0].pbCureStatus(false)
        battle.pbDisplay(_INTL("{1}'s HP was restored.", battle.battlers[0].pbThis))
        battle.scene.pbHideOpponent
    when 1
        pbMessage(_INTL("\\xn[Mafioso]Fine, {1} and I will finish off the drinks!", battle.battlers[1].pbThis))
        battle.scene.disappearBar
        battle.battlers[1].pbRecoverHP(battle.battlers[1].totalhp - battle.battlers[1].hp)
        battle.battlers[1].pbCureStatus(false)
        battle.pbDisplay(_INTL("{1}'s HP was restored.", battle.battlers[1].pbThis))
        battle.pbAnimation(:TOXIC, battle.battlers[1], battle.battlers[1])
        battle.battlers[1].pbPoison if battle.battlers[1].pbCanPoison?(battle.battlers[1], false) 
        pbMessage(_INTL("\\xn[Mafioso]Oh *hic* no! {1}!", battle.battlers[1].pbThis))
    end
    battle.scene.pbHideOpponent
}

#Knife - Mafioso
MafiosoKnife=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("The Mafioso takes out a knife!"))
    random_line = rand(1..6)
    case random_line 
    when 1 #Lowers Enemy's Attack
     #   battle.battlers[1].pbLowerStatStage(:SPEED,2,battle.battlers[0]) if battle.battlers[0].pbCanLowerStatStage?(:SPEED)
        pbMessage(_INTL("Sylvester brandishes his own knife in return!"))
        pbMessage(_INTL("\\xn[\\PN]Two can play at this game."))
        pbMessage(_INTL("\\xn[Mafioso]W-whoa! Play nice!"))
        battle.scene.disappearBar
        battle.battlers[1].pbLowerStatStage(:ATTACK,2,battle.battlers[0]) if battle.battlers[1].pbCanLowerStatStage?(:ATTACK)
    when 2 #Lowers Enemy's Special Attack
     #   battle.battlers[1].pbLowerStatStage(:ATTACK,2,battle.battlers[0]) if battle.battlers[0].pbCanLowerStatStage?(:ATTACK)
        pbMessage(_INTL("Sylvester brandishes his own knife in return!"))
        pbMessage(_INTL("\\xn[\\PN]Now you're really ticking me off."))
        pbMessage(_INTL("\\xn[Mafioso]..."))
        battle.scene.disappearBar
        battle.battlers[1].pbLowerStatStage(:SPECIAL_ATTACK,2,battle.battlers[0]) if battle.battlers[1].pbCanLowerStatStage?(:SPECIAL_ATTACK)
    when 3 #Lowers Player's Defense
        pbMessage(_INTL("\\xn[\\PN]Gah, where'd I put my knife?"))
        battle.scene.disappearBar
        battle.battlers[0].pbLowerStatStage(:DEFENSE,2,battle.battlers[1]) if battle.battlers[0].pbCanLowerStatStage?(:DEFENSE)
    when 4 #Lowers Player's Special Defense
        pbMessage(_INTL("\\xn[\\PN]Gah, where'd I put my knife?"))
        battle.scene.disappearBar
        battle.battlers[0].pbLowerStatStage(:SPECIAL_DEFENSE,2,battle.battlers[1]) if battle.battlers[0].pbCanLowerStatStage?(:SPECIAL_DEFENSE)
    when 5 #Raises Attack (Out of Spite)
        pbMessage(_INTL("\\xn[\\PN]Get out of my way."))
        pbMessage(_INTL("\\xn[Mafioso]No, I don't think I will."))
        battle.scene.disappearBar
        battle.battlers[1].pbRaiseStatStage(:ATTACK,1,battle.battlers[1]) if battle.battlers[1].pbCanRaiseStatStage?(:ATTACK)
    when 6 #Raises Defense (Out of Spite)
        pbMessage(_INTL("\\xn[\\PN]Uh, shoo?"))
        pbMessage(_INTL("\\xn[Mafioso]You don't scare me, Lafayette!"))
        battle.scene.disappearBar
        battle.battlers[1].pbRaiseStatStage(:DEFENSE,1,battle.battlers[1]) if battle.battlers[1].pbCanRaiseStatStage?(:DEFENSE)
    end
    battle.scene.pbHideOpponent
}

#Smuggling Tunnels
MafiosoSneeze=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Mafioso]*Achoo!*"))
    pbMessage(_INTL("\\xn[\\PN]Bless you."))
    pbMessage(_INTL("\\xn[Mafioso]Aw, thank you!"))
    pbMessage(_INTL("\\xn[\\PN]Been around Luciano, recently?"))
    pbMessage(_INTL("\\xn[Mafioso]No, I'm just allergic to mold."))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

#Suosirg
MafiosoThreat=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Mafioso]You're an idiot, Lafayette. You think your family can excuse this?"))
    pbMessage(_INTL("\\xn[\\PN]..."))
    pbMessage(_INTL("\\xn[Luciano]Guess the two of us aren't the best at following the rules!"))
    pbMessage(_INTL("\\xn[Mafioso]Rrr..."))
    pbMessage(_INTL("\\xn[\\PN]Luciano, please. Don't make him any angrier than he is."))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

#Thief
MafiosoThief=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    battle.pbAnimation(:THIEF,battle.battlers[1],battle.battlers[0])
    pbMessage(_INTL("\\xn[Gangster]Yoink!"))
    battle.scene.disappearBar
    battle.battlers[1].pbUseMoveSimple(:THIEF, battle.battlers[0]) #Ekat Note: Doesn't work
    battle.scene.pbHideOpponent
}

#Fling
MafiosoFling=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    battle.pbAnimation(:FLING,battle.battlers[1],battle.battlers[0])
    pbMessage(_INTL("\\xn[Mafioso]Bonk!"))
    battle.scene.disappearBar
    battle.battlers[1].pbUseMoveSimple(:FLING, battle.battlers[0]) #Ekat Note: Doesn't work
    battle.scene.pbHideOpponent
}

#===============================================================================
# Luciano as your partner on the Suosirg
#===============================================================================

LucianoPartner=Proc.new{|battle|
    battle.scene.appearBar
    random_line = rand(1..4)
    case random_line 
    when 1 #Toxic Spikes
        pbMessage(_INTL("\\xn[Luciano]Rose, now's not the time to play fair."))
        Pokemon.play_cry(:CACTURNE) 
        battle.scene.disappearBar
        battle.pbAnimation(:TOXICSPIKES,battle.battlers[0],battle.battlers[1])
        battle.battlers[0].pbOpposingSide.effects[PBEffects::ToxicSpikes] += 1
    when 2..3 #Sticky Barb - Small Damage
        pbMessage(_INTL("\\xn[Luciano]Rose, you know what times like these call for!"))
        Pokemon.play_cry(:CACTURNE) 
        pbWait(0.125)
        pbSEPlay("Battle throw")
        battle.scene.disappearBar
        battle.pbLowerHP(battle.battlers[1], 8) #Removes 1/8 of its total hp
        pbMessage(_INTL("Rose threw a Sticky Barb at the enemy!"))
        pbMessage(_INTL("\\xn[Luciano]No, not a Sticky Barb! Set up a buncha' Toxic Spikes or something!"))
        # Faint check
        battle.battlers[1].pbItemHPHealCheck
        battle.battlers[1].pbFaint if battle.battlers[1].fainted?
    when 4 #Sticky Barb - High Damage
        pbMessage(_INTL("\\xn[Luciano]Rose, you know what times like these call for!"))
        Pokemon.play_cry(:CACTURNE) 
        pbWait(0.125)
        pbSEPlay("Battle throw")
        battle.scene.disappearBar
        battle.pbLowerHP(battle.battlers[1], 4) #Removes 1/4 of its total hp
        pbMessage(_INTL("Rose threw a Sticky Barb at the enemy!"))
        pbMessage(_INTL("\\xn[Luciano]No, not a Sticky Barb! Set up a buncha' Toxic Spikes or something!"))
        # Faint check
        battle.battlers[1].pbItemHPHealCheck
        battle.battlers[1].pbFaint if battle.battlers[1].fainted?
    end
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

#===============================================================================
# Partner Eloise - Mt. Trebel AFTER MERCURY IS HEALED
#===============================================================================

EloisePartner=Proc.new{|battle|
    battle.scene.appearBar
    random_line = rand(1..4)
    case random_line 
    when 1 #Spikes
        pbMessage(_INTL("\\xn[Eloise]An unfair advantage is one the other side has!"))
        battle.scene.disappearBar
        Pokemon.play_cry(:SKARMORY) 
        battle.pbAnimation(:SPIKES,battle.battlers[0], battle.battlers[1])
        battle.battlers[0].pbOpposingSide.effects[PBEffects::Spikes] += 1
    when 2..3 #Attack - Small Damage
        pbMessage(_INTL("\\xn[Eloise]Let's cut them down to size, Mercury!"))
        Pokemon.play_cry(:SKARMORY) 
        pbWait(0.125)
        battle.scene.disappearBar
        battle.pbAnimation(:AIRSLASH,battle.battlers[0], battle.battlers[1])
        battle.pbLowerHP(battle.battlers[1], 8) #Removes 1/8 of its total hp
        # Faint check
        battle.battlers[1].pbItemHPHealCheck
        battle.battlers[1].pbFaint if battle.battlers[1].fainted?
    when 4 #Attack - High Damage
        pbMessage(_INTL("\\xn[Eloise]Let's cut them down to size, Mercury!"))
        Pokemon.play_cry(:SKARMORY) 
        pbWait(0.125)
        battle.scene.disappearBar
        battle.pbAnimation(:STEELWING,battle.battlers[0], battle.battlers[1])
        battle.pbLowerHP(battle.battlers[1], 4) #Removes 1/4 of its total hp
        # Faint check
        battle.battlers[1].pbItemHPHealCheck
        battle.battlers[1].pbFaint if battle.battlers[1].fainted?
    end
    battle.scene.pbHideOpponent
}

#===============================================================================
# Hart Battles
#===============================================================================

#Insulting Magikarp - Frozen Meadows Real Estate
Hart1=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[\\PN]Really, a Magikarp?"))
    pbMessage(_INTL("\\xn[Hart]Hey! Don't talk bad about Magikarp!"))
    battle.scene.disappearBar
    battle.battlers[1].pbRaiseStatStage(:ATTACK,6,battle.battlers[1]) if battle.battlers[1].pbCanRaiseStatStage?(:ATTACK)
    battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,6,battle.battlers[1]) if battle.battlers[1].pbCanRaiseStatStage?(:SPECIAL_ATTACK)
    battle.battlers[1].pbRaiseStatStage(:DEFENSE,6,battle.battlers[1]) if battle.battlers[1].pbCanRaiseStatStage?(:DEFENSE)
    battle.battlers[1].pbRaiseStatStage(:SPECIAL_DEFENSE,6,battle.battlers[1]) if battle.battlers[1].pbCanRaiseStatStage?(:SPECIAL_DEFENSE)
    battle.battlers[1].pbRaiseStatStage(:SPEED,6,battle.battlers[1]) if battle.battlers[1].pbCanRaiseStatStage?(:SPEED)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[\\PN](Were this any other Pokémon, I'd be worried about now.)"))
    pbMessage(_INTL("\\xn[Hart]Now get ready for Magikarp's SIGNATURE move."))
    pbMessage(_INTL("\\xn[\\PN]...Splash?"))
    pbMessage(_INTL("\\xn[Hart]Investigative Splash!"))
    battle.scene.disappearBar
    battle.pbAnimation(:SPLASH, battle.battlers[1], battle.battlers[0])
    pbMessage(_INTL("\\xn[\\PN]*sigh*"))
    battle.scene.pbHideOpponent
}

#Impatient Sylvester - Mt. Trebel Base
Hart2=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[\\PN]I don't have time for this."))
    pbMessage(_INTL("\\xn[\\PN]{1}, let's speed things up.", battle.battlers[0].name))    
    battle.scene.disappearBar    
    battle.battlers[0].pbRaiseStatStage(:SPEED, 6, battle.battlers[0]) if battle.battlers[0].pbCanRaiseStatStage?(:SPEED)
    battle.scene.pbHideOpponent
}


#Investigative Splash - Just separated on its own for convenience 
Hart3=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Hart]Get ready for Magikarp's SIGNATURE move."))
    pbMessage(_INTL("\\xn[\\PN]...Splash?"))
    pbMessage(_INTL("\\xn[Hart]Investigative Splash!"))
    battle.scene.disappearBar
    battle.pbAnimation(:SPLASH,battle.battlers[1],battle.battlers[0])
    pbMessage(_INTL("\\xn[\\PN]*sigh*"))
    battle.scene.pbHideOpponent
}

#===============================================================================
# Northallow Lucile Fight
#===============================================================================

#After the first round
Lucile1=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Lucile]*sigh*"))
    pbMessage(_INTL("\\xn[Lucile]When will you learn your place?"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

#After the second round
Lucile2=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Lucile]Keep trying to set yourself apart as the hero. You'll still be worth nothing to your family."))
    pbMessage(_INTL("\\xn[\\PN]I stand up for justice. Not to make a name for myself."))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

#Last Pokémon 
Lucile3=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Lucile]You toss a few coins to that street rat to make yourself seem kind."))
    pbMessage(_INTL("\\xn[Lucile]You helped Luciano make yourself feel wanted."))
    pbMessage(_INTL("\\xn[\\PN]That's not- You were, you were POISONING him."))
    pbMessage(_INTL("\\xn[Lucile]...He had it coming."))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

#Small damage
Lucile4=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Lucile]Tsk, tsk. Is that the best you can do?"))
    pbMessage(_INTL("\\xn[Lucile]I guess this isn't surprising. Quality over quantity with you Lafayettes and all."))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

#Syl's Pokémon faints
Lucile5=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("\\xn[Lucile]Pathetic."))
    pbMessage(_INTL("\\xn[Lucile]Strategies like this is why you're replaceable."))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

#===============================================================================
# Partner Ramira -  Case Twenty
#===============================================================================

RamiraBook=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbSEPlay("Battle throw")
    pbMessage(_INTL("Lotad throws a sixth edition copy of the Riverview Criminal Code!"))
    pbSEPlay("Battle damage normal")
    battle.scene.disappearBar
    battle.pbLowerHP(battle.battlers[0], 4) #Removes 1/4 of its total hp
    pbMessage(_INTL("\\xn[Ramira]Teehee! Who would've thought that clunky old thing would come in handy?"))
    battle.scene.pbHideOpponent
    # Faint check
    battle.battlers[0].pbItemHPHealCheck
    battle.battlers[0].pbFaint if battle.battlers[0].fainted?
}


#===============================================================================
# Dem's Mushroom insanity
#===============================================================================
DemShroom1=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("Here's a little lesson in trickery!"))
    battle.pbAnimation(:TRICKROOM,battle.battlers[1],battle.battlers[0])
    battle.field.effects[PBEffects::TrickRoom] = 999
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}

DemShroom2=Proc.new{|battle|
    battle.scene.pbShowOpponent(0)
    battle.scene.appearBar
    pbMessage(_INTL("Oh no! My devious plan has been foiled!"))
    battle.scene.disappearBar
    battle.scene.pbHideOpponent
}



# DONT DELETE THIS END
end
