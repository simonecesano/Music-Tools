#!/Users/cesansim/perl5/perlbrew/perls/perl-5.18.2/bin/perl

use strict;
use Getopt::Std;

# should have options for:
# - just printing the id      -I
# - skipping the unmounting   -U
# - skipping the eject        -E
# - only ejecting             -e

$\ = "\n";

my %opt;
getopts('IUEe', \%opt);

if ($opt{h}) {
    print <<EOF
# - just printing the id      -I
# - skipping the unmounting   -U
# - skipping the eject        -E
# - only ejecting             -e
EOF
	;
    exit;
}

if ($opt{e}) { print qx/drutil eject external/; exit };

my ($cdid, $cddev);
unless ($opt{U}) {
    my $passwd = qx/security find-generic-password -ws Exchange 2>&1/; $passwd =~ s/\s*$//;
    ($cddev) = map { /(.+?) on/; $1 } grep { /Audio CD|cddafs/ } split /\n/, qx/mount/;
    die "could not find a cd" unless $cddev;
    print "unmounting $cddev";
    qx(echo $passwd | sudo -S umount "$cddev") if $cddev;
    sleep 1;
}

{
    $cdid = shift @{[split /\s+/, qx/cd-discid "$cddev"/]};
    print "cd id is $cdid";
    die "cd-discid failed" unless $cdid;
    exit if $opt{I};
}

{
    mkdir $cdid unless -d $cdid; chdir $cdid;
    my $count = pop @{[ map { /\s*(\d+)/, $1 } grep { /^\s*\d+\./ } split /\n/, qx/cdparanoia -Q 2>&1/]};
    print "cd contains $count tracks";
    print qx/cdparanoia -B/;
    print qx/drutil eject external/ unless $opt{E};
}
