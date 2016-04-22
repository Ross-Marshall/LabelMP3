#!/usr/bin/perl

# Remove whitespace from the start and end of the string
sub trimwhitespace($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

# Remove the period
sub removeperiod($)
{
        my $string = shift;
	$string =~ s/\.//;
	return $string;
}

# Remove blank spaces
sub removeblanks($)
{
        my $string = shift;
	$string =~ s/ //g;
	return $string;
}

sub remove_trouble_chars($)
{
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        $string =~ s/ //g;
        $string =~ s/\(/-/g;
        $string =~ s/\)/-/g;
        $string =~ s/\'//g;
        $string =~ s/\///g;
        $string =~ s/\;/-/g;
        $string =~ s/\&//g;
        $string =~ s/\?//g;
        $string =~ s/\"//g;
        return $string;
}

######################### main ######################
 
#(1 == $#ARGV ) or die "Usage: perl labelmp3-v2.pl <title file> <mp3 directory list>\n";

$infile = $ARGV[0];   # titles.txt
$filelist = $ARGV[1]; # list of track files
#$outfile = $ARGV[2];
$makemp3 = "make_mp3.sh";
$updatetags = "update_tags.sh";

open(INFILE, "<$infile") or die "(Could not open $infile for input\n)";
open(DIRLIST, "<$filelist") or die "(Could not open $filelist for input\n)";
open(LAME1, ">$makemp3") or die "(Could not open $makemp3 for output\n)";
open(LAME2, ">$updatetags") or die "(Could not open $updatetags for output\n)";

@file_data=<INFILE>;

foreach $line(@file_data)
{
    chomp($line);
    if ( trimwhitespace(substr $line, 0, 7) eq "ARTIST=" )
    {
       $artist = trimwhitespace( substr $line, 7, 80 ); 

       if ( $artist eq "title-first" )
       {
           $titleFirst = 1;
       }
       else
       {
           $titleFirst = 0;
       }
    }
    elsif ( trimwhitespace(substr $line, 0, 6) eq "ALBUM=" )
    {
       $album= trimwhitespace( substr $line, 6, 80 ); 
    }
    else
    {
       $file_name = readline( DIRLIST ); 
       chomp($file_name);
    
       $first_char = index($line, ".")+2;
       $position = trimwhitespace(removeperiod(substr $line, 0,$first_char));


       $artistEnd = index( $line, " - " );
       if ( $artistEnd == -1 )
       {
          $title = trimwhitespace(substr $line, $first_char, 80);
       }
       else
       {
          if ( $titleFirst == 1 ) {
              $title = trimwhitespace(substr $line, $first_char, $artistEnd-2);
              $artist = trimwhitespace(substr $line, $artistEnd+2, 80);
          } else {
              $artist = trimwhitespace(substr $line, $first_char, $artistEnd-2);
              $title = trimwhitespace(substr $line, $artistEnd+2, 80);
          }
       }

       $actual_file_title = remove_trouble_chars($title);
       $new_file_name = removeblanks($album) . "_";
       if ($position < 10 )
       {
           $new_file_name = $new_file_name . "00";
       }
       if ($position < 100 )
       {
           $new_file_name = $new_file_name . "0";
       }
       $new_file_name = $new_file_name . $position . "_" . remove_trouble_chars($artist) . "_" . $actual_file_title . ".mp3\n";

       print LAME1 "lame -b 256 -V2 $file_name $new_file_name\n";
       print LAME2 "mp3info -l \"$album\" -a \"$artist\" -n $position -t \"$title\" $new_file_name\n";
  
    }
}

close (INFILE);
close (DIRLIST);
close (LAME1);
close (LAME2);

`chmod +x *.sh`;

`sh ./make_mp3.sh`;
`sh ./update_tags.sh`; 
`mp3info -i *3`;
