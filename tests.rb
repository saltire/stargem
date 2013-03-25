class Tests
  
  def initialize(game)
    @game = game
  end
  
  def start?
    @game.turn_number == 1
  end
  
  def input?(*words)
    @game.input_match? words
  end
  
  def var?(vid, value)
    ['<', '>', '<=', '>='].each do |oper|
      if value[0..oper.length - 1] == oper
        return @game.vars[vid].send(oper, value[oper.length..-1].to_i)
      end
    end
    # no operator: assume ==
    @game.vars[vid] == value.to_i
  end
  
  def room?(rword)
    rword.split('|').any? {|rid| @game.current_room.id == rid}
  end
  
  def visited?(rword)
    rword.split('|').any? {|rid| @game.rooms[rid].visited?}
  end
  
  def exitexists?(dir)
    @game.current_room.exits.any? {|exitdir, dest| @game.words_match?(dir, exitdir)}
  end
  
  def carrying?
    !@game.nouns_at_loc(:inventory).empty?
  end
    
  def nounloc?(nword, rword)
    @game.match_nouns(nword).any? {|noun| rword.split('|').any? {|rid| @game.noun_at? noun, rid}}
  end
  
  def ininv?(nword)
    @game.match_nouns(nword).any? {|noun| @game.noun_at? noun, :inventory}
  end
  
  def worn?(nword)
    @game.match_nouns(nword).any? {|noun| @game.noun_at? noun, :worn}
  end
  
  def inroom?(nword)
    @game.match_nouns(nword).any? {|noun| @game.noun_at? noun, @game.current_room.id}
  end
  
  def present?(nword)
    @game.match_nouns(nword).any? {|noun| @game.noun_at? noun, @game.current_room.id, :inventory, :worn}
  end
  
  def contained?(nword)
    @game.match_nouns(nword).any? {|noun| !(@game.noun_locs(noun) & @game.nouns.keys).empty?}
  end
  
  def somewhere?(nword)
    @game.match_nouns(nword).any? {|noun| !@game.noun_locs(noun).empty?}
  end
  
  def movable?(nword)
    @game.match_nouns(nword).any? {|noun| noun.movable?}
  end
  
  def wearable?(nword)
    @game.match_nouns(nword).any? {|noun| noun.wearable?}
  end
  
  def hasdesc?(oword)
    @game.match_objects(oword).any? {|obj| obj.desc != ''}
  end
  
  def hasnotes?(oword)
    @game.match_objects(oword).any? {|obj| !obj.notes.empty?}
  end
  
  def hascontents?(oword)
    @game.match_objects(oword).any? {|obj| !@game.nouns_at_loc(obj.id).empty?}
  end
  
  def random(percent)
    rand * 100 < percent
  end
    
  
end