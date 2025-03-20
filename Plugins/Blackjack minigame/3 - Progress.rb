module BlackJack
  class Play

    # Play and check condition when play again
    def play
      loop do
        # Update
        self.update_ingame
        # Play
        self.progress
        break if @finish
      end
    end

    # Set card, play and wait
    def progress
      # Create scene
      self.create_scene
      # Set player, dealer, bet
      self.setPlayer
      # Bet coin before play
      self.bet
      # Distribute
      self.distribute
      # Players distribute cards
      self.playerPlay
      # Check information
      self.play_again
    end

    # Player, AI and dealer distribute cards
    def playerPlay
      loop do
        # Update
        self.update_ingame
        # Action (AI)
        self.action
        # Player bet
        self.playerBet
        break if @finished_round
      end
    end

  end
end