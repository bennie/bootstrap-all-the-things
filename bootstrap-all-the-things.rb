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
