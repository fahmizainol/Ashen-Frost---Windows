#==============================================================================#
#                            Detective Case System                             #
#                                   by Marin                                   #
#                                                                              #
#                           Made for Pokémon Present                           #
#                              (Essentials v17.2)                              #
#==============================================================================#
#                                 Introduction                                 #
#                                                                              #
#    Implements a detective case system. Each case has related evidence that   #
#    can be obtained throughout the world in the form of a testimony or clue.  #
#  A barebones UI has been included to display all cases and related evidence. #
#                                                                              #
#           - By default, the player is on Case 1.                             #
#           - Evidence are fictional items (not actual bag items)              #
#           - Evidence can be part of multiple cases.                          #
#==============================================================================#
#                             Evidence Definition                              #
#                                                                              #
#       Evidence for cases is defined in its own PBS file: evidence.txt.       #
#         This evidence has a very simple format, which is as follows:         #
#                                                                              #
#  [INTERNALNAME]                                                              #
#  Name = Display Name                                                         #
#  Case = Num1, Num2, Num3                                                     #
#  Use = Short usage text                                                      #
#  Description = A longer description that says what the evidence is for.      #
#  (Testimony = true)                                                          #
#                                                                              #
#  - The internal name is how you'll refer to the evidence (with a colon       #
#    in front of it). For example, if you create a piece of evidence called    #
#    TREASUREMAP, then to add it you'd write Evidence.give(:TREASUREMAP).      #
#  - The case number has to be one or more positive numbers. This means that   #
#    this piece of evidence will show up in the evidence list for those cases. #
#  - The use text is a short piece of text that is displayed when the evidence #
#    is selected in the case UI.                                               #
#  - The description is a longer description of what this evidence is exactly. #
#  - The Testimony field is a boolean (true/false, yes/no, etc) field which    #
#    specifies whether this is testimony-type evidence or not.                 #
#    This field can be left out of the PBS, and will default to false in those #
#    instances.                                                                #
#    The testimony property influences which icon is shown in the case UI.     #
#==============================================================================#
#                                    Usage                                     #
#                                                                              #
#  Cases:                                                                      #
#  - Case.start(id) -> Starts a new case (does not do anything other than      #
#                      start the case UI on the page of the new case.          #
#  - Case.all_evidence? -> Returns true if all evidence has been collected for #
#                          the current case, or false if not.                  #
#        aliases: Case.complete?                                               #
#  - Case.clear -> Deletes all evidence related to the current case.           #
#                  Probably won't want or need to do this.                     #
#                                                                              #
#                                                                              #
#  Evidence:                                                                   #
#  - Evidence.obtained?(name) -> Returns true if the player already has the    #
#                                evidence. Use this to avoid duplication.      #
#        aliases: Evidence.has?, Evidence.have?                                #
#  - Evidence.give(name) -> Gives the evidence with the given internal name.   #
#                           Throws an error if the player already has the      #
#                           evidence.                                          #
#                           Also displays the give-message.                    #
#  - Evidence.try_give(name) -> Gives the evidence with the given internal     #
#                               name. Essentially a shortcut for               #
#                               Evidence.give(name) if !Evidence.has?(name)    #
#                               Also displays the give-message.                #
#  - Evidence.remove(name) -> Takes away the specified evidence.               #
#                             Throws an error if the player doesn't have the   #
#                             evidence.                                        #
#        aliases: Evidence.delete                                              #
#  - Evidence.try_remove(name) -> Takes away the specified evidence.           #
#                                 Essentially a shortcut for                   #
#                                 Evidence.remove(name) if Evidence.has?(name) #
#        aliases: Evidence.try_delete                                          #
#  - Evidence.pick(var) -> Lets the user pick a piece of evidence to present,  #
#                          and stores the internal name of the chosen evidence #
#                          in the specified variable (or nil if not chosen)    #
#        aliases: Evidence.choose                                              #
#  - Evidence.has_chosen?(name) -> Lets the user pick a piece of evidence to   #
#                                  present, and immediately compares it to the #
#                                  specified evidence.                         #
#        aliases: Evidence.chosen?, Evidence.picked?, Evidence.has_picked?     #
#                                                                              #
#                                                                              #
#  For during development (but also available when not in debug:               #
#  - Evidence.give_all(case) -> Gives all evidence related to the currently    #
#                               active case that the player does not yet have. #
#  - Evidence.reset -> Deletes all evidence for all cases.                     #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#

class PokemonGlobalMetadata
  attr_accessor :case_num
  attr_accessor :evidence
  attr_accessor :side_case
      
  def case_num
    @case_num ||= 1
    return @case_num
  end
      
  def evidence
    @evidence ||= []
    return @evidence
  end
  
  def side_case
    @side_case ||= []
    return @side_case
  end
end
    
module Case
  class << self
    # Starts a new case.
    def start(num)
      if num > 25
        $PokemonGlobal.side_case << num
        $PokemonGlobal.side_case.sort!
      else  
        if num == $PokemonGlobal.case_num 
          raise "This case is already active."
        end
        $PokemonGlobal.case_num = num
      end
    end
    
    # Returns whether all evidence for the current case has been found.
    def all_evidence?
      Evidence.compiledData.each do |name, data|
        if data[:Case].include?($PokemonGlobal.case_num) && !Evidence.obtained?(name)
          return false
        end
      end
      return true
    end
    alias complete? all_evidence?
    
    # Deletes all evidence related to currently active case.
    # Just in case you for some reason need to.
    def clear
      i = 0
      while i <  $PokemonGlobal.evidence.size
        if Evidence.compiledData[$PokemonGlobal.evidence[i][0]]["Case"].include?($PokemonGlobal.case_num)
          $PokemonGlobal.evidence.delete_at(i)
          next
        end
        i += 1
      end
    end
  end
end
    
module Evidence
  class << self
    # Gives a piece of evidence to the player. Throws an error if invalid.
    def try_give(name, message=true)
      self.ensureCompiledData()
      if @@compiledData[name].nil?
        raise "No evidence with an internal name of #{name.inspect} could be found."
      end
      if !Evidence.has?(name)
         $PokemonGlobal.evidence << [name, $game_map.name]
        data = @@compiledData[name]
        if message
          if !data[:Testimony] # Clue
            pbMessage(_INTL("\\me[sfx-realization]You uncovered the \\c[1]{1}\\c[0]!\\wtnp[30]", data[:Name]))
          else
            pbMessage(_INTL("\\me[sfx-realization]You uncovered \\c[1]{1}\\c[0]!\\wtnp[30]", data[:Name]))
          end
        end
      end
    end
    
    # Gives a piece of evidence to the player. Throws an error if invalid or
    # already obtained.
    def give(name)
      if Evidence.has?(name)
        raise "The player already has this piece of evidence."
      else
        Evidence.try_give(name)
      end
    end
    
    # Returns whether or not the player has the given piece of evidence
    def obtained?(name)
      self.ensureCompiledData()
      if @@compiledData[name].nil?
        raise "No evidence with an internal name of #{name.inspect} could be found."
      end
      return  $PokemonGlobal.evidence.any? { |ev, map| ev == name }
    end
    alias has? obtained?
    alias have? obtained?
    
    # Removes a piece of evidence from the player. Throws an error if invalid.
    def try_remove(*names)
      self.ensureCompiledData()
      for n in names
        if @@compiledData[n].nil?
          raise "No evidence with an internal name of #{n.inspect} could be found."
        end
        if Evidence.has?(n)
           $PokemonGlobal.evidence.each_with_index do |e, i|
             $PokemonGlobal.evidence.delete_at(i) if e[0] == n
          end
        end
      end
    end
    alias try_delete try_remove
    
    # Removes a piece of evidence from the player.
    def remove(*names)
      for n in names
        if Evidence.has?(n)
          Evidence.try_remove(n)
        else
          raise "The player does not have this piece of evidence and thus it cannot be removed."
        end
      end
    end
    alias delete remove
    
    # Makes the user pick a piece of evidence (to present, or else).
    # Stores the internal name of the evidence in the given variable (or nil).
    # Also returns the internal name (or nil).
    def pick(variable = nil, case_num = $PokemonGlobal.case_num)
      ui = CaseUI.new(true, case_num)
      $game_variables[variable] = ui.value if variable
      return ui.value
    end
    alias choose pick
    
    # Makes the user pick a piece of evidence, and returns true if it's the same
    # piece of evidence as is provided.
    def has_picked?(name, case_num = $PokemonGlobal.case_num)
      return Evidence.pick(nil, case_num) == name
    end
    alias picked? has_picked?
    alias chosen? has_picked?
    alias has_chosen? has_picked?
    
     # Gives all evidence of a given case. Probably only to be used in debug.
    def give_all(case_num)
      self.ensureCompiledData()
      @@compiledData.each do |key, value|
        Evidence.give(key) if value[:Case].include?(case_num) && !Evidence.has?(key)
      end
    end
    
    # Deletes all evidence.
    def reset
       $PokemonGlobal.evidence.clear
    end
  end
end
    