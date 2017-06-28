#!/usr/bin/perl
use strict;
use warnings;
use WWW::Mechanize;
use utf8;  # for Chinese characters
use HTML::TableExtract;
binmode STDOUT, ":encoding(UTF-8)";  # Eliminates warning about wide characters

# This section is copied from 
# http://stackoverflow.com/questions/2037467/how-can-i-treat-command-line-arguments-as-utf-8-in-perl
# Without this section, you would need to tell Perl to take in @ARGV
# as UTF-8 via the command: perl -CA scriptname.pl 搜索的生字
use I18N::Langinfo qw(langinfo CODESET);
my $codeset = langinfo(CODESET);
use Encode qw(decode);
@ARGV = map { decode $codeset, $_ } @ARGV;



if (@ARGV < 1) {
	print "請輸入生字...\n";
}	else 	{

	my $url = 'http://www.mandarintools.com/chardict.html';
	my $mech = WWW::Mechanize->new;

	my $charsrch = $ARGV[0];
	my @canto;   # Cantonese pronunciations
	my @mando;   # Mandarin pronunciations

	$mech->get($url);

	# Fill in inputs and click buttom
	$mech->set_fields( 'whatchar' => "$charsrch" );
	# $mech->set_fields( 'whatchar' => '使' );
	$mech->click('searchchar');

	my $charpage = $mech->content;
	my $table_extract = HTML::TableExtract->new(headers => [ 'Pinyin', 'Cantonese'] );
	$table_extract->parse($charpage);


	foreach my $ts ($table_extract->tables) {
		# print "Table (", join(',', $ts->coords), "):\n";
	  	foreach my $row ($ts->rows) {
			push(@mando, @$row[0]);
			push(@canto, @$row[1]);
		}
	}

	# print "@cantopronounce\n";
	print "== 真好笑 牛上樹 ==\n";

	my $char;
	for (my $i = 0; $i < length($charsrch); $i++) {
		$char = substr($charsrch, $i, 1);
		no warnings;  # In case it complains about $canto[$i] or $mando[$i] being undefined
		print "$char: $canto[$i] ..... $mando[$i]\n";
		use warnings;
	}

}

exit 0;
