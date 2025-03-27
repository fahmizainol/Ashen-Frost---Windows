class PBMove
  attr_reader(:move)     # Gets the symbol of the move
  attr_accessor(:pp)     # Gets the number of PP remaining for this move.
  attr_accessor(:ppup)   # Gets the number of PP Ups used for this move.

  def initialize(move=nil)
    @move=move
    @id         = move.id
    @name       = move.name   # Get the move's name
    # Get data on the move
    @function   = move.function_code
    @baseDamage = move.base_damage
    @type       = move.type
    @category   = move.category
    @accuracy   = move.accuracy
    @pp         = move.pp   # Can be changed with Mimic/Transform
    @addlEffect = move.effect_chance
    @target     = move.target
    @priority   = move.priority
    @flags      = move.flags.clone
  end

  # def totalpp
  #   return (maxpp * (1 + 0.2 * @ppup)).floor
  # end
  
  # #yanking these from PB_Move. might be unnecessary!
  # def function
  #   return $cache.moves[@move].function
  # end

  # def type
  #   return $cache.moves[@move].type
  # end

  # def category
  #   return $cache.moves[@move].category
  # end

  # def basedamage
  #   return $cache.moves[@move].basedamage
  # end

  # def accuracy
  #   return $cache.moves[@move].accuracy
  # end

  # def maxpp
  #   return $cache.moves[@move].maxpp
  # end

  # def target
  #   return $cache.moves[@move].target
  # end

  # def desc
  #   return $cache.moves[@move].desc
  # end
end