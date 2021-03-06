require 'date'

class Reservation
  attr_reader :check_in_date, :check_out_date, :dates_booked
  attr_accessor :id, :room_cost, :room_num

  def initialize(room_num, check_in_date, check_out_date, id: 0, room_cost: 200)
    @room_num = room_num
    @check_in_date = Date.parse(check_in_date)
    @check_out_date = Date.parse(check_out_date)
    raise ArgumentError, "invalid dates" if @check_in_date >= @check_out_date
    @dates_booked = date_range(check_in_date, check_out_date)
    @id = 0
    @room_cost = room_cost
  end

  def date_range(check_in_date, check_out_date)
    check_in_date = Date.parse(check_in_date)
    check_out_date = Date.parse(check_out_date)
    dates = []
    date = check_in_date
    while date < check_out_date
      dates << date
      date += 1
    end
    return dates
  end

  def length_of_stay
    duration = check_out_date - check_in_date
    return duration
  end

  def total_cost
    total = length_of_stay * @room_cost
    return total
  end
end
