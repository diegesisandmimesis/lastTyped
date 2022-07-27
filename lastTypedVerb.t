#charset "us-ascii"
//
// lastTypedVerb.t
// Version 1.0
// Copyright 2022 jbg
//
//	Save the verb typed by the player.  The saved verb is accessible
//	via gVerb and the {verb} message parameter substitution.
//	
//	For non-abbreviated verbs this should be the full verb/verb phrase
//	typed by the player.  I.e., if the player types:
//
//	> SMELL ALL
//
//	...this will result in gVerb and "{verb}" returning "smell".
//
//	When an abbreviation is used, we attempt to figure out the canonical
//	form of the abbreviated verb.  I.e.:
//
//	> X ME
//
//	...will get "examine", and...
//
//	> L AT ME
//
//	...will get "look at".
//
//	This library is distributed under the MIT License, see LICENSE.txt
//	for details.
//
#include <adv3.h>
#include <en_us.h>
#include "lastTyped.h"

// Object to hold the canonical form of the verb after we figure it out.
// lastTyped.h has a #define to point gVerb to this object.
lastTypedVerb: object
	_verb = "deadbeef"		// the resolved verb
	get() { return(_verb); }
	set(v) { _verb = v; }
;

#ifndef NO_LAST_TYPED_VERB

// Add canonical verbs for actions that accept abbreviations.
//
// Here we go through and define a _canonicalVerb property on all actions
// that have abbreviations.
//
// _canonicalVerb can be:
//	a string, in which case the string will always be used
//	a list, in which case the library will look through each element of
//		the list and see if the player's input matches the start
//		of any input and if so, pick it.  So >L AT PEBBLE would
//		match _canonicalVerb = static [ 'examine', 'look' ] because
//		"look" starts with "l".
//	a lookup table, in which case the library will use the player's input
//		as a key and return the corresponding value in the table.
//		So >X PEBBLE will match
//		_canonicalVerb = static [ 'x' -> 'examine', 'l' -> 'look' ]
//		because "x" is a key in the table, so the library would
//		pick "examine".
//
// Barring any oversights, the block of modify statements below should cover
// all of the default verbs in adv3.  Additional verbs can be added by
// following the same format, either by adding them below or in a specific
// game's source files.
modify ExamineAction
	_canonicalVerb = static [ 'x' -> 'examine', 'l' -> 'look' ];
modify LookInAction _canonicalVerb = 'look';
modify LookThroughAction _canonicalVerb = 'look';
modify LookUnderAction _canonicalVerb = 'look';
modify LookBehindAction _canonicalVerb = 'look';
modify AskForAction _canonicalVerb = 'ask';
modify AskAboutAction _canonicalVerb = 'ask';
modify TellAboutAction _canonicalVerb = 'tell';
modify InventoryAction _canonicalVerb = 'inventory';
modify InventoryWideAction _canonicalVerb = 'inventory';
modify WaitAction _canonicalVerb = 'wait';
modify LookAction _canonicalVerb = 'look';
modify AgainAction _canonicalVerb = 'again';
modify TravelAction
	_canonicalVerb = static [ 'n' -> 'north', 's' -> 'south',
	'e' -> 'east', 'w' -> 'west', 'u' -> 'up', 'd' -> 'down',
	'nw' -> 'northwest', 'ne' -> 'northeast', 'sw' -> 'southwest',
	'se' -> 'southeast', 'p' -> 'port', 'sb' -> 'starboard' ];

modify Action
	// Our string/list/lookup table containing the canoncial verb(s) for
	// this action.
	//
	// This is something you almost certainly shouldn't fiddle with here;
	// the value for individual actions should be set in the instance/class
	// declaration, as shown in the block of modify statements above.
	_canonicalVerb = nil

	// Attempt to determine what, if anything, the arg abbreviates.
	//
	// This is probably not a method game implementors will need to fiddle
	// around with directly.
	_getCanonicalVerb(v) {
		local i;

#ifdef __DEBUG_LAST_TYPED_VERB
		"_getCanonicalVerb(<<if v>><<v>><<else>>nil<<end>>)\n ";
#endif // __DEBUG_LAST_TYPED_VERB
		// nil in, nil out
		if(v == nil) return(nil);

		if(_canonicalVerb.ofKind(List)) {
			// If we have a list, we try to find an element that
			// starts with our arg.
#ifdef __DEBUG_LAST_TYPED_VERB
			"\tUsing List\n ";
#endif // __DEBUG_LAST_TYPED_VERB
			// If we have a list, see if any of them start with
			// our arg, and return that list element if it does.
			for(i = 1; i <= _canonicalVerb.length(); i++) {
				if(_canonicalVerb[i].startsWith(v))
					return(_canonicalVerb[i]);
			}
			// We have a list but no match, punt.
			return(_canonicalVerb[1]);
		} else if(_canonicalVerb.ofKind(LookupTable)) {
			// If we have a LookupTable, see if our arg is
			// a key in it.  If it is, return the value for
			// that key.
#ifdef __DEBUG_LAST_TYPED_VERB
			"\tUsing LookupTable\n ";
#endif // __DEBUG_LAST_TYPED_VERB
			if(_canonicalVerb.isKeyPresent(v))
				return(_canonicalVerb[v]);

			// We didn't find our arg in the table, so just
			// return the arg.
			return(v);
		}

#ifdef __DEBUG_LAST_TYPED_VERB
		"\tUsing string\n ";
#endif // __DEBUG_LAST_TYPED_VERB
		// If we reached this point then we have a single value
		// for the _canonicalVerb, so we just return it.
		return(_canonicalVerb);
	}
	// Get the verb used in this action, prefering what the player actually
	// typed unless we can't resolve that into something useful.
	//
	// In principle this is safe for you to use as a game implementor,
	// but you probably won't need to.
	getCanonicalVerb() {
		local isNoun, match, prop, i, toks, txt, v;

		// Prefer the original tokens if that's not what we already have
		if(getOriginalAction() != self)
			return(getOriginalAction().getCanonicalVerb());
		toks = getPredicate().getOrigTokenList();

		// Now we go through the token list and record everything
		// that isn't part of a noun phrase.
		txt = nil;
		for(i = 1; i <= toks.length(); i++) {
			isNoun = nil;
			// Walk through all the noun phrases
			foreach(prop in predicateNounPhrases) {
				match = self.(prop);
				// If we have a match, skip to the end of
				// this phrase.
				if(match && (i == match.firstTokenIndex)) {
					i = match.lastTokenIndex;
					isNoun = true;
					break;
				}
			}
			// This stretch of tokens isn't a noun phrase, so
			// we keep track of it.
			if(!isNoun) {
				v = getTokVal(toks[i]);
				// If the token is a single character and
				// we have a canonical verb(s) for this action,
				// try to canonicalize the token.
				if((v.length() < 3) && _canonicalVerb)
					v = _getCanonicalVerb(v);
				txt = (txt ? (txt + ' ') : '') + v;
			}
			
		}
		if(!txt || (txt.length() == 1) && _canonicalVerb)
			return(_getCanonicalVerb(txt));
		return(txt);
	}
	// This is the main point of contact between the library and adv3.
	//
	// We jump through hoops setting the value of the verb on an external
	// object (gVerb) instead of just assigning them to a property because
	// one of our use cases is getting the verb typed by the player in
	// standard library messages (i.e. playerMessages.allNotAllowed()),
	// and gAction is cleared by the time those messages are printed.
	resolveAction(issuingActor, targetActor) {
		lastTypedVerb.set(getCanonicalVerb());
#ifdef __DEBUG_LAST_TYPED_VERB
		"\tCanonical verb is <q><<gVerb>></q><.p> ";
#endif // __DEBUG_LAST_TYPED_VERB
		return(inherited(issuingActor, targetActor));
	}
;

#else // NO_LAST_TYPED_VERB

// Stub methods so we gracefully degrade when compiled without verb support
modify Action
	_getCanonicalVerb(v) { return(v); }
	getCanonicalVerb() { return(nil); }
;

#endif // NO_LAST_TYPED_VERB

// We define canonicalVerb() on Thing regardless of whether
// NO_LAST_TYPED_VERB was defined so message param substitution fails
// more gracefully.
//
// This is used by the message param substitution logic:  look in
// lastTypedMessageBuilder.t for where we're called from.
modify Thing
	canonicalVerb() {
		return(gVerb);
	}
;
