require 'smaug.rb'
require 'app/lowrez.rb'
require 'app/bee.rb'
require 'app/flower.rb'
require 'app/world.rb'
require 'app/beehive.rb'

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

class Game
  attr_reader :bee, :world, :camera_x, :particles, :beehive

  def initialize
    @bee = Bee.new
    @world = World.new
    @beehive = Beehive.new(1, 1.5)
    @camera_x = 0
    @particles = []
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

    if args.inputs.keyboard.key_down.space
      @bee.collect_nectar_from_flowers(args)
    end

    if args.inputs.keyboard.key_held.space
      @bee.deposit_pollen_to_beehive(args)
      @bee.deposit_nectar_to_beehive(args)
    end
  end

  def update(args)
    @bee.update(args)
    update_particles(args)
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
    @beehive.render(args)
    render_particles(args)
    @bee.render(args)
    render_text(args, "POLLEN: #{@bee.pollen}", 2, 62)
    render_text(args, "NECTAR: #{@bee.nectar}", 2, 56)
  end

  private

  def update_particles(args)
    gravity = 0.01  # Adjust this value to control the strength of gravity
    @particles.each do |particle|
      particle[:x] += particle[:dx]
      particle[:y] += particle[:dy]
      particle[:dy] -= gravity  # Apply gravity to vertical velocity
      particle[:lifetime] -= 1
    end
    @particles.reject! { |particle| particle[:lifetime] <= 0 }
  end

  def render_particles(args)
    @particles.each do |particle|
      args.lowrez.primitives << {
        x: particle[:x] - @camera_x,
        y: particle[:y],
        w: 1,
        h: 1,
        r: 255,
        g: 255,
        b: 0
      }.solid!
    end
  end

  def create_nectar_particles(x, y, count = 10)
    count.times do
      @particles << {
        x: x,
        y: y,
        dx: (rand(10) - 5) * 0.1,
        dy: (rand(10) - 5) * 0.1,
        lifetime: 60  # 2 seconds at 60 FPS
      }
    end
  end

  def render_text(args, text, x, y, alignment_enum = 0)
    args.lowrez.labels << {
      x: x,
      y: y,
      text: text,
      size_enum: LOWREZ_FONT_SM,
      alignment_enum: alignment_enum,
      r: 0,
      g: 0,
      b: 0,
      a: 128,
      font: LOWREZ_FONT_PATH
    }
  end
end


def tick(args)
  if args.state.game.nil?
    args.state.game = Game.new
  end
  args.state.game.tick(args)
end
