require 'json'

require 'game'


class Adventure
  
  def initialize(path, state=nil)
    data = File.open(path, 'rb') {|file| JSON.parse(file.read) }
    
    @controls = data['controls']
    @messages = data['messages']
    
    @game = Game.new(data, state)
    
    @synonyms = Hash.new([])
      
    def add_to_synonyms(words)
      words.each {|word| @synonyms[word] = @synonyms[word] | words}
    end
    
    data['words'].each {|words| add_to_synonyms(words)}
    data['nouns'].each {|nid, noun| add_to_synonyms(noun['words']) if noun['words']}
      
  end
  
  def do_command(command='')
    status = 'Nothing happens.'
  end
  
end
