require 'adventure'
 

adv = Adventure.new('starflight.json')

command = ''
while true
  status = adv.do_command(command)
  puts status

  print '> '
  command = gets.chomp
end
