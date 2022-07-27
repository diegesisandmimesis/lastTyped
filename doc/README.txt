
lastTyped
Version 1.0
Copyright 2022 jbg, distributed under the MIT License



ABOUT THIS LIBRARY

The lastTyped library is simple library for keeping track of
the specific nouns and verbs used in a typed command, and for
coverting them, if necessary, into a form suitable for output.

A simple example to illustrate:

	pebble: Thing 'small round pebble/stone/rock' 'pebble'
		"You used the verb <q>{verb}</q> on the <q>{last/it dobj}</q>. "
		lastTypedNounList = noun
	;

If the player typed >X PEBBLE, it would output:

	You used the verb "examine" on the "pebble".

If the player typed >L AT SMALL ROCK, it would output:

	You used the verb "look at" on the "rock".

...and so on.

In addition, by default the library keeps track of how often each noun
is used in referring to an object, and can output noun used most frequently.
An example:

	pebble: Thing 'small round pebble/stone/rock' 'pebble'
		"You used the verb <q>{verb}</q> on the <q>{last/it dobj}</q>.
		\nThe most frequently used term for this object has been
		<q>{most/it dobj}</q>. "
		lastTypedNounList = noun
	;

That would work like:

	> X PEBBLE

	You used the verb "examine" on the "pebble".
	The most frequently used term for this object has been "pebble".

	> L AT PEBBLE

	You used the verb "look at" on the "pebble".
	The most frequently used term for this object has been "pebble".

	> X STONE

	You used the verb "examine" on the "stone".
	The most frequently used term for this object has been "pebble".

	> X STONE

	You used the verb "examine" on the "stone".
	The most frequently used term for this object has been "stone".

...and so on.

In terms of writing game code using this, all that's really needed is
for the lastTypedNounList property to be defined on the object.

If the lastTypedNounList property is NOT defined/is nil, then both
{last/it} and {most/it} will aways return the object's name property.

In most cases you can just set lastTypedNounList to be the object's noun
property.  You can also declare an explicit list of nouns to use instead,
like:

	pebble: Thing 'small round pebble/stone/rock' 'pebble'
		"You used the verb <q>{verb}</q> on the {last/it dobj}. "
		lastTypedNounList = static [ 'pebble', 'stone', 'rock' ]
	;

In this case this is equivalent to using

		lastTypedNounList = noun

...because of the vocabulary used in the object declaration.  You can
also do something like

		lastTypedNounList = static [ 'pebble', 'stone' ]

...if you wanted the {last/it} and {most/it} to not keep track of when
the player referred to the object as a "rock".

That's pretty much it.



EXPANDING/MODIFYING THIS LIBRARY

Using new objects/Things with this library is as simple as defining the
lastTypedNounList for the object.

Using new verbs/Actions with this library is similar but slightly more
complicated.  In general a verb with no abbreviations will work without
any modification.

Verbs with abbreviations (like "x" for "examine" and "l" for "look") need
to have a _canonicalVerb property defined on their Action in order to
work.  Examples can be found in lastTypedVerb.t.  He's what we do
for ExamineAction:

	modify ExamineAction
		_canonicalVerb = static [ 'x' -> 'examine', 'l' -> 'look' ];
		
This tells the library that when the player uses "x" as a verb, that we
want to expand that to be "examine" and when they use "l" we want it to
become "look".

That's the most elaborate case:  where there are multiple abbreviations for
a single Action.  In other cases just defining _canonicalVerb to be a
string works.  You can see this in LookInAction:

	modify LookInAction _canonicalVerb = 'look';

This is because both >LOOK IN BOX and >L IN BOX are valid, and we always
want to use "look".

To reiterate:  defining _canonicalVerb on an Action is generally only needed
if there's an abbreviated form of the verb defined.  And if an Action has
an abbreviation and there's no _canonicalVerb defined, then all that will
happen is {verb} will resolve to the abbreviation:  "You {verb} the object."
becomes "You x the object." instead of "You examine the object."



LIBRARY CONTENTS

The source code is pretty thoroughly commented, so if you want to know
more about what's going on under the hood that's where to look.

The files in the library are:

	lastTyped.h
		A header file, containing all the #defines.

		You can enable and disable library features by commenting or
		uncommenting the various #define statements, as documented
		in the file itself.

		You need to add...

			#include "lastTyped.h"
		
		To all the source files that use the library.

	lastTypedMessageBuilder.t
		This file contains all the code that defines message
		parameter substitution strings for the library.

	lastTypedNoun.t
		This file contains all the noun-related code.

	lastTyped.t
		This file just contains the module ID for the library.

	lastTyped.tl
		This is the library file for the library.

	lastTypedVerb.t
		This file contains all the verb-related code.

	LICENSE.txt
		This file contains a copy of the MIT License, which is
		the license this library is distributed under.

	demo/makefile.t3m
		The makefile for the sample "game" provided with the
		library.

	demo/sample.t
		A sample "game" illustrating the library functionality.

	doc/README.txt
		This file.

