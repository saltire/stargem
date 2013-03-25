require 'adventure'
 

adv = Adventure.new('starflight.json')

do_message = lambda do |message|
  if message == :pause
    puts "  Press Enter to continue..."
    gets
  else
    puts message
  end
end

adv.do_command('').each &do_message

while !adv.game_over?
  print '> '
  adv.do_command(gets.chomp).each &do_message
end
