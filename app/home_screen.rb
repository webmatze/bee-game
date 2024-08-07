class HomeScreen
  def initialize
    @menu_items = ["Start Game", "Controls"]
    @selected_item = 0
  end

  def tick(args)
    handle_input(args)
    render(args)
  end

  private

  def handle_input(args)
    if args.inputs.keyboard.key_down.up
      @selected_item = (@selected_item - 1) % @menu_items.length
    elsif args.inputs.keyboard.key_down.down
      @selected_item = (@selected_item + 1) % @menu_items.length
    elsif args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space
      if @selected_item == 0
        args.state.current_screen = :game
      else
        args.state.current_screen = :controls
      end
    end
  end

  def render(args)
    args.lowrez.background_color = [0, 0, 0]
    args.lowrez.primitives << { x: 0, y: 0, w: 64, h: 64, r: 135, g: 206, b: 235 }.solid!

    render_text(args, "Bee Pollination", 32, 55, 1)
    render_text(args, "Adventure", 32, 48, 1)

    @menu_items.each_with_index do |item, index|
      color = index == @selected_item ? [255, 255, 0] : [255, 255, 255]
      render_text(args, item, 32, 30 - index * 10, 1, color)
    end
  end

  def render_text(args, text, x, y, alignment_enum = 0, color = [0, 0, 0])
    args.lowrez.labels << {
      x: x,
      y: y,
      text: text,
      size_enum: LOWREZ_FONT_SM,
      alignment_enum: alignment_enum,
      r: color[0],
      g: color[1],
      b: color[2],
      a: 255,
      font: LOWREZ_FONT_PATH
    }
  end
end
