class Pokemon

  def compatible_with_move?(move_id)
    move_data = GameData::Move.try_get(move_id)
    babyspecies = species_data.get_baby_species
    babyeggmoves =  GameData::Species.get(babyspecies).egg_moves
    prevo = species_data.get_previous_species
    prevomoves =  GameData::Species.get(prevo).moves
    x = move_data && species_data.tutor_moves.include?(move_data.id)
    y = move_data && species_data.tutor_moves.include?(move_data.id)
    z = move_data && species_data.tutor_moves.include?(move_data.id)
    m = BetterMoveTutorConfig::MOVE_MASTER_SWITCH
      if BetterMoveTutorConfig::LEVEL_MOVE_EXPERT
      x = move_data && species_data.moves.any? { |move| move.include?(move_id) } 
      end
      if BetterMoveTutorConfig::EGGMOVE_CONNOISSEUR
      y = move_data && species_data.egg_moves.include?(move_data.id) || move_data && babyeggmoves.include?(move_data.id)
      end
      if BetterMoveTutorConfig::SECOND_OPPORTUNITY
      z = move_data && prevomoves.any?{ |move| move.include?(move_id) } 
      end
    #return move_data && species_data.tutor_moves.include?(move_data.id) || move_data && species_data.moves.any? { |move| move.include?(move_id) } || move_data && species_data.egg_moves.include?(move_data.id) || move_data && babyeggmoves.include?(move_data.id) || move_data && prevomoves.any?{ |move| move.include?(move_id) }
    if BetterMoveTutorConfig::MOVE_MASTER && $game_switches[m]
      return true
    elsif $game_switches[83] && move_data.id == :DIG # Play as Mordecai
      return true
    else
      return move_data && species_data.tutor_moves.include?(move_data.id) || x || y  || z
    end
  end
end
