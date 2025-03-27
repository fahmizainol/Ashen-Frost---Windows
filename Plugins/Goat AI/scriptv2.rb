class GoatAI
    attr_accessor :battle #:Battle

    attr_accessor :player_trainer
    attr_accessor :ai_trainer
    attr_accessor :battlers
    attr_accessor :player_battler
    attr_accessor :ai_battler

    attr_accessor :move_scores
    attr_accessor :switch_score
    attr_accessor :threat_score

    def initialize(battle)
        @battle = battle
        @player_trainer = @battle.player
        @ai_trainer = @battle.opponent
        @battlers = @battle.battlers
        @player_battler = @battle.battlers[0] # Just doing single now
        @ai_battler = @battle.battlers[1]

        @move_scores = [[-1, -1, -1, -1]] # [moveidx]
        @switch_score = 0
    end

    def pbProcessAITurn
        print "inspecting self"
        print(@battle.battlers.inspect)
        # @move_scores = pbGetMoveScore
        print @move_scores
    end

    def pbGetMoveScore
        # fake_player_mon = pbMakeFakeBattler(@battle.battlers[0].pokemon, false)
        move_scores = [[-1, -1, -1, -1]]
        print(@battle.battlers[1].inspect)
        # @battle.battlers[1].moves.each_with_index do |move, i|
        #     move_scores[0][i] = pbReduceDamage(@battle.battlers[1], @battle.battlers[0])
        #     print(move_scores)
        # end
        return move_scores
    end

    def pbMakeFakeBattler(pokemon,batonpass=false)
        return nil if pokemon.nil?
        pokemon = pokemon.clone
        battler = Battle::Battler.new(@battle,@index)
        return if battler.pokemon == pokemon
        battler.pbInitPokemon(pokemon,@index)
        battler.pbInitEffects(batonpass)
        return battler
      end
    end