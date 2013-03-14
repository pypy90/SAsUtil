#!/usr/bin/perl -s

#Use to Position current work DIR
use Cwd;

ScanCoreFile('.');

sub ScanCoreFile {
    my $workdir = shift;
    my $startdir = cwd;
    
    chdir $workdir or die "can't enter dir $workdir: $!\n";
    opendir my $DIR, "." or die "can't open $workdir: $!\n";
    my @names = readdir $DIR or die "can't read $workdir: $!\n";
    
    foreach my $name (@names) {
        next if ($name eq '.');
        next if ($name eq '..');
        if (-d $name) {
            ScanCoreFile($name);
            next;
        }
        if ($name eq 'core') {
            if (defined $r) {
                unlink $name or die "can't delete $name: $!\n";
            }
            else {
                print "found one in $workdir!\n";
            }
        }
    }
    chdir $startdir or die "can't change to dir $startdir: $!\n";
}
