#!/opt/local/bin/perl
use File::Copy;
use File::Basename;
use Getopt::Std;

my %opt;
getopts('fyv', \%opt);

# -y : dry run
# -f : force clobbering of newer file
# -v : verbose

$\ = "\n"; $, = "\t";

my $script = $ARGV[0];
my $dir    = $ARGV[1];

die "need a file name" unless $script;
die "cannot find file $script" unless -f $script;
die "cannot find directory $dir" unless -d $dir;

my $cmd = $script =~ s/\.\w+$//r;
if ($dir) {
    $dir =~ s/\/$//;
    $cmd = basename($cmd);
    $cmd = "$dir/$cmd"
}

print STDERR $script, $cmd if $opt{v};
exit if $opt{y};


# need to check if the script is newer than the command;
if ((!$opt{f}) && ((-M $script) >= (-M $cmd)))  { die "script is not newer than command"; }
my $utime = ${[ stat($script) ]}[9];

copy($script, $cmd);
utime $utime, $utime, $cmd;
chmod 0755, $cmd;
