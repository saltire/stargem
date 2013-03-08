require 'json'

require 'noun'
require 'room'


class Game
  attr_reader :controls
  
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
    
    def add_to_synonyms(words)
      words.each {|word| @synonyms[word] = @synonyms[word] | words}
    end
    
    @synonyms = Hash.new([])
    data['words'].each {|words| add_to_synonyms(words)}
    data['nouns'].each {|nid, noun| add_to_synonyms(noun['words']) if noun['words']}
  end
end


