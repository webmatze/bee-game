class Flower
  attr_reader :x, :y, :pollen, :nectar, :foreign_pollen

  def initialize(x, y)
    @x = x
    @y = y
    @pollen = 100  # Initial pollen amount
    @nectar = 100  # Initial nectar amount
    @foreign_pollen = {}  # Hash to store pollen from other flowers
  end

  def collect_pollen(amount)
    collected = [@pollen, amount].min
    @pollen -= collected
    collected
  end

  def collect_nectar(amount)
    collected = [@nectar, amount].min
    @nectar -= collected
    collected
  end

  def add_foreign_pollen(flower_id, amount)
    @foreign_pollen[flower_id] ||= 0
    @foreign_pollen[flower_id] += amount
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
