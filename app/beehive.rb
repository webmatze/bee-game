class Beehive
  attr_accessor :pollen, :nectar
  attr_accessor :x, :y, :width, :height

  def initialize(x, y)
    @pollen = 0
    @nectar = 0
    @x = x
    @y = y
    @width = 16
    @height = 16
  end

  def render(args)
    screen_x = (@x * @width) - args.state.game.camera_x
    screen_y = (@y * @height)
    args.lowrez.sprites << {
      x: screen_x,
      y: screen_y,
      w: @width,
      h: @height,
      path: "sprites/beehive.png"
    }
  end
end
