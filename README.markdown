The Go Text Protocol
====================

This library wraps [GNU Go](http://www.gnu.org/software/gnugo/)'s version of the Go Text Protocol or GTP.  It runs GNU Go in a separate process and communicates with the program over a pipe using the GTP protocol.  This makes it easy to:

* Manage full games of Go
* Work with SGF files
* Analyze Go positions

Examples
--------

This code would load an SGF file and show the current state of the game in that file:

    require "go/gtp"
    
    go = Go::GTP.run_gnugo
    go.loadsgf("game.sgf") or abort "Failed to load file"
    puts go.showboard
    go.quit

This shows the two main types of GTP methods.  Methods like `showboard()` return the indicated content.  In this case, you actually get back a `Go::GTP::Board` object which can indexed into, or just converted into a `String` for display as it is used here.

Other methods, like `loadsgf()`, are just called for their side effects and they don't return anything.  For these, you get a boolean result telling you if the call succeeded (`true`) or triggered an error (`false`).  You can always check the `success?()` of either type of call after the fact and retrieve the `last_error()` when there is one, so these return values are just a convenience.  As another convenience, these boolean methods can be called with Ruby's query syntax as well:  `loadsgf?()`.

When working with a GNU Go process, it's a good idea to remember to call `quit()` so the pipe can be closed.  One way to ensure that happens is to use the block form of `run_gnugo()` to have it done for you.  Given that, the following example is another way to handle loading and displaying a game:

    require "go/gtp"
    
    Go::GTP.run_gnugo do |go|
      go.loadsgf?("game.sgf") or abort "Failed to load file"
      puts go.showboard
    end  # quit called automatically after this block

You can customize how GNU Go is invoked, by passing parameters to `run_gnugo()`.  Probably the two most useful are the `:directory` where the executable lives and any `:arguments` you would like to pass it.  For example:

    require "go/gtp"
    
    go = Go::GTP.run_gnugo( directory: "/usr/local/bin",
                            arguments: "--boardsize 9" )
    # ...

Of course, you could also set the board size after the connection is open with `go.boardsize(9)`.

See the [example directory](http://github.com/JEG2/go_gtp/tree/master/example/) for more ideas about how to use this library.

GTP Commands
------------

The method names are literally the command names right out of [the GTP documentation](http://www.gnu.org/software/gnugo/gnugo_19.html#SEC200).  That's intended to make it easy to figure out what you can do with this library.  Return values are Rubified into nice objects, when it makes sense to do so.
