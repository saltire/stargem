class Turn
  def initialize(game)
    @game = game
  end
  
  
  def get_command_actions(command)
    words = command.split.reject {|word| %w(the an a).include? word}
    actions = []

    @game.controls.each do |cset|
      set_actions = cset.reduce([]) {|all, c| all.concat get_control_actions(c, words)}
      set_actions.each do |action, params|
        case action
        when :replace then return get_command_actions(params)
        when :gameover then return actions
        when :done then break
        else actions << [action, params]
        end
      end
    end
    
    actions
  end

  
  def get_control_actions(control, words)
    actions = []
    if test_is_true? control['if']
      
      if control['replace']
        actions << [:replace, control['replace']]
        return actions
      end
      
      control['then'].each do |action|
        if action.is_a? Hash
          actions.concat get_control_actions(action, words)
        else
          action, params = action.split(' ', 2)
          actions << [action.to_sym, params ? params.split : []]
        end
      end
      
      if control['done']
        actions << :done
      end
      if control['gameover']
        actions << :gameover
        return actions
      end
      
    end
    actions
  end

    
  def test_is_true?(test)
    if test.all? {|subtest| subtest.is_a? String}
      test.all? {|subtest| cond_is_true? subtest}
        
    else
      test.any? do |subtest|
        if subtest.is_a? String
          cond_is_true? subtest
        else
          test_is_true? subtest
        end
      end
    end
  end

    
  def cond_is_true?(cond)
    true
  end
  
end