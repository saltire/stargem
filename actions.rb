class Actions
  
  def initialize(game)
    @game = game
  end
  
  def _show_contents(oid, contains_msg=nil, by_name=false, recursive=true, indent=0)
    @game.nouns_at_loc(oid).select {|noun| noun.visible?}.each do |noun|
      @game.queue_output  "\t" * indent + by_name ? noun.name : noun.desc
      if recursive && @game.has_contents?(noun.id)
        if contains_msg
          @game.queue_message contains_msg.gsub(/^/, "\t" * (indent + 1)).gsub('%NOUN', noun.shortname)
        end
        _show_contents noun.id, contains_msg, by_name, true, indent + 1
      end
    end
  end
  
  def message(mid)
    @game.queue_message mid
  end
  
  def pause
    @game.queue_output :pause
  end
  
  def showdesc(oword)
    @game.match_objects(oword).each {|obj| @game.queue_output obj.desc}
  end
  
  def shownotes(oword)
    @game.match_objects(oword).each {|obj| @game.queue_message *obj.notes}
  end
  
  def showcontents(oword, contains_msg=nil, by_name=false, recursive=true)
    @game.match_objects(oword).each {|obj| _show_contents(obj.id, contains_msg, by_name, recursive)}
  end
  
  def listcontents(oword, recursive=true)
    showcontents(oword, by_name=true, recursive=recursive)
  end
  
  def inv(carry_msg, wear_msg=nil, contains_msg=nil, recursive=true)
    inv = @game.nouns_at_loc(:inventory, :worn)
    if inv.empty?
      # change api to add not-carrying message
    else
      inv.each do |noun|
        msg = wear_msg && @game.noun_at?(noun, :worn) ? wear_msg : carry_msg
        @game.queue_message msg.gsub('%NOUN', noun.name)
        if recursive && @game.has_contents?(noun)
          if contains_msg
            @game.queue_message contains_msg.gsub(/^/, "\t" * (indent + 1)).gsub('%NOUN', noun.shortname)
          end
          _show_contents noun.id, contains_msg, by_name=true, indent=1
        end
      end
    end
  end
  
  def move(dir)
    rid = @game.current_room.exits.select {|exitdir, dest| @game.words_match?(dir, exitdir)}.values.first
    @game.go_to_room rid if rid
  end
  
  def destroy(nword)
    @game.match_nouns(nword).each {|noun| @game.destroy_noun noun}
  end
  
  def sendnoun(nword, rword)
    @game.match_nouns(nword).each {|noun| @game.move_noun noun, rword.split(',')}
  end
  
  def sendtoroom(nword)
    @game.match_nouns(nword).each {|noun| @game.move_noun noun, @game.current_room}
  end
  
  def sendtoinv(nword)
    @game.match_nouns(nword).each {|noun| @game.move_noun noun, :inventory}
  end
  
  def wear(nword)
    @game.match_nouns(nword).each {|noun| @game.move_noun noun, :worn}
  end
  
  def sendtonounloc(nword, d_nword)
    locs = @game.match_nouns(d_nword).reduce([]) {|locs, d_noun| locs + @game.noun_locs(d_noun)}
    @game.match_nouns(nword).each {|noun| @game.move_noun noun, *locs}
  end
  
  def sendtonoun(nword, d_nword)
    locs = @game.match_nouns(d_nword).each {|d_noun| d_noun.id}
    @game.match_nouns(nword).each {|noun| @game.move_noun noun, *locs}
  end
  
  def swapnouns(nword1, nword2)
    nouns1 = @game.match_nouns(nword1)
    nouns2 = @game.match_nouns(nword2)
    locs1 = nouns1.each {|noun1| @game.noun_locs noun1}
    locs2 = nouns2.each {|noun2| @game.noun_locs noun2}
    nouns1.each {|noun| @game.move_noun noun, *locs2}
    nouns2.each {|noun| @game.move_noun noun, *locs1}
  end
  
  def setnoundesc(nword, mid)
    @game.match_nouns(nword).each {|noun| noun.desc = @game.messages[mid]}
  end
  
  def addnounnote(nword, mid)
    @game.match_nouns(nword).each {|noun| noun.notes << mid}
  end
  
  def removenounnote(nword, mid)
    @game.match_nouns(nword).each {|noun| noun.notes.delete mid}
  end
  
  def clearnounnotes(nword)
    @game.match_nouns(nword).each {|noun| noun.notes.clear}
  end
  
  def setroomdesc(rword, mid)
    rword.split(',').each {|rid| @game.rooms[rid].desc = @game.messages[mid]}
  end
  
  def addroomnote(rword, mid)
    rword.split(',').each {|rid| @game.rooms[rid].notes << mid}
  end
  
  def removeroomnote(rword, mid)
    rword.split(',').each {|rid| @game.rooms[rid].notes.delete mid}
  end
  
  def clearroomnotes(rword)
    rword.split(',').each {|rid| @game.rooms[rid].notes.clear}
  end
  
  def setvar(vid, value)
    @game.set_var vid, value
  end
  
  def adjustvar(vid, value)
    if ['+', '-', '*', '/'].include? value[0]
      @game.set_var vid, @game.vars[vid].send(value[0], value[1..-1].to_i)
    end
  end

end