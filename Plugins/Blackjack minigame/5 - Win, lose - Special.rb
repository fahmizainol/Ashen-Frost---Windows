module BlackJack
  class Play
    
    # Win (Blackjack)
    def winBlackJack(cards,sum)
      return if cards.size!=2
      ace = 0 if !ace
      cards.each { |j| ace += 1 if j/4 == 0 }
      return true if (ace==1 && sum==21) || ace==2
      return false
    end
    
  end
end