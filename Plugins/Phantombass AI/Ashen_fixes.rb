class Battle::Battler
  def pbMoveTypePoweringUpGem(gem_type, move, move_type, mults)
    return if @index == nil
    return if @battle.choices[@index][0] != :UseMove
    chosen_move = @moves[@battle.choices[@index][1]]
    return if chosen_move.statusMove?
    return if move.is_a?(Battle::Move::PledgeMove)   # Pledge moves never consume Gems
    return if self.is_a?(PBAI::AI_Learn)
    return if chosen_move.id != move.id
    return if chosen_move.type != gem_type
    return if move_type != gem_type
    return if $test_trigger == true
    @effects[PBEffects::GemConsumed] = @item_id if $test_trigger == false
    if Settings::MECHANICS_GENERATION >= 6
      mults[:base_damage_multiplier] *= 1.3
    else
      mults[:base_damage_multiplier] *= 1.5
    end
  end
end

class Battle
  attr_accessor :doublebattle

  alias initialize_ori initialize
  def initialize(scene, p1, p2, player, opponent)
    initialize_ori(scene, p1, p2, player, opponent)
    @doublebattle = false
  end

  def pbGetOpposingIndicesInOrder(idxBattler)
    case pbSideSize(0)
    when 1
      case pbSideSize(1)
      when 1   # 1v1 single
        return [0] if opposes?(idxBattler)
        return [1]
      when 2   # 1v2
        return [0] if opposes?(idxBattler)
        return [3, 1]
      when 3   # 1v3
        return [0] if opposes?(idxBattler)
        return [3, 5, 1]
      end
    when 2
      case pbSideSize(1)
      when 1   # 2v1
        return [0, 2] if opposes?(idxBattler)
        return [1]
      when 2   # 2v2 double
        return [[3, 1], [2, 0], [1, 3], [0, 2]][idxBattler]
        @doublebattle = true
      when 3   # 2v3
        return [[5, 3, 1], [2, 0], [3, 1, 5]][idxBattler] if idxBattler < 3
        return [0, 2]
      end
    when 3
      case pbSideSize(1)
      when 1   # 3v1
        return [2, 0, 4] if opposes?(idxBattler)
        return [1]
      when 2   # 3v2
        return [[3, 1], [2, 4, 0], [3, 1], [2, 0, 4], [1, 3]][idxBattler]
      when 3   # 3v3 triple
        return [[5, 3, 1], [4, 2, 0], [3, 5, 1], [2, 0, 4], [1, 3, 5], [0, 2, 4]][idxBattler]
      end
    end
    return [idxBattler]
  end
end    