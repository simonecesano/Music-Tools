use MP3::Tag;
use Getopt::Long::Descriptive;
use Data::Dump qw/dump/;
use Text::Unidecode;
use utf8;

$\ = "\n"; $, = "\t";

my ($opt, $usage) = 
    describe_options
    (
     "$0 %o <some-arg>",
     [ 'edits|e=s@', "edits to apply (i.e.: artist=s/foo/bar/i or *=s/bar/foo/)" ],
     [ 'unidecode', "unidecode output" ],
     [ 'cleanup', "cleanup tags" ],
     [],
     [ 'dryrun|y', "dry run" ],
     [],
     [ 'verbose|v',  "print extra stuff"            ],
    [ 'help',       "print usage message and exit" ],
    );

print($usage->text), exit if $opt->help;

my $file = $ARGV[0];

die "file $file does not exist" unless -f $file;

my $mp3 = MP3::Tag->new($ARGV[0]);
my $tags = $mp3->autoinfo;

print dump $tags if $opt->verbose;

my @tags = keys %$tags;

my @do = map { s/=/}=~/; '$tags->{' . $_ } grep { !/\*/ } @{$opt->edits};
push @do, map { s/\*=//; my $e = $_; map { '$tags->{' . $_ . '}=~' . $e } sort @tags } grep { /\*/ } @{$opt->edits};

eval for @do;

if ($opt->unidecode) { for (keys %$tags) {
    $tags->{$_} = unidecode($tags->{$_});
} }

if ($opt->cleanup) { for (keys %$tags) {
    $tags->{$_} =~ s/\?/ /g;
    $tags->{$_} =~ s/^\s|\s$//g;
    $tags->{$_} =~ s/ +/ /g;
} }

print dump $tags if $opt->verbose;

$mp3->update_tags($tags) unless $opt->dryrun;
