#!/usr/bin/perl

use Gtk2 '-init';

# Create our Window
my $window = Gtk2::Window->new('toplevel');
$window->set_title("Video Transfomer - Control Window");
$window->signal_connect('delete-event' => sub{ Gtk2->main_quit });

# General layout thing
my $pane = Gtk2::VBox->new();
	
	# File choosers...
	my $chooser = Gtk2::HBox->new();
	
	my $frm_open_dest = Gtk2::Frame->new('Gtk2::FileChooserButton');
	
	my $dest = Gtk2::VBox->new();
	my $source = Gtk2::VBox->new();
	
	my $lbl_dest = Gtk2::Label->new('No Destination File');
	my $lbl_source = Gtk2::Label->new('No Source File');
	
	my $open_dest = Gtk2::FileChooserButton('Select Destination Video', 'open');
	my $open_source = Gtk2::FileChooserButton('Select Source Video', 'open');
	
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
$window->show_all;

Gtk2->main;
0;