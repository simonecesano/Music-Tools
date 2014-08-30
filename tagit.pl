#!/Users/cesansim/perl5/perlbrew/perls/perl-5.18.2/bin/perl

use MP3::Tag;
use CDDB::File;
use Getopt::Long::Descriptive;

use Data::Dump qw/dump/;

use strict;
use Carp;

$\ = "\n"; $, = "\t";

my ($opt, $usage) = 
    describe_options
    (
     "$0 %o <text-file or sqlite-db>",
     ['cddb|c:s', 'cddb file'],
     [],
     ['genre|g:s', 'genre'],
     ['artist|a:s', 'artist'],
     ['title|t:s', 'album title'],
     [],
     [ 'verbose|v',  "print extra stuff"            ],
     [ 'help|h',       "print usage message and exit" ],
    );

print($usage->text), exit if $opt->help;

$\ = "\n";

my @argv = @ARGV;

my ($dir, @files);

if (-d $argv[0]) {
    $dir = $argv[0];
    opendir(DIR, "$dir") || die "Can't open directory $dir: $!\n";
    @files = grep { -f } map { "$dir/$_" } readdir(DIR);
} else {
    @files = @argv;
}

my $cddb = $opt->cddb ? $opt->cddb : "$dir.cddb";
croak "no cddb file" unless -f $cddb;

$cddb = CDDB::File->new($cddb);
my $tracks = { map { 
    my $t; 
    @{$t}{qw/album title artist genre/} = ($opt->title || $cddb->title, $_->title, $opt->artist || $cddb->artist, $opt->genre || $cddb->genre); 
    (sprintf"%02d", $_->number) => $t 
} $cddb->tracks };

my $files; do { /(\d+)\./; push @{$files->{$1}}, $_ } for @files;

for my $f (sort keys $files) {
    my @files = @{ $files->{$f} };

    for my $file (@files) {
	next if $file =~ /wav/;
	print $file if $opt->verbose; 
	my ($track) = ($file =~ /track(\d\d)/);
	my ($atime, $mtime, $ctime) = (stat($file))[8,9,10];
	my $mp3 = MP3::Tag->new($file);
	
	for (qw/album title artist genre/) {
	    my $tag = $tracks->{$f}->{$_};
	    my $sub = $_ . '_set';
	    $mp3->$sub($tag);
	}
	$mp3->track_set($track);
	print $track if $opt->verbose;
	$mp3->update_tags();
	utime($atime, $mtime, $file);
    }
}
