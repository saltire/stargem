require 'json'

#require 'game'


class Adventure
  
  def initialize(path, state=nil)
    data = File.open(path, 'rb') {|file| JSON.parse(file.read) }
    
    @controls = data['controls']
    @messages = data['messages']
    
    #@game = Game(data, state)
    
    @synonyms = Hash.new([])
      
    add_to_synonyms
      
    data['words'].each do |words|
      words.each do |word|
        @synonyms[word] = @synonyms[word] | words
      end
    end
    
    data['nouns'].each do |noun|
      words = noun['words']
      words.each do |word|
        @synonyms[word] = @synonyms[word] | words
      end
    end
    
    puts @synonyms
      
  end
  
  def do_command(command='')
    status = 'Nothing happens.'
  end
  
end
