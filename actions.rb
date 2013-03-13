module Actions
  def show_contents(oid, contains_msg=nil, by_name=false, recursive=true, indent=0)
    @game.nouns_at_loc(oid).select {|noun| noun.visible?}.each do |noun|
      queue_output  "\t" * indent + by_name ? noun.name : noun.description
      if recursive && @game.has_contents?(noun.id)
        if contains_msg
          queue_message contains_msg.gsub(/^/, "\t" * (indent + 1)).gsub('%NOUN', noun.short_name)
        end
        show_contents noun.id, contains_msg, by_name, true, indent + 1
      end
    end
  end
  
  def message(mid)
    queue_message mid
  end
  
  def pause
    queue_output :pause
  end
  
  def showdesc(oword)
    match_objects(oword).each {|obj| queue_output obj.description}
  end
  
  def shownotes(oword)
    match_objects(oword).each {|obj| queue_message obj.notes}
  end
  
  def showcontents(oword, contains_msg=nil, by_name=false, recursive=true)
    match_objects(oword).each {|obj| show_contents(obj.id, contains_msg, by_name, recursive)}
  end
  
  def listcontents(oword, recursive=true)
    showcontents(oword, by_name=true, recursive=recursive)
  end
  
  def inv(carry_msg, wear_msg=nil, contains_msg=nil, recursive=true)
    inv = @game.nouns_by_loc(:inventory, :worn)
    if inv.empty?
      # change api to add not-carrying message
    else
      inv.each do |noun|
        msg = wear_msg && noun_at(noun.id, :worn) ? wear_msg : carry_msg
        queue_message msg.gsub('%NOUN', noun.name)
        if contains_msg && @game.has_contents?(noun.id)
          queue_message contains_msg.gsub(/^/, "\t" * (indent + 1)).gsub('%NOUN', noun.short_name)
          show_contents noun.id, contains_msg, by_name=true, indent=1
        end
      end
    end
  end
  
  def move(dir)
    rid = @game.current_room.exits.select {|exitdir, dest| match_word(dir, exitdir)}.values.first
    @game.go_to_room rid if rid
  end
  
  def destroy(nword)
    match_nouns(nword).each {|noun| destroy_noun noun.id}
  end
  
  
  
end