module Tests
  
  def start?
    @turns.length == 0
  end
  
  def input?(*words)
    words == @words
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
    rword.split('|').any? {|rid| @game.current_room == rid}
  end
  
end