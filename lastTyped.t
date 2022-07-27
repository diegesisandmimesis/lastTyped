#charset "us-ascii"
//
// lastTyped.t
// Version 1.0
// Copyright 2022 jbg
//
//	The lastTyped library is simple library for keeping track of
//	the specific nouns and verbs used in a typed command, and for
//	coverting them, if necessary, into a form suitable for output.
//
//	For example, the given object declaration:
//
//		pebble: Thing 'small round pebble/stone/rock' 'pebble'
//			"You used the verb <q>{verb}</q> on the
//				{last/it dobj}. "
//			lastTypedNounList = noun
//		;
//
//	If the player typed >X PEBBLE, it would output:
//
//		You used the verb "examine" on the pebble.
//
//	If the player typed >L AT SMALL ROCK, it would output:
//
//		You used the verb "look at" on the rock.
//
//	...and so on.
//
//
//	This library is distributed under the MIT License, see LICENSE.txt
//	for details.
//
#include <adv3.h>
#include <en_us.h>
#include "lastTyped.h"

lastTypedModuleID: ModuleID {
	name = 'lastTyped Library'
	byline = 'jbg'
	version = '1.0'
	listingOrder = 99
}
