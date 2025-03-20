# Blackjack game
# Credit: bo4p5687

module BlackJack

  # Class
  class Play

    def initialize
      @sprites = {}
      # Viewport
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      # Value
      # Store: A-Hearts, A-Diamonds, A-Clubs, A-Spade, etc
      # Order: 0, 1, 2, 3, etc
      @card = []
      52.times { |i| @card << i }
      # Store card player (position and dealer)
      @player = {}
      # Set for quitting game
      @finish = false
      # Set for already played
      @already_played = false
      # Set for finishing round
      @finished_round = false
      # Check card if it opened
      @opened = []
      @opened << false 
      # Set progress
      @action = false # Bet
      # (Progress) player play
      @playertime  = false # Player can choose action in this progress
      @createdchoice = false # Progress for creating choice for player
      @choice = {} # Store information of rectangle 'Choice'
      # (Progress) turn of player
      @turn = "player"
    end
  end
  # Def
  def self.play
    if GameData::Item.exists?(:COINCASE) && !$bag.has?(:COINCASE)
      pbMessage(_INTL("\\xn[Attendant]\\bYou don't have a coin case!"))
      return
    elsif $player.coins <= 0
      pbMessage(_INTL("\\xn[Attendant]\\bYou don't have any Coins to play!"))
      return
    end
    loop do
      pbFadeOutIn {
        p = Play.new
        p.play
        p.endScene
      }
      break
    end
  end
end