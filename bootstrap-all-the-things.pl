#!/usr/bin/perl

use Term::Prompt;
use strict;

## Gather username, password and input filename

my $username = $ARGV[0];
my $password = $ARGV[1];
my $filename = $ARGV[2];

$filename = prompt('x','Filename:', '', "$filename" ) unless $filename;
die "$filename is not a file.\n" unless -f $filename;

$username = prompt('x','Username:', '', "$username" ) unless $username;

while ( not $password ) {
  my $try1 = prompt('p','Password:', '', "$password" );
  print "\n";
  my $try2 = prompt('p','Password Confirmation:', '', "$password" );
  print "\n";

  $password = $try1 if $try1 eq $try2;
}

my $handle;
open $handle, '<', $filename;

### Read in the input file

my @check;

while ( my $line = <$handle> ) {
  chomp $line;

  die "Badly formatted line in file: $line\n" unless $line =~ /^(.+?),(.+)$/;
  my $name = $1; my $fqdn = $2;

  my $command = 'knife bootstrap ' 
              . $fqdn
              . ' -N ' .  $name
              . ' --template macys.erb '
              . ' -x ' . $username
              . ' -P ' . $password
              . ' -r "role[base]" '
              . ' --sudo --use-sudo-password'
              . "\n";

  my $display = $command;
  $display =~ s/-P $password/-P \*\*\*\*\*\*\*\*/;

  print "\n==> Executing command: [ $display ]\n";

  system($command);
  my $ret = $? >> 8;

  warn "The bootstrap of node '$name' had an error. (Return code: $ret)\n" unless $ret == 0;
  push @check, [ $name, $ret ];
}

### Verify bootstraps

my $count = scalar(@check);
print "\n\n\nVerifying that all $count servers were bootstrapped.\n";

my $list = `knife node list`;
my @list = split "\n", $list;

my %nodes;
for my $node (@list) { $nodes{$node}++ if length $node; }

print "Found ", scalar(keys %nodes), " nodes on the chef server.\n\n";

for my $check (@check) {
  my $ok = defined $nodes{$check->[0]} ? 'ok' : 'NOT PRESENT ('.$check->[1].')';
  print "$check->[0] : [ $ok ]\n";
}
