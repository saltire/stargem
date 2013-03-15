require 'set'

require 'noun'
require 'room'


class Game
  attr_reader :vars, :nouns, :rooms, :current_room, :turns
  
  def initialize(var_data, noun_data, room_data)
    def store_data(data_hash)
      data_hash.each_with_object({}) {|(id, dat), objs| objs[id] = yield(id, dat)}
    end
    
    @vars = store_data(var_data) {|vid, val| val.to_i}
    @nouns = store_data(noun_data) {|nid, ndata| Noun.new(nid, ndata)}
    @rooms = store_data(room_data) {|rid, rdata| Room.new(rid, rdata)}
      
    @current_room = @rooms.select {|rid, room| room.is_start?}.values.first
      
    @locations = @nouns.reduce(Set.new) do |locmap, (nid, noun)|
      locmap + noun.locs.map {|loc| [nid, loc]}
    end
    
    @turns = []
  end
  
  def save_turn(command, actions, output)
    @turns << [command, actions, output]
  end
  
  # room actions
  
  def go_to_room(rid)
    @current_room = @rooms[rid]
    @current_room.visit
  end
  
  # noun queries
  
  def nouns_by_name(*nwords)
    @nouns.values.select {|noun| !(noun.words & nwords).empty?}
  end
  
  def noun_locs(noun)
    @locations.select {|(nid, oid)| noun.id == nid}.map {|(nid, oid)| oid}
  end
  
  def nouns_at_loc(*oids)
    @locations.select {|(nid_, oid)| oids.include? oid}.map {|(nid, oid)| @nouns[nid]}
  end
  
  def noun_at?(noun, *oids)
    !(noun_locs(noun) & oids).empty?
  end
  
  def has_contents?(*oids)
    !nouns_at_loc(*oids).empty?
  end
  
  # noun actions
  
  def add_noun(noun, *oids)
    oids.each {|oid| @locations << [noun.id, oid]}
  end
  
  def remove_noun(noun, *oids)
    oids.each {|oid| @locations.delete [noun.id, oid]}
  end
  
  def destroy_noun(noun)
    @locations.select! {|(nid, oid)| noun.id != nid}
  end
  
  def move_noun(noun, *oids)
    destroy_noun(noun)
    add_noun(noun, *oids)
  end
  
  # var actions
  
  def set_var(vid, value)
    @vars[vid] = value
  end
  
end
