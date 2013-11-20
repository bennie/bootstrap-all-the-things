#!/usr/bin/env ruby 

require "highline/import"

## Gather username, password and input filename

username = ARGV[0]
password = ARGV[1]
filename = ARGV[2]

filename = ask('Filename: ') unless filename;
abort("#{filename} is not a file") unless File.exist?(filename)

username = ask('Username: ') unless username;

while not password
	input1 = ask('Password: ') { |q| q.echo = '*' };
	input2 = ask('Password Confirmation: ') { |q| q.echo = '*' };
	password = input1 if input1 == input2
end

### Read in the input file

check = Array.new

File.open(filename).each do |line|
	line.chomp

	abort("Badly formatted line in file: #{line}") unless line =~ /^(.+?),(.+)$/

	name = $1
	fqdn = $2

	command = 'echo knife bootstrap '       \
			+ fqdn                     \
			+ ' -N ' + name            \
			+ ' --template macys.erb ' \
			+ ' -x ' + username        \
			+ ' -P ' + password        \
			+ ' -r "role[base]" '      \
			+ ' --sudo --use-sudo-password'

	system(command)

	ret = $?.exitstatus

	warn "The bootstrap of node '#{name}' had an error. (Return code: #{ret})" if ret != 0

	check.push(name).push(ret)	
end

