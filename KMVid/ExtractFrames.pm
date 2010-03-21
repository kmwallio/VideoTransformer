#!/opt/local/bin/perl

use Gtk2 '-init';
use Glib qw/TRUE FALSE/;
use POSIX qw(mkfifo);

package ExtractFrames;

sub new {
	my ($class, $video, $dest) = @_;
	my $window = Gtk2::Window->new('toplevel');
	my $title = "";
	if ($video =~ m/\/(.*)\/(.*)\.(.*)/){
		$title = $2 . "." . $3;
	}
	$window->set_title('Extracting: ' . $title);
	$window->set_border_width(15);
	my $self = {
		_video => $video,
		_dest => $dest,
		_window => $window,
		_done => FALSE
	};
	bless $self, $class;
	$self->{_window}->signal_connect('delete-event' => sub{ $self->destroy() });
	return $self;
}

sub start {
	my $self = shift;
	my $pBar = Gtk2::ProgressBar->new();
	$self->{_window}->add($pBar);
	$self->{_window}->resize(500, 100);
	$self->{_window}->show_all();
	
	
	$FIFO = './temp/' . $self->{_dest} .'.fifo';
	POSIX::mkfifo($FIFO, 0700);
	$pid = open(MP, '| mplayer -vo jpeg:quality=100:outdir=./temp/' . $self->{_dest} . ' -slave -quiet ' . $self->{_video} . ' > ' . $FIFO);
	my $got = 0;
	my $current = 0;
	syswrite(MP, "get_percent_pos\n");
	open(FIFOING, "< $FIFO");
	$not_done = FALSE;
	while($current < 100){
		$got = <FIFOING>;
		if($got =~ m/(.*)\=(.*)/){
			$current = int($2);
		}
		if($got =~ m/Exiting/i){
			$current = 100;
		}
		$pBar->set_fraction($current / 100.0);
		$pBar->set_text($current . '%');
		while (Gtk2->events_pending) {
			Gtk2->main_iteration;
		}
		Gtk2::Gdk->flush;
		syswrite(MP, "get_percent_pos\n");
	}
	close(FIFOING);
	unlink($FIFO);
	
	
	$self->{_done} = TRUE;
	$self->destroy();
}

sub continue {
	my $self = shift;
	return $self->{_done};
}

sub destroy {
	my $self = shift;
	$self->{_window}->destroy();
}
1;