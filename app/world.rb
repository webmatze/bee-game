class World
  TILE_SIZE = 8
  WORLD_WIDTH = 320  # 5 screens wide
  WORLD_HEIGHT = 64

  attr_reader :flowers

  def initialize
    @tiles = Array.new(WORLD_HEIGHT / TILE_SIZE) { Array.new(WORLD_WIDTH / TILE_SIZE, 0) }
    @flowers = []
    generate_world
  end

  def generate_world
    # Generate sky (6 rows) and ground (3 rows)
    (0...8).each do |y|
      (0...@tiles[y].length).each do |x|
        @tiles[y][x] = y > 2 ? 0 : rand(2) + 1
      end
    end

    # Add random flowers in the third row from the bottom
    flower_row = 3
    (0..39).to_a.shuffle[0..19].each do |x|
      @flowers << Flower.new(x, flower_row - rand(4))
    end
  end

  def render(args, camera_x)
    visible_start = (camera_x / TILE_SIZE).floor
    visible_end = visible_start + (64 / TILE_SIZE) + 1
    visible_end = [visible_end, WORLD_WIDTH / TILE_SIZE].min

    (0...8).each do |y|
      (visible_start...visible_end).each do |x|
        tile = @tiles[y][x]
        screen_x = (x * TILE_SIZE) - camera_x
        args.lowrez.sprites << {
          x: screen_x,
          y: y * TILE_SIZE,
          w: TILE_SIZE,
          h: TILE_SIZE,
          path: tile_sprite(tile)
        }
      end
    end
  end

  def tile_sprite(tile)
    case tile
    when 0
      'sprites/sky.png'
    when 1
      'sprites/grass_1.png'
    when 2
      'sprites/grass_2.png'
    end
  end
end
