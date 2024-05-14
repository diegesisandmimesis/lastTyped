#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 jbg
//
// This is a very simple demonstration "game" that illustrates the
// functionality of the lastTyped library
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>
#include "lastTyped.h"

versionInfo:    GameID
        name = 'lastTyped Library Demo Game'
        byline = 'jbg'
        desc = 'Demo game for the lastTyped library. '
        version = '1.0'
        IFID = '12345'
	showAbout() {
		"This is a simple test game that demonstrates the features
		of the lastTyped library.
		<.p>
		You can type >X PEBBLE versus >L AT PEBBLE to see the
		verb canonicalization in action.
		<.p>
		You can also type >X PEBBLE versus >X STONE to see the
		noun matching.  Alternate between using each noun
		several times in a row to see the most used term change.
		<.p>
		In-game that's pretty much all there is to it.  Consult the
		README.txt document distributed with the library source for
		a quick summary of how to use the library in your own games.
		<.p>
		The library source is also extensively commented in a way
		intended to make it as readable as possible. ";
	}
;

// Our game world is just a single room
startRoom:      Room 'Void'
        "This is a featureless void. "
;
// This pebble declaration contains almost all of the things in the
// library that you can use as a game author.
+ Thing 'small round pebble/stone/rock' 'pebble'
	// The description contains all of the message param substitution
	// strings added by the library:
	// {verb} for the canonical verb
	// {last/it} for the matching form of the noun typed by the player
	//	in the current command
	// {most/it} for the most common matching noun used for the object
	//	by the player
	"You just tried to <q>{verb}</q> the <q>{last/it dobj}</q>.
	\nThe most frequently used term for this object has been
	<q>{most/it dobj}</q>. "

	// The list of matching nouns for this object.
	//
	// In this case we just use the object's noun property, which
	// is automagically set from the vocabulary in the object
	// declaration.  This approach should work in most cases, assuming
	// your object declarations are well-behaved.
	lastTypedNounList = noun
;
// This object is mostly the same as the above, only we change the way
// we declare the lastTypedNounList list.
+ Thing 'flat deflated tire/tyre/wheel/thingy' 'flat thingy'
	"<<_debug()>> "

	// In this case we supply our own list to lastTypedNounList.
	// This means that we can refer to this object in ways that
	// won't match.  If you try to >X WHEEL, {last} will always
	// display "flat thingy" (the object's name property,
	// here something slightly silly to highlight the fact that it's
	// not any of the nouns in the object's grammar) and {most}
	// will remain the most-commonly used element of
	// the lastTypedNounList (and not "flat thingy").
	lastTypedNounList = static [ 'tire', 'tyre' ]

	_debug() {
		"You just tried to <q>{verb}</q> the <q>{last/it dobj}</q>.
		\nThe most frequently used term for this object has been
		<q>{most/it dobj}</q>. ";
	}

	dobjFor(Take) { action() { _debug(); inherited(); } }
	dobjFor(Drop) { action() { _debug(); inherited(); } }
;
// This object is mostly for testing different verbs (the dobjFor() method
// below will catch all actions directed at the object).
// We also intentionally don't define the lastTypedNounList property, to
// illustrate the fallback behaviour of {last} and {most}.
+ Thing 'widget' 'widget'
	"Placeholder. "
	dobjFor(Default) {
		action() {
			"You just tried to <q>{verb}</q> the
			<q>{last/it dobj}</q>.
			\nThe most frequently used term for this object has
			been <q>{most/it dobj}</q>. ";
		}
	}
;

modify playerMessages
	// Replace the generic allNotAllowed() message with a slightly
	// more responsive form.  Type >SMELL ALL to test this.
        allNotAllowed(actor) {
		"<.parser>
		{You/he} can only {verb} one thing at a time.
		<./parser> ";
        }
;

me:     Person
        location = startRoom
;

gameMain:       GameMainDef
        initialPlayerChar = me
	// We disallow "all" by default so we can test allNotAllowed()
	// above.
        allVerbsAllowAll = nil
;
