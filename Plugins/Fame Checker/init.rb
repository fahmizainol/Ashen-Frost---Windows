=begin
module Compiler
  class << Compiler
    alias compile_all_fame_checker compile_all_case_system
  end

  def self.compile_all(mustCompile)
    compile_all_fame_checker(mustCompile) { |msg| pbSetWindowText(msg); echoln(msg) }
    FameChecker.compile()
  end
end
=end

# add the FamousPeople element to the save data
class PokemonGlobalMetadata
  attr_accessor :FamousPeople
  attr_accessor :FameTargets
  attr_accessor :FameInfo

  alias fame_checker_ini initialize
  def initialize
    fame_checker_ini
    @FamousPeople = {}
  end
end

# create the use item element so that the item properly can be used if wanted
ItemHandlers::UseFromBag.add(:FAMECHECKER, proc { |item|
  next FameChecker.startFameChecker ? 1 : 0
})

# create the use item element so that the item can be used from the favorite menu
ItemHandlers::UseInField.add(:FAMECHECKER, proc{ |item|
  next FameChecker.startFameChecker ? 1 : 0
})

# create debug menu item
MenuHandlers.add(:debug_menu, :modifyFameData, {
  "name"        => _INTL("Edit Fame Data"),
  "parent"      => :editors_menu,
  "description" => _INTL("Add or remove Famous People and their Info."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { fameTargetEditor() }
  }
})

module FameChecker
  @@vp = nil
  @@sprites = {}
  @@compiledData = nil
  @@reloaded = false

  def self.cleanup()
    @@vp.dispose
    @@vp = nil
    pbDisposeSpriteHash(@@sprites)
  end

  def self.modifySaveHash()
    @@compiledData.each { |key, val|
      if not $PokemonGlobal.FamousPeople[key]
        $PokemonGlobal.FamousPeople[key] = {}
        hash = $PokemonGlobal.FamousPeople[key]
        hash[:HasBeenSeen] = val[:HasBeenSeen]
        hash[:Complete] = val[:Complete].dup
        hash[:FameLookup] = val[:FameLookup]
      end
      hash = $PokemonGlobal.FamousPeople[key]
      hash[:HasBeenSeen] = val[:HasBeenSeen] if val[:HasBeenSeen] == true
      hash[:FameLookup] = val[:FameLookup] if not hash[:FameLookup]

      next if not val[:FameInfo]
      if not hash[:FameInfo]
        hash[:FameInfo] = Array.new(val[:FameInfo].length){|i| val[:FameInfo][i][:HasBeenSeen]}
      else
        newFameInfo = Array.new(val[:FameInfo].length) {|i| val[:FameInfo][i][:HasBeenSeen]} # generate a new FameInfo for the current famous person
        hash[:Complete] = val[:Complete].dup # Set the default complete variable
        hash[:FameLookup].each { |k, value| # run through the entirety of the hash's original fame lookup to see if keys match
          next if not val[:FameLookup][k] # skip if there isn't a key within the compiled data, that element was deleted
          tf = hash[:FameInfo][value] # get the save data seen value
          if tf == true and newFameInfo[val[:FameLookup][k]] == false # if the save data value is true and the compiled data is false
            hash[:Complete][0] += 1 # increase the found value by 1
            newFameInfo[val[:FameLookup][k]] = true # and set the value to true
          end
        }
        hash[:FameInfo] = newFameInfo # update the fame info to the new fame info
        hash[:FameLookup] = val[:FameLookup] # and update the fame lookup for the next compile
      end
    }

    $PokemonGlobal.FamousPeople.each_key { |key|
      if not @@compiledData[key]
        $PokemonGlobal.FamousPeople.delete(key)
      end
    }
  end

  def self.completed?()
    $PokemonGlobal.FamousPeople.each { |key, hash|
      return false if hash[:HasBeenSeen] == false
      return false if hash[:Complete][0] != hash[:Complete][1]
    }
    return true
  end

  def self.ensureCompiledData(overwrite = false)
    return if @@reloaded == true and overwrite == false
    $PokemonGlobal.FamousPeople = {} if not $PokemonGlobal.FamousPeople
    @@compiledData = load_data("Data/fame_targets.dat") rescue {}
    self.modifySaveHash()
    self.convertOldSave()
    $game_switches[FAME_SWITCH] = self.completed?()
    @@reloaded = true
  end

  def self.compiledData()
    if @@compiledData == nil
      self.ensureCompiledData()
    end
    return @@compiledData
  end

  # I was planning on cutting this down as there is a lot of things in it that I personally
  # didn't think was needed, In the end I decided against it because the extra functionality
  # allows the game maker to make full use of the message display commands
  # That being said, I now understand how this function works
  def messageDisplay(msgwindow, message, letterbyletter=true, commandProc=nil, endOnUse = true, endOnBack = true)
    return if !msgwindow
    oldletterbyletter=msgwindow.letterbyletter
    msgwindow.letterbyletter=(letterbyletter) ? true : false
    ret=nil
    commands=nil
    facewindow=nil
    goldwindow=nil
    coinwindow=nil
    battlepointswindow=nil
    cmdvariable=0
    cmdIfCancel=0
    msgwindow.waitcount=0
    autoresume=false
    text=message.clone
    msgback=nil
    linecount=(Graphics.height>400) ? 3 : 2
    ### Text replacement
    text.gsub!(/\\sign\[([^\]]*)\]/i) {   # \sign[something] gets turned into
      next "\\op\\cl\\ts[]\\w["+$1+"]"    # \op\cl\ts[]\w[something]
    }
    text.gsub!(/\\\\/,"\5")
    text.gsub!(/\\1/,"\1")
    if $game_actors
      text.gsub!(/\\n\[([1-8])\]/i) {
        m = $1.to_i
        next $game_actors[m].name
      }
    end
    text.gsub!(/\\pn/i,$Trainer.name) if $Trainer
    text.gsub!(/\\pm/i,_INTL("${1}",$Trainer.money.to_s_formatted)) if $Trainer
    text.gsub!(/\\n/i,"\n")
    text.gsub!(/\\\[([0-9a-f]{8,8})\]/i) { "<c2="+$1+">" }
    text.gsub!(/\\pg/i,"\\b") if $Trainer && $Trainer.male?
    text.gsub!(/\\pg/i,"\\r") if $Trainer && $Trainer.female?
    text.gsub!(/\\pog/i,"\\r") if $Trainer && $Trainer.male?
    text.gsub!(/\\pog/i,"\\b") if $Trainer && $Trainer.female?
    text.gsub!(/\\pg/i,"")
    text.gsub!(/\\pog/i,"")
    text.gsub!(/\\b/i,"<c3=3050C8,D0D0C8>")
    text.gsub!(/\\r/i,"<c3=E00808,D0D0C8>")
    text.gsub!(/\\[Ww]\[([^\]]*)\]/) {
      w = $1.to_s
      if w==""
        msgwindow.windowskin = nil
      else
        msgwindow.setSkin("Graphics/Windowskins/#{w}",false)
      end
      next ""
    }
    isDarkSkin = isDarkWindowskin(msgwindow.windowskin)
    text.gsub!(/\\[Cc]\[([0-9]+)\]/) {
      m = $1.to_i
      next getSkinColor(msgwindow.windowskin,m,isDarkSkin)
    }
    loop do
      last_text = text.clone
      text.gsub!(/\\v\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
      break if text == last_text
    end
    loop do
      last_text = text.clone
      text.gsub!(/\\l\[([0-9]+)\]/i) {
        linecount = [1,$1.to_i].max
        next ""
      }
      break if text == last_text
    end
    colortag = ""
    if $game_system && $game_system.respond_to?("message_frame") &&
       $game_system.message_frame != 0
      colortag = getSkinColor(msgwindow.windowskin,0,true)
    else
      colortag = getSkinColor(msgwindow.windowskin,0,isDarkSkin)
    end
    text = colortag+text
    ### Controls
    textchunks=[]
    controls=[]
    while text[/(?:\\(f|ff|ts|cl|me|se|wt|wtnp|ch)\[([^\]]*)\]|\\(g|cn|pt|wd|wm|op|cl|wu|\.|\||\!|\^))/i]
      textchunks.push($~.pre_match)
      if $~[1]
        controls.push([$~[1].downcase,$~[2],-1])
      else
        controls.push([$~[3].downcase,"",-1])
      end
      text=$~.post_match
    end
    textchunks.push(text)
    for chunk in textchunks
      chunk.gsub!(/\005/,"\\")
    end
    textlen = 0
    for i in 0...controls.length
      control = controls[i][0]
      case control
      when "wt", "wtnp", ".", "|"
        textchunks[i] += "\2"
      when "!"
        textchunks[i] += "\1"
      end
      textlen += toUnformattedText(textchunks[i]).scan(/./m).length
      controls[i][2] = textlen
    end
    text = textchunks.join("")
    signWaitCount = 0
    signWaitTime = Graphics.frame_rate/2
    haveSpecialClose = false
    specialCloseSE = ""
    for i in 0...controls.length
      control = controls[i][0]
      param = controls[i][1]
      case control
      when "op"
        signWaitCount = signWaitTime+1
      when "cl"
        text = text.sub(/\001\z/,"")   # fix: '$' can match end of line as well
        haveSpecialClose = true
        specialCloseSE = param
      when "f"
        facewindow.dispose if facewindow
        facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
      when "ff"
        facewindow.dispose if facewindow
        facewindow = FaceWindowVX.new(param)
      when "ch"
        cmds = param.clone
        cmdvariable = pbCsvPosInt!(cmds)
        cmdIfCancel = pbCsvField!(cmds).to_i
        commands = []
        while cmds.length>0
          commands.push(pbCsvField!(cmds))
        end
      when "wtnp", "^"
        text = text.sub(/\001\z/,"")   # fix: '$' can match end of line as well
      when "se"
        if controls[i][2]==0
          startSE = param
          controls[i] = nil
        end
      end
    end
    ########## Position message window  ##############
    pbRepositionMessageWindow(msgwindow,linecount)
    if facewindow
      pbPositionNearMsgWindow(facewindow,msgwindow,:left)
      facewindow.viewport = msgwindow.viewport
      facewindow.z        = msgwindow.z
    end
    atTop = (msgwindow.y==0)
    ########## Show text #############################
    msgwindow.text = text
    Graphics.frame_reset if Graphics.frame_rate>40
    loop do
      if signWaitCount>0
        signWaitCount -= 1
        if atTop
          msgwindow.y = -msgwindow.height*signWaitCount/signWaitTime
        else
          msgwindow.y = Graphics.height-msgwindow.height*(signWaitTime-signWaitCount)/signWaitTime
        end
      end
      for i in 0...controls.length
        next if !controls[i]
        next if controls[i][2]>msgwindow.position || msgwindow.waitcount!=0
        control = controls[i][0]
        param = controls[i][1]
        case control
        when "f"
          facewindow.dispose if facewindow
          facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
          facewindow.viewport = msgwindow.viewport
          facewindow.z        = msgwindow.z
        when "ff"
          facewindow.dispose if facewindow
          facewindow = FaceWindowVX.new(param)
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
          facewindow.viewport = msgwindow.viewport
          facewindow.z        = msgwindow.z
        when "g"      # Display gold window
          goldwindow.dispose if goldwindow
          goldwindow = pbDisplayGoldWindow(msgwindow)
        when "cn"     # Display coins window
          coinwindow.dispose if coinwindow
          coinwindow = pbDisplayCoinsWindow(msgwindow,goldwindow)
        when "pt"     # Display battle points window
          battlepointswindow.dispose if battlepointswindow
          battlepointswindow = pbDisplayBattlePointsWindow(msgwindow)
        when "wu"
          msgwindow.y = 0
          atTop = true
          msgback.y = msgwindow.y if msgback
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
          msgwindow.y = -msgwindow.height*signWaitCount/signWaitTime
        when "wm"
          atTop = false
          msgwindow.y = (Graphics.height-msgwindow.height)/2
          msgback.y = msgwindow.y if msgback
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        when "wd"
          atTop = false
          msgwindow.y = Graphics.height-msgwindow.height
          msgback.y = msgwindow.y if msgback
          pbPositionNearMsgWindow(facewindow,msgwindow,:left)
          msgwindow.y = Graphics.height-msgwindow.height*(signWaitTime-signWaitCount)/signWaitTime
        when "ts"     # Change text speed
          msgwindow.textspeed = (param=="") ? -999 : param.to_i
        when "."      # Wait 0.25 seconds
          msgwindow.waitcount += Graphics.frame_rate/4
        when "|"      # Wait 1 second
          msgwindow.waitcount += Graphics.frame_rate
        when "wt"     # Wait X/20 seconds
          param = param.sub(/\A\s+/,"").sub(/\s+\z/,"")
          msgwindow.waitcount += param.to_i*Graphics.frame_rate/20
        when "wtnp"   # Wait X/20 seconds, no pause
          param = param.sub(/\A\s+/,"").sub(/\s+\z/,"")
          msgwindow.waitcount = param.to_i*Graphics.frame_rate/20
          autoresume = true
        when "^"      # Wait, no pause
          autoresume = true
        when "se"     # Play SE
          pbSEPlay(pbStringToAudioFile(param))
        when "me"     # Play ME
          pbMEPlay(pbStringToAudioFile(param))
        end
        controls[i] = nil
      end
      break if !letterbyletter
      Graphics.update
      Input.update
      facewindow.update if facewindow
      if autoresume && msgwindow.waitcount==0
        msgwindow.resume if msgwindow.busy?
        break if !msgwindow.busy?
      end
      if (Input.trigger?(Input::USE) && endOnUse) || (Input.trigger?(Input::BACK) && endOnBack)
        input = Input.trigger?(Input::BACK) ? Input::BACK : Input::USE
        if msgwindow.busy?
          pbPlayDecisionSE if msgwindow.pausing?
          msgwindow.resume
        else
          return input if signWaitCount==0
        end
      end
      pbUpdateSceneMap
      msgwindow.update
      yield if block_given?
      break if (!letterbyletter || commandProc || commands) && !msgwindow.busy?
    end
    Input.update   # Must call Input.update again to avoid extra triggers
    msgwindow.letterbyletter=oldletterbyletter
    if commands
      $game_variables[cmdvariable]=pbShowCommands(msgwindow,commands,cmdIfCancel)
      $game_map.need_refresh = true if $game_map
    end
    if commandProc
      ret=commandProc.call(msgwindow)
    end
    msgback.dispose if msgback
    goldwindow.dispose if goldwindow
    coinwindow.dispose if coinwindow
    battlepointswindow.dispose if battlepointswindow
    facewindow.dispose if facewindow
    if haveSpecialClose
      pbSEPlay(pbStringToAudioFile(specialCloseSE))
      atTop = (msgwindow.y==0)
      for i in 0..signWaitTime
        if atTop
          msgwindow.y = -msgwindow.height*i/signWaitTime
        else
          msgwindow.y = Graphics.height-msgwindow.height*(signWaitTime-i)/signWaitTime
        end
        Graphics.update
        Input.update
        pbUpdateSceneMap
        msgwindow.update
      end
    end
    return ret
  end

  def self.FAME_SWITCH()
    return FAME_SWITCH
  end
end



