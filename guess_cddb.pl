#!/Users/cesansim/perl5/perlbrew/perls/perl-5.18.2/bin/perl

use CDDB::File;
use File::Slurp qw/read_file/;
use Path::Class qw(dir);
use Getopt::Std;
use Parallel::ForkManager;
use LWP::Simple qw/get/;

getopts('v');


$\ = "\n"; $, = "\t";

my $cdid = $ARGV[0];
my $genre = $ARGV[1];

die "need a cdid" unless $cdid;
die "$cdid doesn't look like a cdid" unless ($cdid =~ /(?=.*[a-z0-9]{8,8})(?=.*[a-z])(?=.*[0-9])/i);


if (-d $cdid) {
    my $dir = dir($cdid);
    ($cdid) = $dir->dir_list(-1, 1)
}

my ($count, @found);

unless ($genre) {
    $pm = Parallel::ForkManager->new($MAX_PROCESSES);
    
    print "$cdid could be:";
    
    for my $genre (qw/rock blues classical country data folk jazz newage reggae soundtrack misc/) {
	my $pid = $pm->start and next;
	my $url = sprintf 'http://www.freedb.org/freedb/%s/%s', $genre, $cdid;
	
	if ($cddb = get($url)) {
	    $disc = CDDB::File->new_from_string($cddb);
	    print $disc->artist, $disc->title, $disc->genre, $disc->year, $url;
	    $count++;
	    push @found, $url;
	}
	$pm->finish; # Terminates the child process
    }
    $pm->wait_all_children;
    print "found $count";
    # if ($found == 1) {
    # 	my $url = sprintf 'http://www.freedb.org/freedb/%s/%s', $genre, $cdid;
    # 	if ($cddb = get($url)) {
    # 	    open my $fh, '>', "$cdid.cddb";
    # 	    print $fh $cddb;
    # 	}
    # }
    exit;
} else {
    my $url = sprintf 'http://www.freedb.org/freedb/%s/%s', $genre, $cdid;
    if ($cddb = get($url)) {
	open my $fh, '>', "$cdid.cddb";
	print $fh $cddb;
    }
}    


sub CDDB::File::new_from_string {
  my ($class, $data) = @_;

  chomp(my @data = split /\n/, $data);
  bless {
    _data => \@data,
  }, $class;
}

__DATA__
rock
blues
classical
country
data
folk
jazz
newage
reggae
soundtrack
misc
