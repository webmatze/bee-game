class World
  TILE_SIZE = 8
  WORLD_WIDTH = 320  # 5 screens wide
  WORLD_HEIGHT = 64

  attr_reader :flowers

  def initialize
    @tiles = Array.new(WORLD_HEIGHT / TILE_SIZE) { Array.new(WORLD_WIDTH / TILE_SIZE, 0) }
    @flowers = []
    @parallax_layers = {
      sky: { speed: 0.1, elements: generate_parallax_elements(1, 'sprites/sun.png', 16, 16, 4..8) },
      clouds: { speed: 0.3, elements: generate_parallax_elements(10, 'sprites/cloud_1.png', 32, 12, 4..8) },
      bushes: { speed: 0.7, elements: generate_parallax_elements(15, ['sprites/tree_1.png', 'sprites/tree_2.png'], 16, 32, 3..3) }
    }
    generate_world
  end

  def generate_world
    # Generate the ground (3 rows)
    (0...3).each do |y|
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
    render_parallax_backgrounds(args, camera_x)

    visible_start = (camera_x / TILE_SIZE).floor
    visible_end = visible_start + (64 / TILE_SIZE) + 1
    visible_end = [visible_end, WORLD_WIDTH / TILE_SIZE].min

    (0...3).each do |y|
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

  private

  def generate_parallax_elements(count, sprite_path, w = 8, h = 8, y_range = 3..8)
    count.times.map do
      {
        x: rand(WORLD_WIDTH),
        y: (y_range.to_a.sample * TILE_SIZE),  # Keep elements in the upper half of the screen
        w: w,
        h: h,
        path: get_sprite_path(sprite_path)
      }
    end
  end

  def get_sprite_path(sprite_path)
    sprite_path.is_a?(Array) ? sprite_path.sample : sprite_path
  end

  def render_parallax_backgrounds(args, camera_x)
    @parallax_layers.each do |_, layer|
      layer[:elements].each do |element|
        parallax_x = (element[:x] - (camera_x * layer[:speed])) % WORLD_WIDTH
        args.lowrez.sprites << element.merge(x: parallax_x)

        # Render a duplicate if the element is partially off-screen
        if parallax_x > WORLD_WIDTH - element[:w]
          args.lowrez.sprites << element.merge(x: parallax_x - WORLD_WIDTH)
        end
      end
    end
  end
end
