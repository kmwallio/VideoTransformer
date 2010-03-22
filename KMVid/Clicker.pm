#!/opt/local/bin/perl

use Gtk2 '-init';
use Glib qw/TRUE FALSE/;

package Clicker;

sub new {
	my ($class, $image, $parent) = @_;
	my $window = Gtk2::Window->new('toplevel');
	$window->set_title('Mapping');
	$window->set_resizable(FALSE);
	$window->set_position('center');
	# Basic stuff...
	my $guide_lbl = Gtk2::Label->new("Click where the upper left corner goes");
	my $self = {
		_img => $image,
		_window => $window,
		_guide => $guide_lbl,
		_done => FALSE,
		_cur => 0,
		_log => "",
		_working => TRUE,
		_parent => $parent
	};
	bless $self, $class;
	$self->{_window}->signal_connect('delete-event' => sub{ $self->destroy() });
	return $self;
}

sub start {
	my $self = shift;
	
	# Setup layout
	my $v_box = Gtk2::VBox->new();
	$v_box->pack_end($self->{_guide}, TRUE, FALSE, 0);
	
	# Load the image.
	my $img_load = Gtk2::Gdk::PixbufLoader->new();
	open(IMG, "< " . $self->{_img});
	my $image_data = "";
	while(<IMG>){
		$image_data = $image_data . $_;
	}
	$img_load->write($image_data);
	$img_load->close();
	my $img_obj = $img_load->get_pixbuf();
	
	my $width = $img_obj->get_width;
	my $height = $img_obj->get_height;
	
	# Code adapted from http://www.perlmonks.org/?node_id=583578
	my $scwin = Gtk2::ScrolledWindow->new();
	my $ha1  = $scwin->get_hadjustment;
	$scwin->set_policy('always','never');
	
	my $vp = Gtk2::Viewport->new (undef,undef);
	$scwin->add($vp);
	$v_box->pack_start($scwin,1,1,0);
	
	my $area = new Gtk2::DrawingArea;
	$area->size ($width + 50, $height + 50);
	$vp->add($area);
	
	$area->set_events ([qw/exposure-mask
	         	       leave-notify-mask
			       button-press-mask
			       pointer-motion-mask
			       pointer-motion-hint-mask/]);

	$area->signal_connect (
		button_press_event => sub { 
			my $widget = shift;
			my $event = shift;
			# If they clicked normally
			if ($event->button == 1) {
				print join ' ', $event->coords,"\n";
				my ($x, $y) = $event->coords;
				$self->log($x, $y);
			}
			return TRUE;
		});
	
	$self->{_window}->add($v_box);
	$self->{_window}->resize($width, $height + 50);
	$self->{_window}->show_all();
	
	my $pixmap = Gtk2::Gdk::Pixmap->new(
			$area->window,
			$area->allocation->width,
			$area->allocation->height, -1
		);
	$pixmap->draw_pixbuf(
			$area->style->white_gc,    # or black_gc
			$img_obj,
			0, 0,
			0, 0,
			$width,
			$height,
			'none',
			0, 0
		);
	my $gc = Gtk2::Gdk::GC->new( $pixmap );
	my $colormap = $pixmap->get_colormap;
	$area->window->set_back_pixmap ($pixmap,0);
}

sub log {
	my $self = shift;
	my $x = shift;
	my $y = shift;
	$self->{_cur} = $self->{_cur} + 1;
	$self->{_log} = $self->{_log} . $x . " " . $y;
	if($self->{_cur} eq "4"){
		open(MCLICK, ">> ./temp/clicks.log");
		print MCLICK $self->{_log} . "\n";
		close(MCLICK);
		$self->destroy();
		$self->{_parent}();
		return;
	}else{
		$self->{_log} = $self->{_log} . " ";
		$c = $self->{_cur};
		if($c eq "1"){
			$self->{_guide}->set_text("Click where the upper right corner goes");
		}elsif($c eq "2"){
			$self->{_guide}->set_text("Click where the lower left corner goes");
		}else{
			$self->{_guide}->set_text("Click where the lower right corner goes");
		}
	}
}

sub working {
	my $self = shift;
	return $self->{_working};
}

sub destroy {
	my $self = shift;
	$self->{_window}->destroy();
	$self->{_working} = FALSE;
}
1;