#!/usr/bin/perl -w

use strict;


my $passwd = "/etc/passwd";
my $maxUid = 0;

open my($fh),"$passwd" or die "can't open $passwd: $!\n";

while (<$fh>) {
    chomp;
    my @field = split(/:/);
    $maxUid = ($maxUid < $field[2]) ? $field[2] : $maxUid;
}

close($fh);


print 'The next avaiable UID is ' . ++$maxUid . "\n";
