#!/usr/bin/perl

use Gtk2 '-init';

# Create our Window
$window = Gtk2::Window->new('toplevel');
$window->set_title("Video Transfomer");

# Add a quit button
$button = Gtk2::Button->new("Quit");

$window->show_all;

Gtk2->main;

0;