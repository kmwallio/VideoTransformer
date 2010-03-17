#!/usr/bin/perl

use Gtk2 '-init';

# Create our Window
my $window = Gtk2::Window->new('toplevel');
$window->set_title("Video Transfomer - Control Window");
$window->signal_connect('delete-event' => sub{ Gtk2->main_quit });

# Add a quit button
my $quit_b = Gtk2::Button->new("Quit");
$quit_b->signal_connect('clicked' => sub{ Gtk2->main_quit });

# Bottom menu buttons
my $menu_b = Gtk2::HBox->new();

$menu_b->pack_start($quit_b, TRUE, TRUE, 0); 

$window->add($menu_b);
$window->show_all;

Gtk2->main;

0;