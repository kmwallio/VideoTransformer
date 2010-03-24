#!/usr/bin/perl

#use strict;
use Gtk2 '-init';
use Glib qw/TRUE FALSE/;
use KMVid::Clicker;
use KMVid::ExtractFrames;
use Image::Magick;
use PDL;
use PDL::NiceSlice;
use PDL::Matrix;
use PDL::MatrixOps;
use POSIX qw(ceil);

# Create our Window
our $window = Gtk2::Window->new('toplevel');
$window->set_title("Video Transfomer - Control Window");
$window->signal_connect('delete-event' => sub{ Gtk2->main_quit });
$window->set_border_width(15);
my $magic_window = Gtk2::Window->new('toplevel');
$magic_window->set_title('Processing Frames:');
my $mpBar = Gtk2::ProgressBar->new();
$magic_window->signal_connect('delete-event' => sub{ $magic_window->hide_all() });
$magic_window->add($mpBar);
$magic_window->resize(500, 100);

our $working_vid = FALSE;

# General layout thing
my $pane = Gtk2::VBox->new();
	
	# File choosers...
	my $chooser = Gtk2::HBox->new();
	
	my $dest = Gtk2::VBox->new();
	my $source = Gtk2::VBox->new();
	
	our $lbl_dest = Gtk2::Label->new('No Destination File');
	our $lbl_source = Gtk2::Label->new('No Source File');
	
	our $source_file = "";
	our $dest_file = "";
	our @frames;
	our $cur_frame = 0;
	our @clicks;
	
	my $open_dest = Gtk2::Button->new('Select Destination Video');
	$open_dest->signal_connect('clicked' => sub{ choose_file('Select Destination Video','open','dest') });
	my $open_source = Gtk2::Button->new('Select Source Video');
	$open_source->signal_connect('clicked' => sub {choose_file('Select Source Video','open','source') });
	
	$dest->pack_start($lbl_dest, TRUE, FALSE, 0);
	$dest->pack_end($open_dest, TRUE, FALSE, 0);
	
	$source->pack_start($lbl_source, TRUE, FALSE, 0);
	$source->pack_end($open_source, TRUE, FALSE, 0);
	
	$chooser->pack_start($dest, TRUE, FALSE, 0);
	$chooser->pack_end($source, TRUE, FALSE, 0);
	
	# Bottom menu buttons
	my $menu_b = Gtk2::HBox->new();
	# Add a quit button
	my $quit_b = Gtk2::Button->new("Quit");
	$quit_b->signal_connect('clicked' => sub{ Gtk2->main_quit });
	# Process
	my $mouse_b = Gtk2::Button->new("Click-Through Process");
	$mouse_b->signal_connect('clicked' => sub{ click_through() });
	
	my $magic_b = Gtk2::Button->new("Magic Process");
	$magic_b->signal_connect('clicked' => sub{ magic_through() });
	
	# Add our buttons
	$menu_b->pack_start($mouse_b, TRUE, TRUE, 0);
	#$menu_b->pack_start($magic_b, TRUE, TRUE, 0);
	$menu_b->pack_end($quit_b, TRUE, TRUE, 0); 

$pane->pack_start($chooser, TRUE, TRUE, 0);
$pane->pack_end($menu_b, TRUE, FALSE, 0);

# Compose and show the window.
$window->add($pane);
$window->show_all();

Gtk2->main();

sub choose_file {
	my ($prompt, $type, $where) = @_;
	# Create a new file chooser dialog
	my $file_chooser = Gtk2::FileChooserDialog->new($prompt,
												undef,
												$type,
												'gtk-cancel' => 'cancel',
												'gtk-ok' => 'ok'
											);
	# Only let movies be selected
	$file_chooser->add_filter(&filter_movie());
	
	# Check if we get input
	my $fname = "";
	if ('ok' eq $file_chooser->run()) {
		$fname = $file_chooser->get_filename();
		if ($where eq 'source'){
			$source_file = $fname;
			if ($source_file =~ m/\/(.*)\/(.*)\.(.*)/){
				$lbl_source->set_text($2 . "." . $3);
			}else{
				$lbl_source->set_text("No File Selected");
			}
		}else{
			$dest_file = $fname;
			if ($dest_file =~ m/\/(.*)\/(.*)\.(.*)/){
				$lbl_dest->set_text($2 . "." . $3);
			}else{
				$lbl_dest->set_text("No File Selected");
			}
		}
	}
	
	$file_chooser->destroy();
	return;
}

sub filter_movie{
	my $filter = Gtk2::FileFilter->new();
	$filter->set_name("Videos");
	$filter->add_mime_type("video/quicktime");
	$filter->add_mime_type("video/mpeg");
	$filter->add_mime_type("video/x-msvideo");
	return $filter;
}

sub click_through {
	if ($working_vid){
		return already_working();
	}
	
	if ($source_file eq "" || $dest_file eq ""){
		return no_input();
	}
	
	$working_vid = TRUE;
	my $dest = new ExtractFrames($dest_file, "dest");
	$dest->start();
	$dest = undef;
	my $source = new ExtractFrames($source_file, "source");
	$source->start();
	$source = undef;
	
	opendir(DIR, "./temp/dest");
	@frames = readdir(DIR);
	closedir(DIR);
	
	open(CLICKS, "> ./temp/clicks.log");
	print CLICKS "";
	close(CLICKS);
	
	while($frames[$cur_frame] !~ m/(jpeg|jpg)/){
		$cur_frame = $cur_frame + 1;
	}
	$cur_frame = $cur_frame - 1;
	next_frame();
	
	#foreach(@frames){
	#	print $_ . "\n";
	#	if($_ =~ m/(jpeg|jpg)/){
	#		print "./temp/dest/" . $_ . "\n";
	#		my $cl = new Clicker("./temp/dest/" . $_);
	#		$cl->start();
	#		while($cl->working()){
	#			sleep(1);
	#		}
	#		$cl = undef;
	#	}
	#}
	return;
}

sub next_frame {
	$cur_frame = $cur_frame + 1;
	my $size = scalar(@frames);
	if($cur_frame < $size){
		my $s_frame = './temp/source/' . $frames[$cur_frame];
		if(-e $s_frame){
			my $cl = new Clicker("./temp/dest/" . $frames[$cur_frame], \&next_frame);
			$cl->start();
			$cl = undef;
		}else{
			work_magic();
		}
	}else{
		work_magic();
	}
}

sub magic_through {
	if ($working_vid){
		return already_working();
	}
	
	if ($source_file eq "" || $dest_file eq ""){
		return no_input();
	}
	
	$working_vid = TRUE;
	
	$working_vid = FALSE;
	return;
}

sub already_working {
	my $dialog = Gtk2::MessageDialog->new ($window,
										'modal',
										'error',
										'ok',
										'Already processing the videos.');
	$dialog->run();
	$dialog->destroy();
	return FALSE;
}

sub no_input {
	my $dialog = Gtk2::MessageDialog->new ($window,
										'modal',
										'error',
										'ok',
										'Please choose both the source and destination videos.');
	$dialog->run();
	$dialog->destroy();
	return FALSE;
}

sub work_magic {
	$magic_window->show_all();
	open(CLICKR, "< ./temp/clicks.log");
	while(<CLICKR>){
		push(@clicks, $_);
	}
	close(CLICKR);
	my $current = 0;
	foreach(@frames){
		$current = $current + 1;
		if($_ =~ m/(jpeg|jpg)/){
			$mpBar->set_fraction($current / scalar(@frames));
			$mpBar->set_text(($current - 2) . ' of ' . (scalar(@frames) - 2));
			while (Gtk2->events_pending) {
				Gtk2->main_iteration;
			}
			Gtk2::Gdk->flush;
			my $s_frame = './temp/source/' . $_;
			if(-e $s_frame){
				transform('./temp/dest/' . $_, $s_frame, './temp/output/' . $_, shift(@clicks));
			}
		}
	}
	$mpBar->set_fraction(1);
	$mpBar->set_text("Finished all clicked images.");
	while (Gtk2->events_pending) {
		Gtk2->main_iteration;
	}
	Gtk2::Gdk->flush;
	sleep(1);
	make_movie();
}

sub transform {
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
	my @nColor1 = (-1, -1, -1);
	my @nColor2 = (-1, -1, -1);
	my @nColor3 = (-1, -1, -1);
	my @pColor = (-1, -1, -1);
	my $lX = 0;
	my $uX = 0;
	my $lY = 0;
	my $uY = 0;
	#my @oColor = (-1, -1, -1);
	for($nX = 0; $nX < $nwidth; $nX++){
		for($nY = 0; $nY < $nheight; $nY++){
			my $ohYeah = PDL::Matrix->pdl([[$nX], [$nY], [1]]);
			my ($oX, $oY, $oW) = list($mm x $ohYeah);
			$oX = $oX / $oW;
			$oY = $oY / $oW;
			if(int($oX) >= 0 && int($oX) < $width && int($oY) >= 0 && int($oY) < $height){
				@pColor = $source_img->GetPixel(channel => 'RGB', x => int($oX), y => int($oY));
				#if($nwidth > $width && $nheight > $height){
					eval {
						$lY = int($oY);
						$uY = ceil($oY);
						$uX = ceil($oX);
						$lX = int($oX);
						if($uX != $lX && $uY != $lY){
							$fOne = (1 / (($uX - $lX) * ($uY - $lY))) * ($uX - $oX) * ($uY - $oY);
							$fTwo = (1 / (($uX - $lX) * ($uY - $lY))) * ($oX - $lX) * ($uY - $oY);
							$fTre = (1 / (($uX - $lX) * ($uY - $lY))) * ($uX - $oX) * ($oY - $lY);
							$fFor = (1 / (($uX - $lX) * ($uY - $lY))) * ($oX - $lX) * ($oY - $lY);
							@nColor = $source_img->GetPixel(channel => 'RGB', x => $lX, y => $lY);
							@nColor1 = $source_img->GetPixel(channel => 'RGB', x => $uX, y => $lY);
							@nColor2 = $source_img->GetPixel(channel => 'RGB', x => $lX, y => $uY);
							@nColor3 = $source_img->GetPixel(channel => 'RGB', x => $uX, y => $uY);
							$pColor[0] = ($nColor[0] * $fOne) + ($nColor1[0] * $fTwo) + ($nColor2[0] * $fTre) + ($nColor3[0] * $fFor);
							$pColor[1] = ($nColor[1] * $fOne) + ($nColor1[1] * $fTwo) + ($nColor2[1] * $fTre) + ($nColor3[1] * $fFor);
							$pColor[2] = ($nColor[2] * $fOne) + ($nColor1[2] * $fTwo) + ($nColor2[2] * $fTre) + ($nColor3[2] * $fFor);
						}
					};
				#}
				#@oColor = $dest_img->GetPixel(x => $nX, y => $nY);
				$dest_img->SetPixel(x => $nX, y => $nY, color => \@pColor);
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
}

sub make_movie {
	$mpBar->set_fraction(1);
	$mpBar->set_text("Making Movie.  Window will close magically.");
	while (Gtk2->events_pending) {
		Gtk2->main_iteration;
	}
	Gtk2::Gdk->flush;
	$make_m = `mencoder "mf://./temp/output/*.jpg" -mf fps=15 -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=1500 -o video.mpeg`;
	$convert = `ffmpeg -i video.mpeg -b 1500k -r 15 -f mp4 -y video.mp4`;
	$mpBar->set_text("Done... video.mp4 is the result.");
	sleep(15);
	$magic_window->hide_all();
}