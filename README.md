CAHMaker
========

A little app I made that takes a text file and builds "Cards Against Humanity" cards from
it as individual PNG files on your desktop, ready for printing via a service like Moo.com
or MeinSpiel.de.

Usage
-----

Drag a text file on the built application and it will show you each card in that text
file rendered like a real CAH card. Choose "Build All Images" from the "File" menu to
have it generate PNG files for each card and for card backs on your *Desktop*.

The file must have a format like the cards_against_gallifrey.txt example file.


Card Text File Format
---------------------

It should be enough to look at the cards_against_gallifrey.txt example file, but in case
you need more info:

Each card starts with 'WHITE' or 'BLACK' on a line of its own, indicating the card's color.
Then follow the lines of text for this card. An empty line denotes the end of the current
card (i.e. cards are separated by one or more empty lines).

Two special 'fake cards' define the backs of the cards. These have the colors 'BLACK-BACK'
and 'WHITE-BACK'. The last line of this card is colored blue. The text on the back of the
card is also printed as a single line at the bottom of the front of each card. Usually,
you write the name of the game (e.g. "Cards against Humanity" or whatever) on the backs of
the cards, but one could also denote the kind of card here for another game, like
"Action card" or so.


License
-------

	Copyright 2013 by Uli Kusterer.
	
	This software is provided 'as-is', without any express or implied
	warranty. In no event will the authors be held liable for any damages
	arising from the use of this software.
	
	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:
	
	   1. The origin of this software must not be misrepresented; you must not
	   claim that you wrote the original software. If you use this software
	   in a product, an acknowledgment in the product documentation would be
	   appreciated but is not required.
	
	   2. Altered source versions must be plainly marked as such, and must not be
	   misrepresented as being the original software.
	
	   3. This notice may not be removed or altered from any source
	   distribution.
