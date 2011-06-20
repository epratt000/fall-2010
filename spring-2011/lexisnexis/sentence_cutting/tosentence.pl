#!/usr/bin/perl -w
# @file tosentence.pl
# @brief This script is to split paragraphs into sentences.
# We used the Lingua::EN::Sentence package for this task. 
# The unique difficulty for this task is to identify as many 
# variations as possible for the input data. So, we use the
# random sampling method to make this task sound. 
# 
# @author Simon Guo<shumin.guo@lexisnexis.com>
# @revision 1.0 06/15/2011, by Simon
# - Initially created.
# @revision 1.1 06/19/2011, by Simon
# - Added more acronyms and sentence variations by random sampling. 
# @comments Please update the revision log when you update
# this file, thanks. 

use Lingua::EN::Sentence qw( get_sentences add_acronyms get_EOS );

# the end of sentence.
my $EOS = &get_EOS(); 		# end of sentence separator. 

while (<STDIN>) {
    # 
    # ======================================================================
    # --Preprocessing of the document.-- 
    # This process will be used to remove all the errors that can cause the
    # failure of the sentence cutting program. 
    # 
    # do pre-processing to the paragraph, erase the unregular patterns.
    # add additional acronyms. 
    # ajust abbreviations. 
    add_acronyms(q/[0-9]+/, 'Sec', 'Am', 'Jur', 'App', 'No', 'Etc', 'Id'); 
    add_acronyms('orig', 'Rev', 'Civ', 'Stat', 'Ann', 'Mag', 'Op', 'Com', 'Bl'); # 06/19/2011.
    add_acronyms('Ab', 'tit', 'pen', 'supp', 'bhd', 'Indus'); # 06/20/2011.

    # because acronyms are capital initialized words some may not work such as seq. 
    s/(seq\.)/$1,/g;
    s/(cert\.)/$1,/g;
    s/(disc\.)/$1,/g;
    s/(etc\.) ([A-Z])/$1. $2/g;	# ended with etc. might have problem. 
    
    # special cases.
    s/"If/" If/g;
    s/Id\.//g;			# This term is redundant?
    s/([0-9a-z]+\."?)([A-Z])/$1 $2/g; # Add space between sentences. 

    # remove the numbering at the beginning of paragraph. 
    s/\. ([SL]_[0-9]+)/\, $1/g;	# e.g: xxx. S_10. => xxx, S_10.
    s/\" ([SL]_[0-9]+)/", $1/g;
    s/([SL]_[0-9]+)\. ?([^A-Z])/$1\, $2/g; # change . to ,

    # Adjust headnotes and footnotes. 
    s/(FN_[0-9]+) ([A-Z])/$1\. $2/g;
    s/\. ([HF]N_[0-9]+)/\, $1/g;   
    s/([SL]_[0-9]+[.,;!'"])/$1 /g; # e.g: S_10,Abc => S_10, Abc

    # adjust marks. like .... ... etc. 
    s/\.\.\.\.?( [^A-Z])/, $1/g; # e.g: .... by => , by
    s/\.\.\.\.?( [A-Z])/\. $1/g; # e.g: .... By => . By
    s/\.\.\.?\.?([^ ])/\.$1/g;	 # e.g: ..., by => ., by

    # adjust numbers. 
    s/^[0-9]+\. //g;		# e.g: 1. The extent of ....
    #s/ ([0-9]+)\. / $1, /g;
    s/ I\.//g;			# remove numbering. 
    s/ II\.//g;
    s/ III\.//g;
    s/ IV\.//g;
    s/([\"\.]) ([0-9]+[^\.])/$1, $2/g;
    s/([\"\.]) ([\(])/$1, $2/g;		   # e.g: A. (2nd) => A., (2nd)
    s/([\",\.][0-9]+)\. ([^A-Z])/$1, $2/g; # e.g: "2. xxx. => "2, xxx.

    my $sentence = get_sentences($_); 
    foreach $sentence (@$sentence) {
	# post-process the sentence.
	$sentence =~ s/  +/ /g;	# remove redundant spaces. 
	$sentence =~ s/\.\./\./g; # remove additional period mark. 
	# If sentence doesn't contain ending mark, add one. 
	if (($sentence =~ m/(^.*)([^\.\"\?\:])$/) && 
	    ($sentence !~ m/PARAGRAPH_[0-9]+/)) {
	    $sentence = $1 . $2 . "."; 
	}
	print "\n" . $sentence . "\n"; 
    }
}
