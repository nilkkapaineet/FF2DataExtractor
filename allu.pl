#!/usr/bin/perl

for ($i=550;$i<=10400;$i=$i+25){
	&lueTiedosto($i);
}
&regex;
&kayttaja;
&tulostaKayttajat;
&tulostaTunnit;
&tulostaKuut;
&tulostaPaivat;

sub tulostaPaivat {
	open(my $fh, '>', 'paivaReport.txt');
	print $fh "mikä päivä, montako kpl\n";
	foreach my $name (sort { $viestitPaivassa{$a} <=> $viestitPaivassa{$b} } keys %viestitPaivassa) {
		if ($name == 5) {
			$vkop = "perjantai";
		} elsif ($name == 4) {
			$vkop = "torstai";
		} elsif ($name == 3) {
			$vkop = "keskiviikko";
		} elsif ($name == 2) {
			$vkop = "tiistai";
		} elsif ($name == 1) {
			$vkop = "maanantai";
		} elsif ($name == 6) {
			$vkop = "lauantai";
		} elsif ($name == 0) {
			$vkop = "sunnuntai";
		}
		printf $fh "%-8s %s\n", $vkop, $viestitPaivassa{$name};
	}
	close $fh;
}

sub tulostaTunnit {
	open(my $fh, '>', 'tuntiReport.txt');
	print $fh "mikä tunti, montako kpl\n";
	foreach my $name (sort { $viestitTunnissa{$a} <=> $viestitTunnissa{$b} } keys %viestitTunnissa) {
		printf $fh "%-8s %s\n", $name, $viestitTunnissa{$name};
	}
	close $fh;
}

sub tulostaKuut {
	open(my $fh, '>', 'kuuReport.txt');
	print $fh "mikä kuu, montako kpl\n";
	foreach my $name (sort { $viestitKuussa{$a} <=> $viestitKuussa{$b} } keys %viestitKuussa) {
		printf $fh "%-8s %s\n", $name, $viestitKuussa{$name};
	}
	close $fh;
}

sub tulostaKayttajat {
	open(my $fh, '>', 'userReport.txt');
	print $fh "kuka käyttäjä, montako kpl\n";
	foreach my $name (sort { $kayttajat{$a} <=> $kayttajat{$b} } keys %kayttajat) {
		printf $fh "%-8s %s\n", $name, $kayttajat{$name};
	}
	close $fh;
}

sub lueTiedosto {
	my $numb = shift;
	print "tiedosto $numb menossa \n";
	$fileHandle = 'index.php_topic=189560_' . $numb;
	open(XZY,$fileHandle);
	push(@lines,<XZY>);
	close(XZY);	

}

sub regex {
	foreach my $rivi (@lines) {
		 if ($rivi =~ m{Vastaus #(\d+) : (\d+).(\d+).(\d+) klo (\d+):(\d+):(\d+)} ) {
			my ($numero, $pvm, $kk, $vuosi, $tunti, $min, $sek) = ($1, $2, $3, $4, $5, $6, $7);
			if( exists($viestitKuussa{$kk} ) ){
				$viestitKuussa{$kk} = $viestitKuussa{$kk} + 1;
			} else {
				$viestitKuussa{$kk} = 1;
			}
			if( exists($viestitTunnissa{$tunti} ) ){
				$viestitTunnissa{$tunti} = $viestitTunnissa{$tunti} + 1;
			} else {
				$viestitTunnissa{$tunti} = 1;
			}
			# määrittele pvm pvm%7
			if ($kk eq "01" || $kk eq "04" || $kk eq "07") {
				#perjantai
				$pvm += 4;
			} elsif ($kk eq "02" || $kk eq "08") {
				#maanantai
				# älä tee mitään
			} elsif ($kk eq "03" || $kk eq "11") {
				# tiistai
				$pvm += 1;
			} elsif ($kk eq "05") {
				# sunnuntai
				$pvm += 6;
			} elsif ($kk eq "06") {
				# keskiviikko
				$pvm += 2;
			} elsif ($kk eq "10") {
				# lauantai
				$pvm += 5;
			} else {
				# torstai
				$pvm += 3;
			}
			$pvm = $pvm%7;
				
			if( exists($viestitPaivassa{$pvm} ) ){
				$viestitPaivassa{$pvm} = $viestitPaivassa{$pvm} + 1;
			} else {
				$viestitPaivassa{$pvm} = 1;
			}
		}
	}
}

sub kayttaja {

	foreach my $rivi (@lines) {
		if ($rivi =~ m{Vs: Aleksi} ) {
			if( exists($kayttajat{$edellinenRivi} ) ){
				# lisää value yhdellä
				$kayttajat{$edellinenRivi} = $kayttajat{$edellinenRivi} + 1;
			} else {
				# uusi käyttäjä, value 1
				$kayttajat{$edellinenRivi} = 1;
			}
		}
		if ($rivi =~ /^\s*$/ ) {
				# empty line
		} else {
			$rivi =~ s/^\s+|\s+$//g;
			$edellinenRivi = $rivi;
		}
	}
}
