require 'app/lowrez.rb'

# Bee Pollination Adventure
#
# A LowRez game where you control a bee to pollinate flowers across a scrolling world.
# The game is built using the DragonRuby GTK framework and adheres to the 64x64 pixel
# resolution constraint of the LowRez game jam.
#
# Game features:
# - Scrolling world spanning multiple screens
# - Player-controlled bee character
# - Flower pollination mechanics
# - Obstacles and challenges (to be implemented)
#
# This file contains the main game logic, including the Bee and World classes.

class Bee
  attr_accessor :x, :y, :pollen

  def initialize
    @x = 16
    @y = 32
    @pollen = 0
  end

  def move_left
    move(-1, 0)
  end

  def move_right
    move(1, 0)
  end

  def move_up
    move(0, 1)
  end

  def move_down
    move(0, -1)
  end

  def move(dx, dy)
    @x += dx
    @y += dy
  end

  def render(args)
    args.lowrez.sprites << {
      x: @x,
      y: @y,
      w: 8,
      h: 8,
      path: 'sprites/bee_1.png'
    }
  end
end

class World
  TILE_SIZE = 8
  WORLD_WIDTH = 320  # 5 screens wide
  WORLD_HEIGHT = 64

  def initialize
    @tiles = Array.new(WORLD_HEIGHT / TILE_SIZE) { Array.new(WORLD_WIDTH / TILE_SIZE, 0) }
    generate_world
  end

  def generate_world
    # Generate sky (6 rows) and ground (3 rows)
    (0...8).each do |y|
      (0...@tiles[y].length).each do |x|
        @tiles[y][x] = y > 2 ? 0 : 1
      end
    end

    # Add random flowers in the third row from the bottom
    flower_row = 3
    @tiles[flower_row].map! do |tile|
      rand < 0.2 ? 2 : tile  # 20% chance of a flower
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
      'sprites/grass.png'
    when 2
      'sprites/flower_1.png'
    end
  end
end

$bee = Bee.new
$world = World.new
$camera_x = 0

def tick args
  args.lowrez.background_color = [0, 0, 0]

  args.lowrez.solids << {
    x: 0,
    y: 0,
    w: 64,
    h: 64,
    r: 135,
    g: 206,
    b: 235
  }
  # Handle input for bee movement
  if args.inputs.left
    $bee.move_left
    $camera_x = [$camera_x - 1, 0].max
  elsif args.inputs.right
    $bee.move_right
    $camera_x += 1
  end

  if args.inputs.up
    $bee.move_up
  elsif args.inputs.down
    $bee.move_down
  end

  $world.render(args, $camera_x)
  $bee.render(args)

  args.lowrez.labels  << {
    x: 32,
    y: 60,
    text: "LowrezJam 2024",
    size_enum: LOWREZ_FONT_SM,
    alignment_enum: 1,
    r: 0,
    g: 0,
    b: 0,
    a: 255,
    font: LOWREZ_FONT_PATH
  }

end
