class Bee
  GRAVITY = 0.005  # Constant for gravity effect
  JUMP_SPEED = 0.05
  X_SPEED = 0.5
  COLLECTION_RANGE = 5  # Range within which the bee can collect from flowers

  attr_accessor :x, :y, :pollen, :nectar, :velocity_y

  def initialize
    @x = 16
    @y = 32
    @pollen = 0
    @nectar = 0
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
    collect_pollen_from_flowers(args)
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

  def collect_pollen_from_flowers(args)
    flowers = args.state.game.world.flowers
    flowers.each do |flower|
      if in_range?(flower, args)
        collected_pollen = flower.collect_pollen(1)
        @pollen += collected_pollen
      end
    end
  end

  def collect_nectar_from_flowers(args)
    flowers = args.state.game.world.flowers
    flowers.each do |flower|
      if in_range?(flower, args)
        collected_nectar = flower.collect_nectar(5)
        @nectar += collected_nectar
      end
    end
  end

  def in_range?(flower, args)
    camera_x = args.state.game.camera_x
    dx = (flower.x * World::TILE_SIZE) - camera_x - @x
    dy = (flower.y * World::TILE_SIZE) - @y
    distance = Math.sqrt(dx * dx + dy * dy)
    distance <= COLLECTION_RANGE
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
