## add_music.pl

Adds a file to the iTunes database

    perl add_music.pl some/file/with/music.mp3

## find_no_tag.pl

Finds files without tags. If passed a directory, examines it recurively.

   perl find_no_tag.pl /some/directory

to find files without tags in the directory or 

   find . -type f -name \*.mp3 -mtime -2 -exec perl find_no_tag.pl {} \;

to check whether the files found have all tags 

## guess_cddb.pl

Finds cddb files across genres, if only one genre is found, downloads it.

   perl guess_cddb.pl 7b08c90a

outputs:

    7b08c90a could be:
    Jason and the Scorchers	A Blazing Grace	Rock	1995	rock
    GIRL	Waisted Youth	Hard Rock	1982	blues
    Donna Dean	Between you and me			folk
    H?sker D?	Candy Apple Grey	Alternative	1986	misc

and 

   perl guess_cddb.pl 7b08c90a misc

downloads the Candy Apple Grey cddb entry.

## music_edit.pl

    music_edit.pl [-ehvy] [long options...] <some-arg>
    	-e --edits      edits to apply (i.e.: artist=s/foo/bar/i or
    	                *=s/bar/foo/)
    	--unidecode     unidecode output
    	--cleanup       cleanup tags
    	              
    	-y --dryrun     dry run
    	              
    	-v --verbose    print extra stuff
    	-h --help       print usage message and exit
    
Edits tags in a file with regexps.

    perl /Users/cesansim/Devel/Music-Tools/music_edit.pl -e album=s/zo.+?sis//i -v --cleanup /some/file/00-track.mp3

edits the album tag of a file by executing the regexp s/zo.+?sis//i on it

## music_find.pl

## music_tidy.pl

    music_tidy.pl [-cfhlrsvy] [long options...] <some-arg>
    	-f --format     path format
    	-r --root       root directory
    	-l --lc         convert to lowercase
    	-s --spaces     convert spaces to underscores
    	              
    	-y --dryrun     dry run
    	-c --copy       copy instead of moving
    	              
    	-v --verbose    print extra stuff
    	-h --help       print usage message and exit

tidies music by copying or moving the files into directories according to the content of the file's tags and a template.

Two tags are added automatically:

- initial, with the artist's initial
- format, from the file suffix

For example

    perl ~/Devel/Music-Tools/music_tidy.pl -csl -r ~/Desktop -slf %s/%s/%s/%s/%02d-%s.%s,format,initial,artist,album,track,song,format /some/file/track01.mp3

would put the file into ~/Desktop/mp3/b/the_beatles/revolver/01-taxman.mp3 (assuming that it is the beatles' Taxman from the album Revolver

## ripit.pl

## tagit.pl

    tagit.pl [-acghtv] [long options...] <text-file or sqlite-db>
    	-c --cddb       cddb file
    	              
    	-g --genre      genre
    	-a --artist     artist
    	-t --title      album title
    	              
    	-v --verbose    print extra stuff
    	-h --help       print usage message and exit
    
Tags files in a directory with the data in the cddb file of the same name, or another
one specified by the `-d` option.

    perl tagit.pl /some/dir/2d10c415

would tag the files in /some/dir/2d10c415 with the data in /some/dir/2d10c415.cddb.

Specific tags can be forced with the respective tags.

## encodeit.sh

## find_cddb.sh

## findwav.sh

