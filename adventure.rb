require 'game'

require 'tests'
require 'actions'


class Adventure
  include Tests
  include Actions

  def initialize(path)
    @game = Game.new(path)
    @turns = []
      
  end
  
  
  def do_command(command)
    actions = get_command_actions(command)
    p actions
    @turns << [command, actions]
    
  end
  
  
  def get_command_actions(command)
    @words = command.split.reject {|word| %w(the an a).include? word}
    actions = []

    @game.controls.each do |cset|
      # get all actions in the set
      set_actions = cset.reduce([]) {|all, c| all.concat get_control_actions(c, @words)}
      set_actions.each do |action, params|
        # add actions to the queue, testing for special conditions
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
        # return only the replacement
        actions << [:replace, control['replace']]
        return actions
      end
      
      control['then'].each do |action|
        if action.is_a? Hash
          # this is another cond block, so get append actions from it recursively
          actions.concat get_control_actions(action, words)
        else
          # append action and parameters
          action, params = action.split(' ', 2)
          actions << [action.to_sym, params ? params.split : []]
        end
      end
      
      if control['done']
        actions << :done
      end
      if control['gameover']
        actions << :gameover
      end
      
    end
    actions
  end
  
    
  def test_is_true?(test)
    if test.all? {|subtest| subtest.is_a? String}
      # if all subtests are strings, i.e. conds, they must all pass
      test.all? {|subtest| cond_is_true? subtest}
        
    else
      # if some/all subtests are arrays, i.e. further tests, then any can pass
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
    method, *params = cond.split
    method, neg = method[0] == '!' ? [method[1..-1], true] : [method, false]
    
    #p method, params, self.send(method + '?', *params)
    self.send(method + '?', *params) ^ neg
  end
  
  
  def match_word(iword, word)
    word == '*' || word.split('|').any? {|w| @game.synonyms[w].include? iword}
  end
  
  def match_nouns(nword)
    if /%(\d+)/.match(nword)
      # substitute numbered wildcard for that word in command
      @game.nouns_by_name(@words[$1.to_i])
    else
      nword.split(',').map {|nid| @game.nouns[nid]}
    end
  end
  
end