#!/Users/cesansim/perl5/perlbrew/perls/perl-5.18.2/bin/perl

use strict;
use File::Find ();
use MP3::Tag;
use Getopt::Std;

use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

our($opt_d);

$\ = "\n";

getopts('d');

my $dirs;

sub wanted;

File::Find::find({wanted => \&wanted}, $ARGV[0] || '.');
exit;

sub wanted {
    return unless /mp3$|flac$|ogg$/;
    my $mp3=MP3::Tag->new($_);
    my %info;
    @info{qw/title track artist album/} = $mp3->autoinfo();
    return if ((scalar grep { /\w/ } values %info) == 4);
    if ($opt_d) {
	print $dir unless $dirs->{$dir}++;
    } else {
	print($name) 
    }
}

