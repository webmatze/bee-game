require 'smaug.rb'
require 'app/lowrez.rb'
require 'app/bee.rb'
require 'app/flower.rb'
require 'app/world.rb'

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
  attr_reader :bee, :world, :camera_x

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
    render_text(args, "Pollen: #{@bee.pollen}", 2, 62)
    render_text(args, "Nectar: #{@bee.nectar}", 2, 56)
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
