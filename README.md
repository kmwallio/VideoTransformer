# VideoTransformer

This will take one source video and overlay it atop another video.  It does this for every frame.

## Installation

Just download and run `perl transform.pl`

To put the frames into a video file, run:

> mencoder "mf://./*.jpg" -mf fps=15 -ovc lavc -lavcopts vcodec=mpeg4 -o video.mpeg

Change the fps to the input's fps.

To convert to an mp4, run:

> ffmpeg -i video.mpeg -f mp4 video.mp4

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
	* ImageMagick (use for opening images, and not to solve the problem)

## Installation (Detailed)

### Mac OS X

Download and install [MacPorts](http://www.macports.org/ "Mac Ports").  Then run the following (it'll install more than needed, but yeah...).

> sudo port install p5-gtk\*  
> sudo port install p5-pdl  
> sudo port install imagemagick +perl  
> sudo port install mplayer  
> sudo port install ffmpeg
> sudo port upgrade --enforce-variants perl5.8 +threads

if on Snow Leopard, use mplayer-devel.

For nicer themes:

> sudo port install gtk-chtheme  
> sudo port install gtk2-aurora

### Linux

Depending on your distro, install the GTK2-Perl package...  Debian, Fedora, Ubuntu, and etc make it easy.  Just search the repos.  Other wise, [this link](http://live.gnome.org/GTK2-Perl/FrequentlyAskedQuestions#Downloading.2C_Building.2C_Installing_Gtk2-Perl) should hopefully help...

Also install the mplayer and ffmpeg binaries for your system.

### Windows

[This link](http://live.gnome.org/GTK2-Perl/FrequentlyAskedQuestions#Downloading.2C_Building.2C_Installing_Gtk2-Perl) should help if using ActiveState or StrawberryPerl, alternatively, try [Camelbox](http://code.google.com/p/camelbox/ "Camelbox - Perl for Windows").

This program might not work on Windows for a while though...

## Known Issues...

* The progress bar lingers at 99% for a while.  That's what we're told by MPlayer, so that's what we go with...
* Create a "temp" directory in the same folder as transform.pl
* Expects the destination and source videos to have the same frame rate