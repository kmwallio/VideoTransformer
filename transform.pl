#!/usr/bin/perl

use strict;
use Gtk2 '-init';
use Glib qw/TRUE FALSE/;

# Create our Window
my $window = Gtk2::Window->new('toplevel');
$window->set_title("Video Transfomer - Control Window");
$window->signal_connect('delete-event' => sub{ Gtk2->main_quit });

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
	# Add our buttons
	$menu_b->pack_start($quit_b, TRUE, TRUE, 0); 

$pane->pack_start($chooser, TRUE, TRUE, 0);
$pane->pack_end($menu_b, TRUE, FALSE, 0);

# Compose and show the window.
$window->add($pane);
$window->show_all();

Gtk2->main();

sub choose_file {
	my ($prompt, $type, $where) = @_;
	# Create a new file chooser dialog
	my $file_chooser = Gtk2::FileChooserDialog->new(
								$prompt,
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
	}
	
	$file_chooser->destroy();
	
	if ($where eq 'source'){
		$source_file = $fname;
		if ($source_file =~ m/\/(.*?)\./){
			$lbl_source->set_text($1);
		}else{
			$lbl_source->set_text("No File Selected");
		}
	}else{
		$dest_file = $fname;
		if ($dest_file =~ m/\/(.*?)\./){
			$lbl_dest->set_text($1);
		}else{
			$lbl_dest->set_text("No File Selected");
		}
	}
	return;
}

sub filter_movie{
	my $filter = Gtk2::FileFilter->new();
	$filter->set_name("Videos");
	$filter->add_mime_type("video/quicktime");
	$filter->add_mime_type("video/mpeg");
	$filter->add_mime_type("x-msvideo");
	return $filter;
}
