if __FILE__ == $0
  require 'adventure'
  
  adv = Adventure.new('starflight.json')
  
  while true
    print '> '
    status = adv.do_command(gets.chomp)
    puts status
  end
end
