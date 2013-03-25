require 'json'

require 'game'
require 'tests'
require 'actions'


class Adventure
  def initialize(path)
    data = File.open(path, 'rb') {|file| JSON.parse(file.read) }
    
    @controls = data['controls']
    
    @game = Game.new data
    @tests = Tests.new @game
    @actions = Actions.new @game
  end
  
  
  def do_command(command)
    @game.start_turn(command)
    actions = do_command_actions(command)
    output = @game.end_turn actions
  end
  
  
  def do_command_actions(command)
    @game.set_words(command)
    actions = []
      
    @controls.each do |cset|
      csactions = []

      cset.each do |control|
        done = false
        get_control_actions(control).each do |action, params|
          # add actions to the queue, testing for special conditions
          case action
          when :replace
            print '-----REPLACING WITH: '
            puts @game.sub_input_words(params)
            return do_command_actions(@game.sub_input_words(params))
          #when :replace then return get_command_actions(@game.sub_input_words(params))
          when :gameover
            done = true
            @game.end_game
            break
          when :done
            done = true
            break
          else
            csactions << [action, params]
            actions << [action, params]
            p [action, params]
          end
        end
        break if done
      end
      
      # execute actions for this control set
      csactions.each {|(action, params)| @actions.send action, *params}
      break if @game.gameover
    end
    
    actions
  end
  

  def get_control_actions(control)
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
          actions += get_control_actions(action)
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
    print cond + ': '
    
    method, *params = cond.split
    method, neg = method[0] == '!' ? [method[1..-1], true] : [method, false]
    
    puts @tests.send(method + '?', *params) ^ neg
    @tests.send(method + '?', *params) ^ neg
  end
  
  
  def game_over?
    @game.gameover
  end
  
end