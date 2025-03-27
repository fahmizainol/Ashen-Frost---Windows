class MoveData
  attr_reader :move
  attr_reader :name
  attr_reader :function
  attr_reader :type
  attr_reader :category
  attr_reader :basedamage
  attr_reader :accuracy
  attr_reader :maxpp
  attr_reader :target
  attr_reader :desc
  attr_reader :priority

  def initialize(movesym,data)
    @flags = {}
    @move            = movesym
    data.each do |key, value|
      case key
      when :name then           @name            = value
      when :function then       @function        = value
      when :type then           @type            = value
      when :category then       @category        = value
      when :basedamage then     @basedamage      = value
      when :accuracy then       @accuracy        = value
      when :maxpp then          @maxpp           = value
      when :target then         @target          = value
      when :desc then           @desc            = value
      when :priority then       @priority        = value ? value : 0
      else @flags[key] = value
      end
    end
  end

  def checkFlag?(fuck,me)
    return ""
  end
end