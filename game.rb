require 'json'

require 'noun'
require 'room'


class Game
  attr_reader :controls, :messages, :vars, :nouns, :rooms, :current_room, :synonyms
  
  def initialize(path)
    data = File.open(path, 'rb') {|file| JSON.parse(file.read) }
    
    @controls = data['controls']
    @messages = data['messages']
    
    def store_data(data_hash)
      data_hash.each_with_object({}) {|(id, dat), objs| objs[id] = yield(id, dat)}
    end
    
    @vars = store_data(data['vars']) {|vid, val| val.to_i}
    @nouns = store_data(data['nouns']) {|nid, ndata| Noun.new(nid, ndata)}
    @rooms = store_data(data['rooms']) {|rid, rdata| Room.new(rid, rdata)}
    
    @current_room = @rooms.select {|rid, room| room.is_start?}.values.first

    def add_to_synonyms(words)
      words.each {|word| @synonyms[word] = @synonyms[word] | words}
    end
    
    @synonyms = Hash.new([])
    data['words'].each {|words| add_to_synonyms(words)}
    data['nouns'].each {|nid, noun| add_to_synonyms(noun['words']) if noun['words']}
      
  end
  
  def nouns_by_name(*nwords)
    @nouns.select {|nid, noun| !(noun.words & nwords).empty?}.values
  end
  
  def nouns_by_loc(*oids)
    @nouns.select {|nid, noun| !(noun.locs & oids).empty?}.values
  end
  
  def nouns_present
    nouns_by_loc(@current_room.id, :inventory, :worn)
  end
  
end
