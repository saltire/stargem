module Tests
  
  def start?
    @turns.length == 0
  end
  
  def input?(*words)
    words.each_with_index.map {|word, i| @words[i] && match_word(@words[i], word)}.all?
  end
  
  def var?(vid, value)
    ['<', '>', '<=', '>='].each do |oper|
      if value[0..oper.length - 1] == oper
        return @game.vars[vid].send(oper, value[oper.length..-1].to_i)
      end
    end
    # no operator: assume ==
    @game.vars['vid'] == value.to_i
  end
  
  def room?(rword)
    rword.split('|').any? {|rid| @game.current_room.id == rid}
  end
  
  def visited?(rword)
    rword.split('|').any? {|rid| @game.rooms['rid'].visited?}
  end
  
  def exitexists?(dir)
    @game.current_room.exits.any? {|exitdir, dest| match_word(dir, exitdir)}
  end
  
  def carrying?
    !nouns_at_loc(:inventory).empty?
  end
    
  def nounloc?(nword, rword)
    match_nouns(nword).any? {|noun| rword.split('|').any? {|rid| noun_at? noun.id, rid}}
  end
  
  def ininv?(nword)
    match_nouns(nword).any? {|noun| noun_at? noun.id, :inventory}
  end
  
  def worn?(nword)
    match_nouns(nword).any? {|noun| noun_at? noun.id, :worn}
  end
  
  def inroom?(nword)
    match_nouns(nword).any? {|noun| noun_at? noun.id, @game.current_room.id}
  end
  
  def present?(nword)
    !(match_nouns(nword) & @game.nouns_present).empty?
  end
  
  def contained?(nword)
    match_nouns(nword).any? {|noun| !(noun_locs(noun.id) & @game.nouns.keys).empty?}
  end
  
  def somewhere?(nword)
    match_nouns(nword).any? {|noun| !noun_locs(noun.id).empty?}
  end
  
  def movable?(nword)
    match_nouns(nword).any? {|noun| noun.movable?}
  end
  
  def wearable?(nword)
    match_nouns(nword).any? {|noun| noun.wearable?}
  end
  
  def hasdesc?(oword)
    match_objects(oword).any? {|obj| obj.description != ''}
  end
  
  def hasnotes?(oword)
    match_objects(oword).any? {|obj| !obj.notes.empty?}
  end
  
  def hascontents?(oword)
    match_objects(oword).any? {|obj| !@game.nouns_at_loc(obj.id).empty?}
  end
  
  def random(percent)
    rand * 100 < percent
  end
    
  
end