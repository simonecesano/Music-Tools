#!/Users/cesansim/perl5/perlbrew/perls/perl-5.18.2/bin/perl

use Path::Iterator::Rule;
use MP3::Tag;
use Getopt::Long::Descriptive;
use Path::Tiny;
use List::MoreUtils qw/uniq/;
use Text::Unidecode;

my ($opt, $usage) = 
    describe_options
    (
     "$0 %o <some-arg>",
     [ 'type|t=s', "file type (wav, mp3, etc.)" ],
     [],
     [ 'tag=s',   "file tag" ],
     [ 'notag=s',   "missing tag" ],
     [ 'print=s', "output" ],
     [],
     [ 'uniq|u', "only print unique output" ],
     [ 'unidecode', "unidecode output" ],
     [],
     [ 'verbose|v',  "print extra stuff"            ],
    [ 'help',       "print usage message and exit" ],
    );

print($usage->text), exit if $opt->help;

$\ = "\n"; $, = "\t";

my $rule = Path::Iterator::Rule->new;

if ($opt->type) {
    my $r = '\.' . $opt->type . '$';
    $rule = $rule->name(qr/$r/);
} else {
    $rule = $rule->name(qr/\.mp3$|\.ogg$|\.flac$/);
}

if ($opt->tag) {
    my ($tag, $val) = split '=', $opt->tag;
    my $sub;
    if (ref eval $val eq 'Regexp') {
	$val = eval $val;
	$sub = sub { my $mp3 = MP3::Tag->new($_); $mp3 && $mp3->autoinfo->{$tag} =~ $val };
    } else {
	$sub = sub { my $mp3 = MP3::Tag->new($_); $mp3 && $mp3->autoinfo->{$tag} eq $val };
    }
    $rule = $rule->and( $sub );
}

if ($opt->notag) {
    for (my $tag = split /\W/, $opt->notag) {
	$sub = sub { my $mp3 = MP3::Tag->new($_); $mp3->autoinfo->{$tag} = '' };
	$rule = $rule->and( $sub );
    }
}


my $print;

if ($opt->print) {
    # my @tags = grep { !/file/ } split ',', $opt->print;
    my @tags = split ',', $opt->print;

    $print = sub {
	my $file = shift;
	$mp3 = MP3::Tag->new($file)->autoinfo;
	$mp3->{file} = path($file);
	$mp3->{dir} = $mp3->{file}->parent;
	return (@{$mp3}{@tags});
    };
} else {
    $print = sub { return @_ };
}

if ($opt->unidecode) {
    my $sub = $print;
    $print = sub { map { unidecode($_) } $sub->(@_) } 
}

my @iter;
my $next = $rule->iter( @ARGV );

if ($opt->uniq) {
    while ( defined( my $file = $next->() ) ) {
	push @iter, join $,, $print->($file);
    }
    print for uniq sort @iter;
} else {
    while ( defined( my $file = $next->() ) ) {
	print $print->($file);
    }
}


