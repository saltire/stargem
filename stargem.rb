require 'adventure'
 

adv = Adventure.new('starflight.json')

command = ''
while true
  output = adv.do_command(command)
  #puts output

  print '> '
  command = gets.chomp
end
