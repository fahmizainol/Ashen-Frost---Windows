class DynamicSprite < Sprite
    attr_accessor :speed
    attr_reader :frame
    attr_reader :frame_count
  
    def initialize(viewport = nil)
      super(viewport)
      @i = 0
      @speed = 5
      @frame = 0
    end
  
    def update
      return if self.bitmap.nil? || @frame_count.nil? || @frame_count == 0
      @i += 1
      if @i % @speed == 0
        self.frame += 1
      end
    end
  
    def frame=(frame)
      @frame = frame % @frame_count
      self.src_rect.x = self.src_rect.width * (@frame % @horizontal_frames)
      self.src_rect.y = self.src_rect.height * (@frame.to_f / @horizontal_frames).floor
    end
  
    def set_cell(width, height)
      @cell_width = width
      @cell_height = height
      self.src_rect.set(0, 0, width, height)
      if self.bitmap && !self.bitmap.disposed?
        @horizontal_frames = (self.bitmap.width / self.src_rect.width).ceil
        @vertical_frames = (self.bitmap.height / self.src_rect.height).ceil
        @frame_count = @horizontal_frames * @vertical_frames
      end
    end
  
    def bitmap=(bmp)
      update = self.bitmap.nil?
      super(bmp)
      self.src_rect.set(0, 0, @cell_width, @cell_height) if @cell_width && @cell_height
      if update && !self.bitmap.nil? && !self.bitmap.disposed?
        @horizontal_frames = (self.bitmap.width / self.src_rect.width).ceil
        @vertical_frames = (self.bitmap.height / self.src_rect.height).ceil
        @frame_count = @horizontal_frames * @vertical_frames
      end
    end
  end
  
  class TilingDynamicSprite < DynamicSprite
    def initialize(viewport = nil)
      super(viewport)
      @sprites = []
      8.times { @sprites << DynamicSprite.new(self.viewport) }
    end
    
    def x=(value)
      super(value)
      reposition_sprites
    end
    
    def y=(value)
      super(value)
      reposition_sprites
    end
    
    def ox=(value)
      super(value)
      reposition_sprites
    end
    
    def oy=(value)
      super(value)
      reposition_sprites
    end
    
    def z=(value)
      super(value)
      reposition_sprites
    end
    
    def zoom_x=(value)
      super(value)
      reposition_sprites
    end
    
    def zoom_y=(value)
      super(value)
      reposition_sprites
    end
    
    def blend_type=(value)
      super(value)
      reposition_sprites
    end
    
    def opacity=(value)
      super(value)
      reposition_sprites
    end
    
    def bitmap=(value)
      super(value)
      reposition_sprites
    end
    
    def reposition_sprite(sprite, x, y)
      frame = sprite.frame
      sprite.bitmap = self.disposed? ? nil : self.bitmap
      sprite.set_cell(@cell_width, @cell_height) if @cell_width && @cell_height
      sprite.zoom_x = self.zoom_x
      sprite.zoom_y = self.zoom_y
      sprite.blend_type = self.blend_type
      sprite.opacity = self.opacity
      sprite.x = self.x + (x <=> 0) * sprite.src_rect.width.to_f * sprite.zoom_x
      sprite.y = self.y + (y <=> 0) * sprite.src_rect.height.to_f * sprite.zoom_y
      sprite.z = self.z
      sprite.ox = self.ox
      sprite.oy = self.oy
      sprite.frame = frame if sprite.frame_count && sprite.frame_count > 0
    end
    
    def reposition_sprites
      return if @sprites.size == 0
      reposition_sprite(@sprites[0], -1, -1)
      reposition_sprite(@sprites[1], -1, 0)
      reposition_sprite(@sprites[2], -1, 1)
      reposition_sprite(@sprites[3], 0, -1)
      reposition_sprite(@sprites[4], 0, 1)
      reposition_sprite(@sprites[5], 1, -1)
      reposition_sprite(@sprites[6], 1, 0)
      reposition_sprite(@sprites[7], 1, 1)
    end
    
    def set_cell(width, height)
      super(width, height)
      reposition_sprites
    end
    
    def update
      super
      @sprites.each { |e| e.update }
    end
    
    def dispose
      super
      @sprites.each { |e| e.dispose }
    end
  end