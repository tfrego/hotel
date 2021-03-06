require_relative 'reservation.rb'
require 'awesome_print'
require 'date'
require 'pry'

class BookingSystem
  attr_reader :num_rooms, :rooms, :reservations, :room_blocks

  def initialize()
    @num_rooms = 20
    @rooms = load_rooms
    @reservations = []
    @room_blocks = []
  end

  def load_rooms
    rooms =[]
    @num_rooms.times { |room| rooms << room + 1 }
    return rooms
  end

  # access the list of all of the rooms in the hotel
  def list_all_rooms
    return @rooms
  end

  # reserve a room for a given date range
  def reserve_room(check_in, check_out)
    dates = date_range(check_in, check_out)
    new_reservation = nil
    @rooms.each do |room|
      if is_available?(room, dates) && is_not_blocked?(room, dates)
        new_reservation = Reservation.new(room, check_in, check_out)
        new_reservation.id = assign_res_id
        @reservations << new_reservation
        break
      end
    end
    if new_reservation != nil
      return new_reservation
    else
      raise StandardError, 'no rooms available in date range'
    end
  end

  def is_available?(room, dates)
    reservations = @reservations.select { |reservation| reservation.room_num == room }
    reservations.each do |reservation|
      dates.each do |date|
        if reservation.dates_booked.include?(date)
          return false
        end
      end
    end
    return true
  end

  def is_not_blocked?(room, dates)
    room_blocks = @room_blocks.select { |block| block.collection_rooms.include?(room) }
    room_blocks.each do |block|
      dates.each do |date|
        if block.dates_booked.include?(date)
          return false
        end
      end
    end
    return true
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

  def assign_res_id
    return @reservations.count + 1
  end

  # access the list of reservations for a specific date
  def reservations_by_date(date)
    date = Date.parse(date)
    list_res = []
    @reservations.each do |reservation|
      if reservation.check_in_date <= date && reservation.check_out_date >= date
        list_res << reservation
      end
    end
    return list_res
  end

  # get the total cost for a given reservation
  def total_cost_of_reservation(res_id)
    if reservation = @reservations.find { |res| res.id == res_id}
      return reservation.total_cost
    else
      return nil
    end
  end

  # view a list of rooms that are not reserved for a given date range
  def unreserved_rooms_by_date(start_date, end_date)
    dates = date_range(start_date, end_date)
    dates << Date.parse(end_date)
    unreserved_rooms = []
    @rooms.each do |room|
      if is_available?(room, dates) && is_not_blocked?(room, dates)
        unreserved_rooms << room
      end
    end
    return unreserved_rooms
  end

  # create block of rooms
  def create_block_of_rooms(start_date, end_date, discounted_rate)
    dates = date_range(start_date, end_date)
    new_block = RoomBlock.new(start_date, end_date, room_cost: discounted_rate)
    new_block.id = assign_block_id

    num_of_rooms = 0
    @rooms.each do |room|
      if is_available?(room, dates) && is_not_blocked?(room, dates)
        new_block.add_room(room)
        num_of_rooms += 1
      end
      if num_of_rooms == 5
        break
      end
    end

    @room_blocks << new_block

    return new_block
  end

  def assign_block_id
    return @room_blocks.count + 1
  end

  # check if block of rooms has availability
  def block_available?(block_id)
    selected_block = @room_blocks.find { |block| block.id == block_id}
    dates = date_range("#{selected_block.check_in_date}", "#{selected_block.check_out_date}")

    selected_block.collection_rooms.each do |room_blocked|
      check_room = @rooms.find { |room| room == room_blocked }
      if is_available?(check_room, dates)
        return true
      end
    end
    return false
  end

  # # reserve a room from within a block of rooms
  def reserve_within_block(block_id)
    selected_block = @room_blocks.find { |block| block.id == block_id}
    new_reservation = nil
    dates = date_range("#{selected_block.check_in_date}", "#{selected_block.check_out_date}")

    selected_block.collection_rooms.each do |room_blocked|
      check_room = @rooms.find { |room| room == room_blocked }
      if is_available?(check_room, dates)
        new_reservation = Reservation.new(check_room, "#{selected_block.check_in_date}", "#{selected_block.check_out_date}")
        new_reservation.id = assign_res_id
        @reservations << new_reservation
        break
      end
    end

    if new_reservation != nil
      return new_reservation
    else
      raise StandardError, 'no rooms available in block'
    end
  end
end
