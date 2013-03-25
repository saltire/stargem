require 'set'

require 'noun'
require 'room'


class Game
  attr_reader :vars, :nouns, :rooms, :messages, :current_room, :gameover
  
  def initialize(data)
    def store_data(data_hash)
      data_hash.each_with_object({}) {|(id, dat), objs| objs[id] = yield(id, dat)}
    end    
    @vars = store_data(data['vars']) {|vid, val| val.to_i}
    @nouns = store_data(data['nouns']) {|nid, ndata| Noun.new(nid, ndata)}
    @rooms = store_data(data['rooms']) {|rid, rdata| Room.new(rid, rdata)}
    
    @messages = data['messages']

    @synonyms = Hash.new([])
    def add_to_synonyms(words)
      words.each {|word| @synonyms[word] = @synonyms[word] | words}
    end    
    data['words'].each {|words| add_to_synonyms(words)}
    data['nouns'].values.each {|noun| add_to_synonyms(noun['words']) if noun['words']}
      
    @current_room = @rooms.select {|rid, room| room.is_start?}.values.first
      
    @locations = @nouns.reduce(Set.new) do |locmap, (nid, noun)|
      locmap + noun.locs.map {|loc| [nid, loc]}
    end
    
    @turns = []
    @gameover = false
  end
  
  # turn management
  
  def start_turn(command)
    @turns << {:command => command, :output => []}
    set_words(command)
  end
  
  def set_words(words)
    @turns.last[:words] = words.split.reject {|word| %w(the an a).include? word}
  end
  
  def end_turn(actions)
    @turns.last[:actions] = actions
    @turns.last[:output]
  end
  
  def turn_number
    @turns.length
  end
  
  def end_game
    @gameover = true
  end
  
  # input word matching
  
  def sub_input_words(phrase)
    phrase.gsub(/%(\d+)/) {|index| @turns.last[:words][index.to_i - 1] || ''}
  end

  def words_match?(cword, words)
    words == '*' || words.split('|').any? do |word|
      @synonyms[word].include? sub_input_words(cword)
    end
  end
  
  def input_match?(iwords)
    cwords = @turns.last[:words]
    iwords.each_with_index.all? {|word, i| cwords[i] && words_match?(cwords[i], word)}
  end

  # object matching
  
  def match_nouns(nword)
    nword.split(',').reduce([]) do |nouns, nid|
      if @nouns[nid]
        nouns << @nouns[nid]
      else
        nouns + nouns_by_name(sub_input_words(nid))
      end
    end
  end
  
  def match_objects(oword)
    oword == '%ROOM' ? [@current_room] : (match_nouns(oword) || [@rooms[oword]])
  end
  
  # message queueing
  
  def queue_output(*messages)
    @turns.last[:output] += messages.each do |msg|
      unless msg == :pause
        msg.gsub!(/%VAR\((.+)\)/) {|m| @game.vars[$1]}
        msg.gsub! '%TURNS', turn_number.to_s
        sub_input_words msg
      end
    end
  end
  
  def queue_message(*mids)
    queue_output *mids.map {|mid| @messages[mid]}
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
    @vars[vid] = value.to_i
  end
  
end
