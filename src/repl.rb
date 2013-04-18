require 'lithp'
require 'reader'
require 'readline'

lisp = Lisp.new

if File.exist?("core.ulithp")
  source = File.open("core.ulithp", "r").read
  forms = Marshal.load(source)

  forms.each { |form| puts "#{form}" ; lisp.eval(form) }

  puts "Done loading core library containing #{forms.length} forms."
end

stty_save = `stty -g`.chomp
trap("INT") { system("stty", stty_save); exit }

while line = Readline.readline("ulithp> ", true)
  s_expression = Reader.new(line).read
  p lisp.eval(s_expression)
end
