use Gtk2 '-init';
use Glib qw/TRUE FALSE/;
use KMVid::Clicker;
use KMVid::ExtractFrames;
use Image::Magick;
use PDL;
use PDL::NiceSlice;
use PDL::Matrix;
use PDL::MatrixOps;
use Gtk2 '-init';
use Glib qw/TRUE FALSE/;
my $window = Gtk2::Window->new('toplevel');
$window->set_title('Running Clicks:');
my $pBar = Gtk2::ProgressBar->new();
$window->signal_connect('delete-event' => sub{ Gtk2->main_quit });
$window->add($pBar);
$window->resize(500, 100);
$window->show_all();

work_magic();

sub work_magic {
	opendir(DIR, "./temp/dest");
	@frames = readdir(DIR);
	closedir(DIR);
	open(CLICKR, "< ./temp/clicks.log");
	while(<CLICKR>){
		push(@clicks, $_);
	}
	close(CLICKR);
	$current = 0;
	foreach(@frames){
		print $_ . "\n";
		$current = $current + 1;
		if($_ =~ m/(jpeg|jpg)/){
			print " is an Image.";
			my $s_frame = './temp/source/' . $_;
			if(-e $s_frame && @clicks != 0){
				print " has Clicks.\n";
				$pBar->set_fraction($current / scalar(@frames));
				$pBar->set_text(($current - 2) . ' of ' . (scalar(@frames) - 2));
				while (Gtk2->events_pending) {
					Gtk2->main_iteration;
				}
				Gtk2::Gdk->flush;
				transform('./temp/dest/' . $_, $s_frame, './temp/output/' . $_, shift(@clicks));
			}
		}
	}
	$pBar->set_fraction(1);
	$pBar->set_text("Finished all clicked images.");
	while (Gtk2->events_pending) {
		Gtk2->main_iteration;
	}
	Gtk2::Gdk->flush;
}

sub transform {
	print "Transform\n";
	my $dest = shift;
	my $source = shift;
	my $out = shift;
	my $coords = shift;
	
	($x3, $y3, $x2, $y2, $x0, $y0, $x1, $y1) = split(/\s/, $coords);
	
	my $dest_img = new Image::Magick;
	$dest_img->Read($dest);
	my $source_img = new Image::Magick;
	$source_img->Read($source);
	
	my $width = $source_img->Get('columns');
	my $height = $source_img->Get('rows');
	
	my $nwidth = $dest_img->Get('columns');
	my $nheight = $dest_img->Get('rows');
	
	my $u0 = 0;
	my $v0 = $height;
	my $u1 = $width;
	my $v1 = $height;
	my $u2 = $width;
	my $v2 = 0;
	my $u3 = 0;
	my $v3 = 0;
	
	my $m = PDL::Matrix->pdl([
		[$u0, $v0, 1, 0, 0, 0, (-1 * $u0 * $x0), (-1 * $v0 * $x0)],
		[$u1, $v1, 1, 0, 0, 0, (-1 * $u1 * $x1), (-1 * $v1 * $x1)],
		[$u2, $v2, 1, 0, 0, 0, (-1 * $u2 * $x2), (-1 * $v2 * $x2)],
		[$u3, $v3, 1, 0, 0, 0, (-1 * $u3 * $x3), (-1 * $v3 * $x3)],
		[0, 0, 0, $u0, $v0, 1, (-1 * $u0 * $y0), (-1 * $v0 * $y0)],
		[0, 0, 0, $u1, $v1, 1, (-1 * $u1 * $y1), (-1 * $v1 * $y1)],
		[0, 0, 0, $u2, $v2, 1, (-1 * $u2 * $y2), (-1 * $v2 * $y2)],
		[0, 0, 0, $u3, $v3, 1, (-1 * $u3 * $y3), (-1 * $v3 * $y3)]
		]);
	
	my $s0 = PDL::Matrix->pdl([
		[$x0],
		[$x1],
		[$x2],
		[$x3],
		[$y0],
		[$y1],
		[$y2],
		[$y3]
		]);
	my $s = PDL::Matrix->pdl($x0,
		$x1,
		$x2,
		$x3,
		$y0,
		$y1,
		$y2,
		$y3);
	
	my $m_inv = inv($m);
	my $q = $m x $s0;
	#print $m;
	#print $m_inv;
	my $r = (transpose($m_inv) x $s);
	$r = transpose($r);
	my ($a, $b, $c, $d, $e, $f, $g, $h) = list($r);
	
	my $mm = PDL::Matrix->pdl([
		[$e - ($f * $h), ($c * $h) - $b, ($b * $f) - ($c * $e)],
		[($f * $g) - $d, $a - ($c * $g), ($c * $d) - ($a * $f)],
		[($d * $h) - ($e * $g), ($b * $g) - ($a * $h), ($a * $e) - ($b * $d)]
		]);
	my @nColor = (-1, -1, -1);
	my @oColor = (-1, -1, -1);
	for($nX = 0; $nX < $nwidth; $nX++){
		for($nY = 0; $nY < $nheight; $nY++){
			my $ohYeah = PDL::Matrix->pdl([[$nX], [$nY], [1]]);
			my ($oX, $oY, $oW) = list($mm x $ohYeah);
			$oX = $oX / $oW;
			$oY = $oY / $oW;
			if(int($oX) >= 0 && int($oX) < $width && int($oY) >= 0 && int($oY) < $height){
				@nColor = $source_img->GetPixel(channel => 'RGB', x => int($oX), y => int($oY));
				@oColor = $dest_img->GetPixel(x => $nX, y => $nY);
				$dest_img->SetPixel(x => $nX, y => $nY, color => \@nColor);
			}
			$ohYeah = undef;
			while (Gtk2->events_pending) {
				Gtk2->main_iteration;
			}
			Gtk2::Gdk->flush;
		}
	}
	$s = undef;
	$s0 = undef;
	$m_inv = undef;
	$q = undef;
	$m = undef;
	$dest_img->Write($out);
	$dest_img = undef;
	$source_img = undef;
	print "End Transform\n";
}

Gtk2->main();