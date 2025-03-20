module BlackJack
  class Play

    # Create scene
    def create_scene
      # Background
      addBackgroundPlane(@sprites,"bg","BlackJack/Background",@viewport) if !@sprites["bg"]
      # Draw message box
      3.times { |i|
        @sprites["left mess #{i}"] = BitmapWrapper.new(Graphics.width,Graphics.height) if !@sprites["left mess #{i}"]
        @sprites["mid mess #{i}"] = BitmapWrapper.new(Graphics.width,Graphics.height) if !@sprites["mid mess #{i}"]
        @sprites["right mess #{i}"] = BitmapWrapper.new(Graphics.width,Graphics.height) if !@sprites["right mess #{i}"]
      }
      @sprites["mess"] = AnimatedBitmap.new("Graphics/Pictures/BlackJack/Message Box").deanimate if !@sprites["mess"]
      @sprites["signal"] = AnimatedBitmap.new("Graphics/Pictures/BlackJack/Signal").deanimate if !@sprites["signal"]
      # Draw bet text in the box
      self.create_sprite_2("bet_text",@viewport) if !@sprites["bet_text"]
      @sprites["bet_text"].z = 40
      self.clearTxt("bet_text")
      # Draw sum text in the box
      self.create_sprite_2("sum_text",@viewport) if !@sprites["sum_text"]
      @sprites["sum_text"].z = 40
      self.clearTxt("sum_text")
    end

    # Set position of player
    def setPlayer
      # Dealer
      self.setStruct(:dealer)
      @player[:dealer][:name] = "Dealer"
      @player[:dealer][:position][0] = self.posCardDealer[0]
      @player[:dealer][:position][1] = self.posCardDealer[1]
      # Player
      self.setStruct(:player)
      # Check position of player
      @player[:player][:name] = $player.name
      @player[:player][:player] = true
      positioncard = self.posCardPlayer
      @player[:player][:position][0] = positioncard[0]
      @player[:player][:position][1] = positioncard[1]
    end

    # Bet
    def bet
      pbMessage(_INTL("\\CN\\xn[Dealer]Welcome to Blackjack!")) if !@already_played
      # Setup bet messages
      params = ChooseNumberParams.new
      params.setRange(1, $player.coins)
      params.setInitialValue(1)
      params.setCancelValue(-1)
      bet_amount = 0
      loop do
        bet_amount = pbMessageChooseNumber(
          _INTL("\\CN\\xn[Dealer]How much would you like to bet?"), params
        )
        if bet_amount > $player.coins
          pbMessage(_INTL("\\CN\\xn[Dealer]You don't have enough coins!"))
        elsif bet_amount == 0
          pbMessage(_INTL("\\CN\\xn[Dealer]You must place a bet!"))
        else
          break      
        end
      end
      # Update values
      @player[:player][:bet] = bet_amount
      @player[:player][:insurance][0] = @player[:player][:bet] / 2
      # Draw text 'Bet'
      self.drawTxtBet
    end

    # Draw text when bet
    def drawTxtBet
      self.clearTxt("bet_text")
      # Draw text
      text = []
      string = "Bet: #{@player[:player][:bet]}"
      x = Graphics.width  / 2
      y = 252
      text << [ string, x, y, 0, Color.new(74, 74, 74), Color.new(173, 181, 189) ]
      self.drawTxt("bet_text",text,nil,nil,1,false,2,false,false)
    end

    # Draw text when card value changes
    def drawTxtSum
      self.clearTxt("sum_text")
      # Draw text
      text = []
      string = "Card Sum: #{@player[:player][:sum]}"
      x = Graphics.width / 2
      y = 276
      text << [ string, x, y, 0, Color.new(74, 74, 74), Color.new(173, 181, 189) ]
      self.drawTxt("sum_text",text,nil,nil,1,false,2,false,false)
    end

    # Set sprite Message
    def setSizeMess(*arg)
      name, origin, rnew, rold = arg
      return if !rnew.is_a?(Array) || !rold.is_a?(Array) 
      return if rnew.size<4 || rold.size < 4 
      return if !@sprites["#{name}"] || !@sprites["#{origin}"]
      @sprites["#{name}"].stretch_blt(
        Rect.new(rnew[0],rnew[1],rnew[2],rnew[3]),
        @sprites["#{origin}"],
        Rect.new(rold[0],rold[1],rold[2],rold[3])
      )
    end

    # Draw blt Message
    def drawBltMess(*arg)
      bitmap, x, y, sprite, rnew = arg
      return if !rnew.is_a?(Array)
      return if rnew.size < 4
      bitmap.blt(x, y, sprite, Rect.new(rnew[0],rnew[1],rnew[2],rnew[3]))
    end

    # Draw box of message
    def drawMess(bitmap,text=nil,wmax=nil,hmax=nil)
      return if bitmap.nil?
      wmax = (Graphics.width - bitmap.text_size(text).width) / 2   if !wmax
      hmax = Graphics.height / 2 - bitmap.text_size(text).height + 5 if !hmax
      suml = summ = sumr = sumh = 0
      rnewl = rnewm = rnewr = []
      4.times {
        rnewl << 0
        rnewm << 0
        rnewr << 0
      }
      3.times { |i|
        # Left, Right
        wl = RectMessBox[i][0]
        hl = RectMessBox[i][1]
        suml += RectMessBox[i-1][1] if i!=0
        # Middle
        wm = RectMessBox[i+3][0]
        hm = RectMessBox[i+3][1]
        summ += RectMessBox[i+3-1][1] if i!=0
        # Set
        if i==1 # Middle
          # Left
          rnewl = [0, 0, wl*2, bitmap.text_size(text).height]
          # Middle
          rnewm = [0, 0, bitmap.text_size(text).width, bitmap.text_size(text).height]
          # Right
          rnewr = [0, 0, wl*2, bitmap.text_size(text).height]
        else # Left, Right
          # Left
          rnewl = [0, 0, wl*2, hl*2]
          # Middle
          rnewm = [0, 0, bitmap.text_size(text).width, hl*2]
          # Right
          rnewr = [0, 0, wl*2, hl*2]
        end
        # Left
        roldl = [0, suml, wl, hl]
        # Middle
        roldm = [wl, summ, wm, hm]
        # Right
        roldr = [wl+wm, suml, wl, hl]
        # Set sprite
        self.setSizeMess("left mess #{i}", "mess", rnewl, roldl)
        self.setSizeMess("mid mess #{i}", "mess", rnewm, roldm)
        self.setSizeMess("right mess #{i}", "mess", rnewr, roldr)
        # Draw bitmap
        sumh += (i==1 ? hl*2 : bitmap.text_size(text).height) if i!=0
        x = wmax - wl*2
        y = hmax + sumh
        self.drawBltMess(bitmap, x, y, @sprites["left mess #{i}"], rnewl)
        x += rnewl[2]
        self.drawBltMess(bitmap, x, y, @sprites["mid mess #{i}"], rnewm)
        x += rnewm[2]
        self.drawBltMess(bitmap, x, y, @sprites["right mess #{i}"], rnewr)
      }
    end

    # Progress distribute
    def distribute
      2.times {
        @player.each { |k,v|
          next if v[:name].nil?
          self.distributeCard(k, v[:status].size==0)
          self.drawCard(k, v[:card].size-1)
        }
      }
      # Check blackjack for player
      @player.each { |k,v|
        next if v[:name].nil?
        next if !self.winBlackJack(v[:card],v[:sum])
        @player[k][:blackjack] = true
        next if k==:dealer
        self.redrawCard(k)
      }
    end

    # Distribute card
    def distributeCard(name,status=false)
      random = rand(@card.size)
      @player[name][:card] << @card[random]
      @card.delete_at(random)
      @player[name][:status] << status
      @player[name][:sum] = self.calcSPerCard(@player[name][:card])
      drawTxtSum
    end

    # Draw new card
    def drawCard(*arr)
      return if !arr.is_a?(Array) || arr.size < 2
      name, position = arr
      return if !name.is_a?(Symbol) && !name.is_a?(String)
      name = self.str2sym(name) if name.is_a?(String)
      namesprite = "#{name} #{position}"
      if @sprites["#{namesprite}"]
        self.dispose("#{namesprite}")
        @sprites["#{namesprite}"] = nil
      end
      create_sprite(namesprite, "Card", @viewport)
      # Position of this card
      card = @player[name][:position]
      # Open - Make it so player always draws upward
      if (@player[name][:status][position] || @player[name][:player])
        w = self.posCardPlayer(0)[2]
        h = self.posCardPlayer(0)[3]
        set_src_wh_sprite(namesprite, w, h)
        x = @player[name][:card][position] % 4 * w
        y = @player[name][:card][position] / 4 * h
        set_src_xy_sprite(namesprite, x, y)
      # Closed
      else
        @sprites["#{namesprite}"].bitmap = Bitmap.new("Graphics/Pictures/BlackJack/Behind")
      end
      @sprites["#{namesprite}"].z = card[2] + (@player[name][:status][position] ?  position : -position) 
      set_xy_sprite(namesprite, card[0] + position*15, card[1])
    end

    # Draw card (Opened)
    def redrawCard(name)
      @player[name][:card].size.times { |i|
        @player[name][:status][i] = true
        self.drawCard(name, i)
      }
    end

    def clearCard
      # Clear out all cards of player and dealter
      @player.each { |k,v|
        @player[k][:card].size.times { |i|
        self.dispose("#{k} #{i}")
        @sprites["#{k} #{i}"] = nil
        }
      }
      # Clear out all the opened values
      @opened.map! { |x| x = false}
    end

    def playerBet
      @playertime = @turn == "player"
      if !@playertime
        return
      end
      # Set value
      redraw = 0
      loop do
        # Update
        self.update_ingame
        # Break
        if !@playertime
          # Next turn
          @turn = "dealer"
          break
        end
        # Check lost all (value of cards is greater than or equal to 22)
        if self.calcSPerCard(@player[:player][:card]) >= 22
          @player[:player][:lost] = true
          @playertime = false
          redo
        end
        # Draw text
        if redraw && redraw > 0
          redraw -= 1
        end
        # Choose your value
        cmd = pbMessage(_INTL('What would you like to do?'), ["Hit", "Stand", "Double", "Insure", "Give Up"], 5)
        case cmd
        when 0
          # Hit
          redraw = 25
          self.distributeCard(:player)
          self.drawCard(:player, @player[:player][:card].size - 1)
        when 1
          @playertime = false
        when 2
          # Double
          redraw = 25
          double = self.double(:player) ? pbMessage(_INTL("You distributed your cards and doubled down.")) : pbMessage(_INTL("You cannot double down."))
        when 3
          # Insure
          redraw = 25
          self.insure(:player)
          insurance = @player[:player][:insurance][1] ? pbMessage(_INTL("You bet insurance that the house has Blackjack."))  : pbMessage(_INTL("You cannot bet insurance."))          
        when 4
          # Give Up
          if pbConfirmMessage(_INTL("Are you sure you want to give up? You'll lose half of your initial bet."))
            @player[:player][:giveup] = true
            self.dealerOpen(:player)
            @playertime = false
          end
        end
      end
    end

  end
end