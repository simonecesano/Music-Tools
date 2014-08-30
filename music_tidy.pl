#!/Users/cesansim/perl5/perlbrew/perls/perl-5.18.2/bin/perl

use MP3::Tag;
use Getopt::Long::Descriptive;
use Path::Tiny;
use utf8;
use Text::Unidecode;

my ($opt, $usage) = describe_options(
    "$0 %o <some-arg>",
    [ 'format|f=s',   "path format" ],
    [ 'root|r=s',   "root directory" ],
    [ 'lc|l',   "convert to lowercase" ],
    [ 'spaces|s',   "convert spaces to underscores" ],
    [],
    [ 'dryrun|y',   "dry run" ],
    [ 'copy|c',   "copy instead of moving" ],
    [],
    [ 'verbose|v',  "print extra stuff"            ],
    [ 'help|h',       "print usage message and exit" ],
  );

print($usage->text), exit if $opt->help;

$\ = "\n"; $, = "\t";

my $file = $ARGV[0];

die "could not find file $file" unless -f $file;
die "root directory does not exist" unless -d $opt->root;

$mp3 = MP3::Tag->new($file)->autoinfo;
($mp3->{format}) = ($file =~ /\.(\w{3,4})$/); 
(undef, $mp3->{initial}) = ($mp3->{artist} =~ /(the\s)*(\w)/i); 

#---------------------
# parameter munging
#---------------------
my ($fmt, @data) = split /::|,/, $opt->format;
for (@data) { die "tag \"$_\" not found in file $file" unless $mp3->{$_} };
@data = @{$mp3}{@data};

#------------------
# and checking 
#------------------
die sprintf("something's not ok: %d placeholders and %d tags", length($fmt =~ s/[^%]//gr), (scalar @data))
    if (length($fmt =~ s/[^%]//gr) != (scalar @data));

#------------------
# process tags
#------------------
@data = map { unidecode($_) } @data; 
@data = map { lc } @data if $opt->lc;
@data = map { s/\s/_/g; $_ } @data if $opt->spaces;

#----------------------
# actually do the job
#----------------------
my $root = $opt->root; $root .= '/' unless $root =~ /\/$/;
print "copy $file to $path" if ($opt->dryrun || $opt->verbose);

unless ($opt->dryrun) {
    my $path = path($opt->root . (sprintf $fmt, @data))->touchpath;
    if ($opt->copy) {
	path($file)->copy($path) 
    } else { 
	path($file)->move($path) 
    }
}
