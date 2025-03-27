class Battle
    alias old_initialize initialize
    def initialize(scene, p1, p2, player, opponent)
        old_initialize(scene, p1, p2, player, opponent)
        @battleAI = GoatAI.new(self)
    end

    def pbCommandPhaseLoop(isPlayer)
		# NOTE: Doing some things (e.g. running, throwing a Poké Ball) takes up all
		#       your actions in a round.
		actioned = []
		idxBattler = -1
		# DemICE store all damages in a hash for better efficiency.
		# @battleAI.registerDamagesAI if isPlayer
		loop do
			break if @decision != 0   # Battle ended, stop choosing actions
			idxBattler += 1
			break if idxBattler >= @battlers.length
			next if !@battlers[idxBattler] || pbOwnedByPlayer?(idxBattler) != isPlayer
			next if @choices[idxBattler][0] != :None    # Action is forced, can't choose one
			next if !pbCanShowCommands?(idxBattler)   # Action is forced, can't choose one
			if !@controlPlayer && pbOwnedByPlayer?(idxBattler)
				# Player chooses an action
				actioned.push(idxBattler)
				commandsEnd = false   # Whether to cancel choosing all other actions this round
				loop do
					cmd = pbCommandMenu(idxBattler, actioned.length == 1)
					# If being Sky Dropped, can't do anything except use a move
					if cmd > 0 && @battlers[idxBattler].effects[PBEffects::SkyDrop] >= 0
						pbDisplay(_INTL("Sky Drop won't let {1} go!", @battlers[idxBattler].pbThis(true)))
						next
					end
					case cmd
					when 0    # Fight
						break if pbFightMenu(idxBattler)
					when 1    # Bag
						if pbItemMenu(idxBattler, actioned.length == 1)
							commandsEnd = true if pbItemUsesAllActions?(@choices[idxBattler][1])
							break
						end
					when 2    # Pokémon
						break if pbPartyMenu(idxBattler)
					when 3    # Run
						# NOTE: "Run" is only an available option for the first battler the
						#       player chooses an action for in a round. Attempting to run
						#       from battle prevents you from choosing any other actions in
						#       that round.
						if pbRunMenu(idxBattler)
							commandsEnd = true
							break
						end
					when 4    # Call
						break if pbCallMenu(idxBattler)
					when -2   # Debug
						pbDebugMenu
						next
					when -1   # Go back to previous battler's action choice
						next if actioned.length <= 1
						actioned.pop   # Forget this battler was done
						idxBattler = actioned.last - 1
						pbCancelChoice(idxBattler + 1)   # Clear the previous battler's choice
						actioned.pop   # Forget the previous battler was done
						break
					end
					pbCancelChoice(idxBattler)
				end
			else 
				# DemICE moved the AI decision after player decision.
				# AI controls this battler
                print(@battlers[0].pokemon)
				@battleAI.pbDefaultChooseEnemyCommand(idxBattler)
			end 
			break if commandsEnd
		end
	end
end

# class Battle::Battler
#     def inspect
#         attributes = instance_variables.map do |var|
#           value = instance_variable_get(var)
#           "#{var}=#{value.inspect}"
#         end
        
#         "#<#{self.class}:#{object_id} #{attributes.join(', ')}>"
#       end
# end

class Battle::Move
  
    alias ai_pbReduceDamage pbReduceDamage
    def pbReduceDamage(user, target)
      ai_pbReduceDamage(user, target)
      hp_lost = target.damageState.hpLost
      total_hp_lost = target.damageState.totalHPLost
      return total_hp_lost
    end
end

class GoatAI
    def pbDefaultChooseEnemyCommand(idxBattler)
    
        #return if pbEnemyShouldUseItem?(idxBattler)
      #   return if pbEnemyShouldWithdraw?(idxBattler)
      #   return if @battle.pbAutoFightMenu(idxBattler)
      pbProcessAITurn
        @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?(idxBattler)
        if PluginManager.installed?("ZUD Mechanics")
          @battle.pbRegisterUltraBurst(idxBattler) if pbEnemyShouldUltraBurst?(idxBattler)
          @battle.pbRegisterDynamax(idxBattler) if pbEnemyShouldDynamax?(idxBattler)
        end
        if PluginManager.installed?("Terastal Phenomenon")
          @battle.pbRegisterTerastallize(idxBattler) if pbEnemyShouldTerastallize?(idxBattler)
        end
        if PluginManager.installed?("Pokémon Birthsigns")
          @battle.pbRegisterZodiacPower(idxBattler) if pbEnemyShouldZodiacPower?(idxBattler)
        end
        if PluginManager.installed?("Focus Meter System")
          @battle.pbRegisterFocus(idxBattler) if pbEnemyShouldFocus?(idxBattler)
        end
        if PluginManager.installed?("Essentials Deluxe")
          if !@battle.pbScriptedMechanic?(idxBattler, :custom) && pbEnemyShouldCustom?(idxBattler)
            @battle.pbRegisterCustom(idxBattler)
          end
        end  
        @battle.pbChooseMoves(idxBattler)
        if PluginManager.installed?("PLA Battle Styles") # Purposefully set after move selection.
          @battle.pbRegisterStyle(idxBattler) if pbEnemyShouldUseStyle?(idxBattler)
        end
    end
end
