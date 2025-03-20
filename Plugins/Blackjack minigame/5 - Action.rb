module BlackJack
  class Play
    
    # Double
    def double(name)
      num = @player[name][:bet]
      return false if name == :player && ($player.coins <= 0 || $player.coins - num < num || ![9, 10, 11].include?(@player[name][:sum]))
      @player[name][:bet] += num
      self.distributeCard(name)
      self.drawCard(name, @player[name][:card].size - 1)
      return true
    end

    # Insure
    def insure(name)
      return if (@player[:dealer][:card][0] / 4 != 0) || (name == :dealer)
      return if @player[name][:insurance][1]
      num = @player[name][:insurance][0] + @player[name][:bet]
      return if name == :player && ($player.coins <= 0 || $player.coins < num)
      @player[name][:insurance][1] = true
    end

    # AI
    def action
      # Dealer
      if @turn == "dealer"
        player = @player[:dealer]
        player[:status].size.times { |i|
          @player[:dealer][:status][i] = true
          self.drawCard(:dealer, i)
        }
        # Lost all
        if player[:sum] >= 22 && !(@player[:player][:lost] || @player[:player][:giveup])
          pbMessage(_INTL("\\CNThe dealer busted!"))
          # Gain coin
          $player.coins += @player[:player][:bet]
          pbMessage(_INTL("\\CN#{$player.name} gained #{@player[:player][:bet]} coins!"))
          @finished_round = true 
          return
        # Win Black jack (insurance)
        elsif player[:card].size == 2 && self.winBlackJack(player[:card],player[:sum])
          @player[:dealer][:blackjack] = true
          # Open cards of players
          @player.each { |k,v|
            next if k==:dealer || v[:name].nil?
            self.dealerOpen(k)
          }
        end
        # Normal
        if player[:sum] < 17 && !(@player[:player][:lost] || @player[:player][:giveup])
          self.distributeCard(:dealer, true)
          self.drawCard(:dealer, player[:card].size-1)
        else
          notopen = false if !notopen
          order = -1 if !order
          needopen = 0 if !needopen
          # Check cards
          @player.each { |k,v|
            next if k==:dealer
            order += 1
            if v[:name].nil? && !@opened[order]
              @opened[order] = true
              next
            end
            # Check if give up
            if v[:giveup] && !@opened[order]
              pbMessage(_INTL("\\CN#{$player.name} gave up!"))
              # Lose coins
              $player.coins -= (v[:bet] / 2).ceil
              pbMessage(_INTL("\\CNHe lost #{(v[:bet] / 2).ceil} coins!"))
              @opened[order] = true
              next
            # Next if player lost
            elsif v[:lost] && !@opened[order]
              pbMessage(_INTL("\\CN#{$player.name} busted!"))
              # Lose coins
              $player.coins -= v[:bet]
              pbMessage(_INTL("\\CNHe lost #{v[:bet]} coins!"))
              @opened[order] = true
              next
            end
            # Open card
            if !player[:blackjack]
              next if @opened[order]
              case player[:sum]
              when 17
                random = rand(1000)
                if (random < 500 && v[:card].size == 2) || (random < 600 && v[:card].size > 2 && v[:card].size < 5)
                  self.dealerOpen(k)
                  @opened[order] = true
                end
              when 18
                random = rand(1000)
                if random < 900
                  self.dealerOpen(k)
                  @opened[order] = true
                end
              else
                self.dealerOpen(k)
                @opened[order] = true
              end
              @opened[order] = true if v[:blackjack] 
              next if !@opened[order]
            end
            next if v[:name].nil?
            # Display Messages
            if v[:blackjack] 
              pbMessage(_INTL("#{$player.name} has blackjack."))
            elsif player[:blackjack]
              pbMessage(_INTL("The dealer has blackjack.")) 
            else
              pbMessage(_INTL("#{$player.name} has a sum of #{v[:sum]}.")) 
              pbMessage(_INTL("The dealer has a sum of #{player[:sum]}.")) 
            end
            # Compare values
            case self.compareValue(k)
            when "nil"
              p "Error: compare"
              Kernel.exit!
            # blackjack
            when "greater blackjack"
              # Display messages
              pbMessage(_INTL("\\CNWith his blackjack, the dealer won.")) 
              # Lose coins/break even
              if v[:insurance][1]
                pbMessage(_INTL("\\CN#{$player.name} broke even due to his insurance!"))
              else  
                $player.coins -= v[:bet]
                pbMessage(_INTL("\\CN#{$player.name} lost #{v[:bet]} coins!"))
              end
            when "less blackjack"
              # Display messages
              pbMessage(_INTL("\\CNWith his blackjack, #{$player.name} won.")) 
              # Gain coins
              $player.coins += (v[:bet] * 1.5).ceil
              pbMessage(_INTL("\\CN#{$player.name} gained #{(v[:bet] * 1.5).ceil} coins!"))
              # Insurance bet check
              if v[:insurance][1]
                pbMessage(_INTL("\\CNUnfortunately, #{$player.name} lost on his insurance bet!"))
                $player.coins -= v[:insurance][0]
                pbMessage(_INTL("\\CN#{$player.name} lost #{v[:insurance][0]} coins!"))
              end
            # Normal case
            when "greater"
              # Display messages
              pbMessage(_INTL("\\CNAs #{player[:sum]} is greater than #{v[:sum]}, the dealer won."))
              # Lose coins
              $player.coins -= v[:bet]
              pbMessage(_INTL("\\CN#{$player.name} lost #{v[:bet]} coins!"))
              # Insurance bet check
              if v[:insurance][1]
                pbMessage(_INTL("\\CN#{$player.name} also lost on his insurance bet!"))
                $player.coins -= v[:insurance][0]
                pbMessage(_INTL("\\CN#{$player.name} lost #{v[:insurance][0]} coins!"))
              end
            when "less"
              # Display messages
              pbMessage(_INTL("\\CNAs #{v[:sum]} is greater than #{player[:sum]}, #{$player.name} won."))
              # Gain coin
              $player.coins += v[:bet]
              pbMessage(_INTL("\\CN#{$player.name} gained #{v[:bet]} coins!"))
              # Insurance bet check
              if v[:insurance][1]
                pbMessage(_INTL("\\CNUnfortunately, #{$player.name} lost on his insurance bet!"))
                $player.coins -= v[:insurance][0]
                pbMessage(_INTL("\\CN#{$player.name} lost #{v[:insurance][0]} coins!"))
              end
            when "draw"
              pbMessage(_INTL("\\CNIt's a draw!"))
              # Insurance bet check
              if v[:insurance][1]
                pbMessage(_INTL("\\CNUnfortunately, #{$player.name} lost on his insurance bet!"))
                $player.coins -= v[:insurance][0]
                pbMessage(_INTL("\\CN#{$player.name} lost #{v[:insurance][0]} coins!"))
              end  
            end
            @opened[order] = true if player[:blackjack]
          }
          if !@opened.include?(false)
            @finished_round = true # Finish round
            return
          end
          # Continue distribute
          random = rand(1000)
          return unless (random < 500 && player[:sum] < 17) || (random < 50 && player[:sum] == 17)
          self.distributeCard(:dealer, true)
          self.drawCard(:dealer, player[:card].size-1)
        end
        return
      end
      # Player
      name = self.str2sym("player")
      if @player[name][:name].nil? || @player[name][:blackjack]
        @turn = "dealer"
        return
      end
      if @player[name]
        @playertime = true
        return
      end
    end

    
    def play_again
      # End check for game
      if $player.coins == 0
        pbMessage(_INTL("You ran out of coins!"))
        @finish = true
      end
      # Start over or nah
      if pbConfirmMessage(_INTL("\\xn[Dealer]Would you like to play again?"))
        self.clearCard
        @already_played = true
        @finished_round = false
        @turn = "player"
      else
        @finish = true
      end
    end

    # Check card opened, AI decide hit or stand
    def cardOpened(num=nil)
      return false if num.nil?
      card = []
      @player.each { |k,v|
        next if v[:name].nil?
        card << (v[:card][0] / 4)
      }
      return true if card.include?(num)
      return false
    end

    # Dealer opens cards of player
    def dealerOpen(name)
      return if name.nil?
      player = @player[name]
      return if name==:dealer || player[:name].nil?
      @player[name][:status].size.times { |i| 
        @player[name][:status][i] = true
        self.drawCard(name, i)
      }
    end

    # Compare value
    def compareValue(name)
      return "nil" if name.nil?
      player = @player[name]
      return "nil" if name==:dealer || player[:name].nil?
      dealer = @player[:dealer]
      # Dealer
      # Blackjack
      if dealer[:blackjack]
        return "draw" if player[:blackjack]
        return "greater blackjack"
      # Normal
      elsif dealer[:sum] == player[:sum]
        return "draw"
      elsif dealer[:sum] <= 21
        if player[:blackjack]
          return "less blackjack"
        elsif (dealer[:sum] > player[:sum] && player[:sum] < 21) || player[:sum] > 21
          return "greater"
        end
      elsif dealer[:sum] > 21
        player[:sum] > 21 ? (return "draw") : (return "less")
      end
      return "less"
    end

    # Check 
    def blackjackDealer(name)
      return "nil" if name.nil?
      player = @player[name]
      dealer = @player[:dealer]
      return true if player[:insurance][1] && dealer[:blackjack]
      return false
    end

    # Player get coins after playing
    def playerGet
      player = @player[:player]
      $player.coins += player[:interest] - player[:deficit]
      $player.coins -= player[:bet] / 2 if player[:giveup]
    end

  end
end