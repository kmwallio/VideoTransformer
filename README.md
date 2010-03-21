# VideoTransformer

This will take one source video and overlay it atop another video.  It does this for every frame.

## Installation

Just download and run `perl transform.pl`

## Requirements

* mplayer
* ffmpeg
* Perl
* GTK2-Perl
* Perl Modules \(in [CPAN](http://www.cpan.org/ "CPAN")\):
	* GD
	* Gtk2 (GTK2-Perl)
	* GStreamer
	* Math

## Installation (Detailed)

### Mac OS X

Download and install [MacPorts](http://www.macports.org/ "Mac Ports").  Then run the following (it'll install more than needed, but yeah...).

> sudo port install p5-gtk*  
> sudo port install p5-math*  
> sudo port install p5-gd*

For nicer themes:

> sudo port install gtk-chtheme  
> sudo port install gtk2-aurora

### Linux

Depending on your distro, install the GTK2-Perl package...  Debian, Fedora, Ubuntu, and etc make it easy.  Just search the repos.  Other wise, [this link](http://live.gnome.org/GTK2-Perl/FrequentlyAskedQuestions#Downloading.2C_Building.2C_Installing_Gtk2-Perl) should hopefully help...

### Windows

[This link](http://live.gnome.org/GTK2-Perl/FrequentlyAskedQuestions#Downloading.2C_Building.2C_Installing_Gtk2-Perl) should help if using ActiveState or StrawberryPerl, alternatively, try [Camelbox](http://code.google.com/p/camelbox/ "Camelbox - Perl for Windows").