class Cache_Game
    attr_reader :pkmn
    attr_reader :moves
    attr_reader :move2anim
    attr_reader :items
    attr_reader :trainers
    attr_reader :trainertypes
    attr_reader :FEData
    attr_reader :FENotes
    attr_reader :types
    attr_reader :abil
    attr_reader :mapinfos
    attr_reader :mapdata
    attr_reader :regions
    attr_reader :encounters
    attr_reader :metadata
    attr_reader :bosses
    attr_reader :map_conns
    attr_reader :town_map
    attr_reader :animations
    attr_reader :RXsystem
    attr_reader :RXevents
    attr_reader :RXtilesets
    attr_reader :RXanimations
    attr_reader :cachedmaps
    attr_reader :natures
    attr_reader :shadows



    def cacheMoves
        return if !File.exists?("Data/moves.dat")
        @moves          = load_data("Data/moves.dat") if !@moves
        @move2anim          = load_data("Data/move2anim.dat") if !@move2anim
    end

    
    def initialize
        cacheMoves
    end


end
$cache = Cache_Game.new if !$cache