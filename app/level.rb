class Level
  attr_reader :number, :description, :goal_type, :goal_amount, :time_limit

  def initialize(number, description, goal_type, goal_amount, time_limit = nil)
    @number = number
    @description = description
    @goal_type = goal_type
    @goal_amount = goal_amount
    @time_limit = time_limit
    @show_popup = true
  end

  def start
    @show_popup = true
  end

  def reset
    @show_popup = true
  end

  def hide_popup
    @show_popup = false
  end

  def show_popup?
    @show_popup
  end

  def completed?(pollen, nectar, elapsed_time)
    case @goal_type
    when :pollen
      pollen >= @goal_amount
    when :nectar
      nectar >= @goal_amount
    else
      false
    end
  end

  def failed?(elapsed_time)
    @time_limit && elapsed_time >= @time_limit
  end
end
