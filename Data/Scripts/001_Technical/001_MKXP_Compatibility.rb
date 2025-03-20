# Using mkxp-z v2.3.1 - https://gitlab.com/mkxp-z/mkxp-z/-/releases/v2.3.1
$VERBOSE = nil
Font.default_shadow = false if Font.respond_to?(:default_shadow)
Graphics.frame_rate = 40
Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

# mkxp-z extra libraries
# macOS version of mkxp-z has the standard libraries located elsewhere but they're in load path by default.
$:.push('stdlib') unless System.platform[/macOS/]
# Fix loading of rbconfig gem.
$:.push('stdlib/x64-mingw32') if System.platform[/Windows/]
$:.push('stdlib/x86_64-linux') if System.platform[/Linux/]
$:.push('../Resources/Ruby/3.1.0/x86_64-darwin') if System.platform[/macOS/]
# Add external gems to load path.
$:.push('gems')

# JoiPlay RPG Maker Plugin 1.20.51 completely broke require so we have to use require_relative instead.
def gem(name)
  if $joiplay
    require File.expand_path("../gems/" + name + ".rb", __FILE__)
  else
    require name
  end
end

def pbSetWindowText(string)
  System.set_window_title(string || System.game_title)
end

class Bitmap
  attr_accessor :text_offset_y

  alias mkxp_draw_text draw_text unless method_defined?(:mkxp_draw_text)

  def draw_text(x, y, width, height = nil, text = "", align = 0)
    if x.is_a?(Rect)
      x.y -= (@text_offset_y || 0)
      # rect, string & alignment
      mkxp_draw_text(x, y, width)
    else
      y -= (@text_offset_y || 0)
      height = text_size(text).height
      mkxp_draw_text(x, y, width, height, text, align)
    end
  end
end

def pbSetResizeFactor(factor)
  if !$ResizeInitialized
    Graphics.resize_screen(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
    $ResizeInitialized = true
  end
  if factor < 0 || factor == 4
    Graphics.fullscreen = true if !Graphics.fullscreen
  else
    Graphics.fullscreen = false if Graphics.fullscreen
    Graphics.scale = (factor + 1) * 0.5
    Graphics.center
  end
end
