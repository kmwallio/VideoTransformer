#!/usr/bin/perl

use Gtk2 '-init';

# Create our Window
my $window = Gtk2::Window->new('toplevel');
$window->set_title("Video Transfomer - Control Window");
$window->signal_connect('delete-event' => sub{ Gtk2->main_quit });

# General layout thing
my $pane = Gtk2::VBox->new();
	
	# File choosers...
	
	# Bottom menu buttons
	my $menu_b = Gtk2::HBox->new();
	# Add a quit button
	my $quit_b = Gtk2::Button->new("Quit");
	$quit_b->signal_connect('clicked' => sub{ Gtk2->main_quit });
	# Add our buttons
	$menu_b->pack_start($quit_b, TRUE, TRUE, 0); 

$pane->pack_end($menu_b, TRUE, FALSE, 0);

# Compose and show the window.
$window->add($pane);
$window->show_all;

Gtk2->main;
0;