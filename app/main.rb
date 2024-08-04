require 'smaug.rb'
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
  GRAVITY = 0.005  # Constant for gravity effect
  JUMP_SPEED = 0.05
  X_SPEED = 0.5

  attr_accessor :x, :y, :pollen, :velocity_y

  def initialize
    @x = 16
    @y = 32
    @pollen = 0
    @animation_frame = 0
    @last_frame_change = 0
    @tilt_angle = 0
    @last_dx = 0
    @velocity_y = 0  # Initialize vertical velocity
  end

  def apply_gravity
    @velocity_y -= GRAVITY
    @y += @velocity_y
    @y = [@y, 0].max  # Prevent going below the bottom of the screen
  end

  def update(args)
    apply_gravity
    update_tilt
  end

  def move_left
    move(-X_SPEED, 0)
  end

  def move_right
    move(X_SPEED, 0)
  end

  def move_up
    move(nil, 1)
    @velocity_y = JUMP_SPEED
  end

  def move_down
    move(nil, -1)
    @velocity_y = -JUMP_SPEED
  end

  def stop
    move(0, 0)
  end

  def move(dx, dy)
    @x += dx if dx
    @y += dy if dy
    @last_dx = dx if dx
  end

  def update_tilt
    target_tilt = @last_dx.round * 90  # 10 degrees left or right
    @tilt_angle = (@tilt_angle * 0.8 + target_tilt * 0.2).round  # Smooth transition
  end

  def render(args)
    current_time = args.state.tick_count

    if current_time - @last_frame_change >= 10
      @animation_frame = (@animation_frame + 1) % 2
      @last_frame_change = current_time
    end

    args.lowrez.sprites << {
      x: @x,
      y: @y,
      w: 8,
      h: 8,
      path: "sprites/bee_#{@animation_frame + 1}.png",
      angle: -@tilt_angle
    }
  end
end

class Flower
  attr_reader :x, :y, :pollen

  def initialize(x, y)
    @x = x
    @y = y
    @pollen = 100  # Initial pollen amount
  end

  def collect_pollen(amount)
    collected = [@pollen, amount].min
    @pollen -= collected
    collected
  end

  def render(args, camera_x)
    screen_x = (@x * World::TILE_SIZE) - camera_x
    args.lowrez.sprites << {
      x: screen_x,
      y: @y * World::TILE_SIZE,
      w: World::TILE_SIZE,
      h: World::TILE_SIZE,
      path: 'sprites/flower_1.png'
    }
  end
end

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
        @tiles[y][x] = y > 2 ? 0 : 1
      end
    end

    # Add random flowers in the third row from the bottom
    flower_row = 3
    (0..39).to_a.shuffle[0..10].each do |x|
      @flowers << Flower.new(x, flower_row)
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
    end
  end
end

class Game
  def initialize
    @bee = Bee.new
    @world = World.new
    @camera_x = 0
  end

  def tick(args)
    handle_input(args)
    update(args)
    render(args)
  end

  private

  def handle_input(args)
    if args.inputs.left
      if @bee.x > 0
        @bee.move_left
      else
        @camera_x = [@camera_x - Bee::X_SPEED, 0].max
      end
    elsif args.inputs.right
      if @bee.x < 56
        @bee.move_right
      else
        @camera_x = [@camera_x + Bee::X_SPEED, World::WORLD_WIDTH - 64].min
      end
    else
      @bee.stop
    end

    if args.inputs.up
      @bee.move_up if @bee.y < 56
    elsif args.inputs.down
      @bee.move_down if @bee.y > 0
    end
  end

  def update(args)
    @bee.update(args)
  end

  def render(args)
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

    @world.render(args, @camera_x)
    @world.flowers.each { |flower| flower.render(args, @camera_x) }
    @bee.render(args)
    args.lowrez.labels << {
      x: 32,
      y: 60,
      text: "LowrezJam 2024",
      size_enum: LOWREZ_FONT_SM,
      alignment_enum: 1,
      r: 0,
      g: 0,
      b: 0,
      a: 128,
      font: LOWREZ_FONT_PATH
    }
  end
end

$game = Game.new

def tick(args)
  $game.tick(args)
end
