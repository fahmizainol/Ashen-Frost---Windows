##########################
#    Kyu TextLog V3.0    #
########CONSTANTS########
PADY = 40 # Margins on the Y axis
PADX = 26 # Margins on the X axis
INTERPAD = 0 # Distance between text boxes.
IMG = nil # Background image. Leave it at nil if you don't want any. If used: "imagename".
DEFAULTCOLOR = "<c3=FFFFFF,4A4A4A>" # Default color that will be displayed in the log
##########################

if defined?(PluginManager)
  PluginManager.register({
    :name => "Kyu's Textlog",
    :version => "3.0",
    :credits => "Kyu"
  })
end

class Log
  def initialize()
    $PokemonGlobal.log ||= [] if !$PokemonGlobal.log
    @pos = $PokemonGlobal.log.length - 1
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = Sprite.new(@viewport)
    #Background.
    if !IMG
     @background = Viewport.new(0, 0, Graphics.width, Graphics.height)
     @background.z = 99998
     @background.tone = Tone.new(-75,-75,-75, 255)
  # @sprites["background"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
  #  @sprites["background"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0))
  #  @sprites["background"].tone = Tone.new(-75,-75,-75, 255)
    else
      @sprites["background"].bitmap = Bitmap.new("Graphics/Pictures/" + IMG)
    end
    # Draw up and down arrows
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
    @sprites["uparrow"].x = 242
    @sprites["uparrow"].y = 6
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
    @sprites["downarrow"].x = 242
    @sprites["downarrow"].y = 340
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    # Text are drawn over this.
    @sprites["canvas"] = Sprite.new(@viewport)
    @sprites["canvas"].y = PADY
    @sprites["canvas"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
    pbSetSystemFont(@sprites["canvas"].bitmap)
    @totalheight = 0
    
    @w = 0
    @lines = 0 #Lines currently drawn. Used to know how much @pos will increase when pressing up.
    
    #Calculates how many texts can be displayed. This is added to 
    #an array and then drawn.
    drawLines()
 
    self.update
  end
  
  def drawLines(down=false)
    if !down
      aux=[]
      while @totalheight <= Graphics.height - 2*PADY and @pos-@w >= 0
        @totalheight+= 32*$PokemonGlobal.log[@pos-@w].length + INTERPAD
        if @totalheight <= Graphics.height - 2*PADY
          aux.push($PokemonGlobal.log[@pos-@w])
        end
        @w+=1
      end
      @totalheight = 0
      for i in 0...aux.length
        for z in 0...aux[aux.length-1-i].length
          chr = getFormattedText(@sprites["canvas"].bitmap,PADX,@totalheight+(32*z) + 2,
                Graphics.width - 2*PADX,Graphics.height,
                aux[aux.length-1-i][z],32)
          drawFormattedChars(@sprites["canvas"].bitmap,chr)
        end
        @totalheight += 32*aux[aux.length-1-i].length + INTERPAD
      end
      @lines = aux.length
      @pos+=1
      aux.clear
    else #When pressing down
      while @totalheight <= Graphics.height - 2*PADY and (@pos+@w) <= $PokemonGlobal.log.length - 1
        if @totalheight + 32*$PokemonGlobal.log[@pos + @w].length <= Graphics.height - 2*PADY
          for i in 0...$PokemonGlobal.log[@pos + @w].length
            chr = getFormattedText(@sprites["canvas"].bitmap,PADX,@totalheight+(32*i) + 2,
                  Graphics.width - 2*PADX, Graphics.height,
                  $PokemonGlobal.log[@pos + @w][i],32)
            drawFormattedChars(@sprites["canvas"].bitmap,chr)
          end
        end
        @totalheight += 32*$PokemonGlobal.log[@pos + @w].length + INTERPAD
        @w += 1
      end
      @pos+= @w-1
      @lines = @w-1
    end
  end

  def update
    loop do
      # Show and update arrows
      @sprites["uparrow"].visible = @pos - @lines > 0
      @sprites["downarrow"].visible = @pos < $PokemonGlobal.log.length - 1
      update_arrows
      if Input.trigger?(Input::DOWN) and @pos < $PokemonGlobal.log.length - 1
        @sprites["canvas"].bitmap.clear
        @totalheight = 0
        @w = 0
        # Draw text boxes until the next one exceeds the limit.
        drawLines(true)
      end
     
      if Input.trigger?(Input::UP) and @pos - @lines > 0
        @sprites["canvas"].bitmap.clear
        @pos-=@lines+1
        @totalheight = 0
        @w = 0
        # Same operation as when starting the screen.
        drawLines()
      end
     
      if Input.trigger?(Input::B) # Clear
        @sprites["canvas"].bitmap.clear
        pbDisposeSpriteHash(@sprites)
        @background.dispose
        @viewport.dispose
        Input.update
        Graphics.update
        break
      end

      Input.update
      Graphics.update
    end
  end

  def update_arrows
    @i ||= 0
    mps = 3
    if @i % mps == 0
      case @i / mps
      when 1,2,3
        @sprites["uparrow"].y -= 1
        @sprites["downarrow"].y += 1
      when 4,5,6,7,8,9
        @sprites["uparrow"].y += 1
        @sprites["downarrow"].y -= 1
      when 10,11,12
        @sprites["uparrow"].y -= 1
        @sprites["downarrow"].y += 1
      end
    end
    @i = 0 if @i == 12 * mps
    @i += 1
  end
end
 
class Scene_Map #Añade la acción de Input F en Scene_Map para abrir el log
  alias update_old update
  def update
    if Input.trigger?(Input::JUMPUP)
      Log.new
    end
    update_old
  end
end

 
class PokemonGlobalMetadata #Añade la variable global log, que guarda todo.
  attr_accessor :log
  alias kyu_initialize initialize
  def initialize
    kyu_initialize
    @log ||= []
  end
end
  
def getLineChunks(value) #Divide un texto en varias líneas en función de PADX
  regex = [/<[cC][^>]*>/,/<\/[cC][^>]*>/,/<[bB]>/,/<\/[bB]>/,/<[iI]>/,/<\/[iI]>/,
  /<[uU]>/,/<\/[uU]>/,/<[sS]>/,/<\/[sS]>/,/<outln>/,/<\/outln>/,/<outln2>/,
  /<\/outln2>/,/<fn=\d+>/,/<\/fn>/,/<fs=\d+>/,/<\/fs>/,/<[oO]=\d*>/,/<\/[oO]>/,
  /<ac>/,/<\/ac>/,/<al>/,/<\/al>/,/<ar>/,/<\/ar>/]
  bitmap = Bitmap.new(Graphics.width - 2*PADX,Graphics.height)
  width = Graphics.width - 2*PADX
  pbSetSystemFont(bitmap)
  totalwidth = 0 #Anchura total de la línea actual
  count = 0 #Línea actual
  
  #Color, bold, italic, underlined, struck, outline, thickoutline, font,
  #fontsize, opacity, centered, left-centered,right-centered
  regs=["","","","","","","","","","","","",""]
  ret=[""] # Array with all the lines of the text.
  value = value.clone
  text = []
  
  # Adding line breaks after alignments
  value.gsub!(/<ac>/,"\n<ac>")
  value.gsub!(/<\/ac>/,"</ac>\n")
  value.gsub!(/<al>/,"\n<al>")
  value.gsub!(/<\/al>/,"</al>\n")
  value.gsub!(/<ar>/,"\n<ar>")
  value.gsub!(/<\/ar>/,"</ar>\n")
  
  # Processing of line breaks
  while value[/.*((\n)|(<br\/>))/] != nil
    val = value.slice!(/.*((\n)|(<br\/>))/)
    if val[/<r>/]
      val.gsub!(/<r>/,"<ar>")
      val.insert(-2,"</ar>")
    end
    text.push(val)
  end
  # Add what's left after the line breaks
  text.push(value) 
  
  # Analysis of all the words in the text line by line
  text.each{|line|
    words = line.split
    aux = []
    words.each_index{|i|
      if words[i][/<[^>]*>(<[^>]*>|\w+)/] != nil
        val = words[i].slice!(/<[^>]*>/)
        aux.push(val)
        aux.push(words[i])
      elsif words[i][/\w+<[^>]*>/] != nil
        val = words[i].slice!(/<[^>]*>/)
        aux.push(words[i])
        aux.push(val)
      else
        aux.push(words[i])
      end
    }
    words = aux
    init = "" #Expresiones de apertura Ej: <fs=X>
    ending = "" #Expresiones de cierre Ej: </fs>
    
    words.each{|word|
        if word[/^<.*>$/] == nil
          word+= " "
        end
        init = "" #Expresiones de apertura Ej: <fs=X>
        ending = "" #Expresiones de cierre Ej: </fs>
        
        #Detecta comandos especiales y los activa en regs hasta que encuentra
        #el de cierre.
        regex.each_index{|index|
          aux = word.slice!(regex[index])
          if aux != nil
            if index % 2 != 0 #Comando de cierre
              if index == 1
                regs[0].slice!(/[^<]*<[cC][^>]*>$/)
                regs[0] = DEFAULTCOLOR
                ending += DEFAULTCOLOR
              else
                regs[((index+1)/2)-1]=""
              end
              ending += aux
              if index == 14 #</fn>
                pbSetSystemFont(bitmap)
              elsif index == 3 #</b>
                bitmap.font.bold = false
              elsif index == 5 #</i>
                bitmap.font.italic = false
              end
            else # Open command
              regs[index/2] = aux
              init += aux
              if index == 14 #<fn=X>
                bitmap.font.name = aux.gsub(/fn=/){""}
              elsif index == 2 #<b>
                bitmap.font.bold = true
              elsif index == 4 #<i>
                bitmap.font.italic = true
              end
            end
          end
        }
        
        #In Word only the net word remains without special commands. It is measured
        #how much it occupies in bitmap and is added to totalwidth. Depending on it
        #whether a line break is performed or not.
        wordwidth = bitmap.text_size(word).width
        totalwidth += wordwidth
        if totalwidth > width
          count += 1
          ret.push("")
          regs.each{|reg|
            ret[count]+=reg
          }
          ret[count]+= word + ending
          totalwidth = wordwidth
        else
          ret[count] += (init + word + ending)
        end
      }
      count += 1
      ret.push("")
      regs.each{|reg|
        ret[count]+=reg
        }
      ret[count]+=ending
      totalwidth = 0
    }
  return ret
end

################################################################################
#This method is used to change the colors of the texts in a textbox to 
#the textlog.
#To add a new color, just add a line like this:
#text.gsub!(tag_to_replace, new_tag)
################################################################################
def changeSkinColor(text)
    text = text.clone
    text.gsub!("<c3=3050C8,BABABA>", "<c3=1880F8,000000>")  # 1  \b
    text.gsub!("<c3=E00808,BABABA>", "<c3=E00808,000000>")  # 2  \r    
    #Ashen Frost Colours 
    text.gsub!("<c3=1880F8,BABABA>", "<c3=FFFFFF,1880F8>")  # 1  Blue
    text.gsub!("<c3=F83018,BABABA>", "<c3=FFFFFF,E00808>")  # 2  Red
    text.gsub!("<c3=18C020,BABABA>", "<c3=FFFFFF,009807>")  # 3  Green
    text.gsub!("<c3=40C0D0,BABABA>", "<c3=FFFFFF,2EA7B6>")  # 4  Cyan
    text.gsub!("<c3=D030C0,BABABA>", "<c3=FFFFFF,CC66C1>")  # 5  Magenta
    text.gsub!("<c3=E0D820,BABABA>", "<c3=FFFFFF,CCAF66>")  # 6  Yellow
    text.gsub!("<c3=98A0B0,BABABA>", "<c3=FFFFFF,7D889B>")  # 7  Grey
    text.gsub!("<c3=000000,BABABA>", "<c3=FFFFFF,000000>")  # 8  White
    text.gsub!("<c3=9018F8,BABABA>", "<c3=FFFFFF,8439C5>")  # 9  Purple
    text.gsub!("<c3=501028,BABABA>", "<c3=FFFFFF,891440>")  # 10 Dominic
    text.gsub!("<c3=205A94,BABABA>", "<c3=FFFFFF,205A94>")  # 11 Adamant
    text.gsub!("<c3=802094,BABABA>", "<c3=FFFFFF,802094>")  # 12 Lustrous
    text.gsub!("<c3=AD49CA,BABABA>", "<c3=FFFFFF,AD49CA>")  # 13 Ditto
    text.gsub!("<c3=510016,BABABA>", "<c3=FFFFFF,A9183F>")  # 14 Arceus
    text.gsub!("<c3=263035,BABABA>", "<c3=FFFFFF,263035>")  # 15 Nova
    text.gsub!("<c3=1D7064,BABABA>", "<c3=FFFFFF,1D7064>")  # 16 Luciano
    text.gsub!("<c3=263035,BABABA>", "<c3=FFFFFF,263035>")  # 17 Raphael
    text.gsub!("<c3=426385,BABABA>", "<c3=FFFFFF,426385>")  # 18 Leonardo & Raph
    text.gsub!("<c3=3A1372,BABABA>", "<c3=FFFFFF,3A1372>")  # 19 Lucile
    text.gsub!("<c3=1D7064,BABABA>", "<c3=FFFFFF,1D7064>")  # 20 Serenity Trainer
    text.gsub!("<c3=473E34,BABABA>", "<c3=FFFFFF,473E34>")  # 21 Radon
    text.gsub!("<c3=590C16,BABABA>", "<c3=FFFFFF,62242C>")  # 22 Maisy
    text.gsub!("<c3=000000,1880F8>", "<c3=FFFFFF,1880F8>")  # 23 Blue Testimony
    text.gsub!("<c3=000000,F83018>", "<c3=FFFFFF,F83018>")  # 24 Red Testimony
    text.gsub!("<c3=000000,18C020>", "<c3=FFFFFF,009807>")  # 25 Green Testimony
    text.gsub!("<c3=F8D000,BABABA>", "<c3=FFFFFF,826D00>")  # 26 Zapdos
    text.gsub!("<c3=B1B1B7,BEBEB0>", "<c3=FFFFFF,6F6F76>")  # 27 Nearly Invisible TExt
    text.gsub!("<c3=A79B9E,555571>", "<c3=FFFFFF,998B8E>")  # 28 Tombstone 
    text.gsub!("<c3=37687C,96C5D8>", "<c3=FFFFFF,37687C>")  # 29 Northallow Signpost (Blue)  
    text.gsub!("<c3=8F7163,E0B069>", "<c3=FFFFFF,8F7163>")  # 30 SS. Suosirg Plaque 
    text.gsub!("<c3=887358,505068>", "<c3=FFFFFF,887358>")  # 31 Fogdale Wooden Sign  
    text.gsub!("<c3=708878,F0F0E0>", "<c3=FFFFFF,708878>")  # 32 Chalkboard  
    text.gsub!("<c3=539097,BAC8D6>", "<c3=FFFFFF,539097>")  # 33 Underground Signboard
    text.gsub!("<c3=E00808,D0D0C8>", "<c3=FFFFFF,E00808>")  # 34 Highlighted Text (Red)
    text.gsub!("<c3=3050C8,D0D0C8>", "<c3=FFFFFF,3050C8>")  # 35 Highlighted Text (Blue)
    text.gsub!("<c3=2FC667,D0D0C8>", "<c3=FFFFFF,009807>")  # 36 Highlighted Text (Green)
    text.gsub!("<c3=8C0C0C,F66441>", "<c3=FFFFFF,8C0C0C>")  # 37 OH SHIT (WARNING)
    text.gsub!("<c3=FFFFFF,484848>", "<c3=FFFFFF,000000>")  # 38 Explaining Hardmode
    text.gsub!("<c3=7F3578,BABABA>", "<c3=FFFFFF,7F3578>")  # 39 Sammy
    text.gsub!("<c3=6A3D4E,BABABA>", "<c3=FFFFFF,6A3D4E>")  # 40 Rosewell
    text.gsub!("<c3=882F31,BABABA>", "<c3=FFFFFF,882F31>")  # 41 Eloise
    text.gsub!("<c3=3E4C55,E0F8CF>", "<c3=FFFFFF,3E4C55>")  # 42 VR
    text.gsub!("<c3=6166B4,BABABA>", "<c3=FFFFFF,6166B4>")  # 43 Lugia
    text.gsub!("<c3=A04870,BABABA>", "<c3=FFFFFF,A04870>")  # 44 Cresselia
    text.gsub!("<c3=DCCDB9,9B724D>", "<c3=FFFFFF,847766>")  # 45 Ancient Book Text
    text.gsub!("<c3=894B2A,BABABA>", "<c3=FFFFFF,BA6B40>")  # 46 Bruce 
    text.gsub!("<c3=000000,6166B4>", "<c3=FFFFFF,6166B4>")  # 43 Lugia (Dark)
    text.gsub!("<c3=000000,A04870>", "<c3=FFFFFF,A04870>")  # 44 Cresselia (Dark)
    text.gsub!("<c3=383E8B,BABABA>", "<c3=FFFFFF,383E8B>")  # 49 Mordecai
    text.gsub!("<c3=2D7106,BABABA>", "<c3=FFFFFF,2D7106>")  # 50 Ramira
    text.gsub!("<c3=3E4C55,E0F8CF>", "<c3=FFFFFF,3E4C55>")  # 51 Codec
    text.gsub!("<c3=A3691D,BABABA>", "<c3=FFFFFF,A3691D>")  # 52 Hart
    text.gsub!("<c3=487EC0,BABABA>", "<c3=FFFFFF,487EC0>")  # 53 Sylvester II
    return text
end