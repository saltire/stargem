require 'noun'
require 'room'


class Game
  def initialize(data, state=nil)
    
    if !state
      def store_data(data_hash)
        data_hash.each_with_object({}) {|(id, dat), objs| objs[id] = yield(id, dat)}
      end
      
      @vars = store_data(data['vars']) {|vid, val| val.to_i}
      @nouns = store_data(data['nouns']) {|nid, ndata| Noun.new(nid, ndata)}
      @rooms = store_data(data['rooms']) {|rid, rdata| Room.new(rid, rdata)}
      
      @turn = 0
      @current_room = @rooms.select {|rid, room| room.is_start?}.values.first
  
      @current_room.visit
      
    else
      # init data from state object
    end
    
  end
end