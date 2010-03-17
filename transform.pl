#!/usr/bin/perl

use Gtk2 '-init';

# Create our Window
$window = Gtk2::Window->new('toplevel');
$window->set_title("Video Transfomer - Control Window");
$window->signal_connect('delete-event' => sub{ Gtk2->main_quit });

# Add a quit button
$button = Gtk2::Button->new("Quit");
$button->signal_connect('clicked' => sub{ Gtk2->main_quit });

$window->show_all;

Gtk2->main;

0;