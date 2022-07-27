#charset "us-ascii"
//
// lastTypedNoun.t
// Version 1.0
// Copyright 2022 jbg
//
//	Determine what noun the player used to refer to an object.
//	Normally TADS/adv3 doesn't care what exact words the player uses
//	to refer to an object as long as they are unambiguous.  So if we have
//	an object defined something like:
//
//		+ pebble: Thing 'small round pebble/stone/rock' 'pebble'
//			"It's a small, round pebble. "
//		;
//
//	Then >X PEBBLE, >X STONE, or even >X ROUND (assuming there are
//	no other round objects in scope) will be treated interchangeably.
//
//	The purpose of the the code below is to allow a game author to
//	determine how the player actually referred to an object in a given
//	command, and to keep track of how often they use different terms
//	for the same object.
//
//	From an implementation standpoint, the main additional coding
//	requirement is to add a lastTypedNounList property to each object
//	that needs to use the library's functionality.
//
//	lastTypedNounList needs to be a list, and if the player's input doesn't
//	match any string in the list then the library will use the object's
//	name property instead.
//
//	This library is distributed under the MIT License, see LICENSE.txt
//	for details.
//
#include <adv3.h>
#include <en_us.h>
#include "lastTyped.h"

#ifndef NO_LAST_TYPED_NOUN

modify Thing
	// lastTypedNounList must be either nil or a list.  If it is nil, then
	// the library will always treat the object's defined name property
	// as if it was what the player typed.
	//
	// A simple way to define lastTypedNounList is to just set it to
	// be the object's noun property, like:
	//
	//	pebble: Thing 'small round pebble/stone/rock' 'pebble'
	//		"This is a small, round pebble. "
	//		lastTypedNounList = noun
	//	;
	//
	// In this case this is equivalent to using:
	//
	//	lastTypedNounList = static [ 'pebble', 'stone', 'rock' ]
	//
	// This is the only bit that game implementors should have to fiddle
	// with directly.
	lastTypedNounList = nil

	// _lastTypedNoun the last matching noun used for this object, or
	// nil if the player's input didn't match any noun in our
	// lastTypedNounList.
	//
	// This value is set automagically by the library;  it should not be
	// set by game implementors.
	_lastTypedNoun = nil

	// _lastTypedNounStats will hold a LookupTable containing counts for
	// all of the matching nouns used for this object, if stat keeping
	// is not disabled.
	//
	// This value is set automagically by the library;  it should not be
	// set by game implementors.
	_lastTypedNounStats = nil


	// Misfeature?  If we have a resolved typed noun we use it, otherwise
	// we return the plain ol' name.  Done so we can use lastTypedName()
	// without having to do any conditional nonsense, but maybe we
	// shouldn't.
	//
	// It is safe for game implementors to call obj.lastTypedNoun()
	// in game code, although if the value is being used for output
	// it may be easier to use message parameter substitution to
	// get the value:  "{You/he} take{s} the {last/it dobj}. " instead
	// of "{You/he} take{s} the <<dobj.lastTypedNoun()>>. ", for
	// example.
	lastTypedNoun = (_lastTypedNoun ? _lastTypedNoun : name)

	// If we're collecting stats, return the matching noun most
	// frequently used to refer to this object.
	// If we fail for any reason, we fall back on returning
	// lastTypedNoun instead.
	//
	// Like with lastTypedNoun(), mostTypedNoun() is safe for game
	// implementors to call directly.  And once again if the value is
	// being used for output it may be simpler to use message parameter
	// substitution:  "{You/he} take{s} the {most/it dobj}. "
	mostTypedNoun() {
#ifndef LAST_TYPED_NOUN_STATS
		// If we're being compired without stat support, we
		// return lastTypedNoun().  Misfeature?  Maybe it makes more
		// sense to always return self.name instead?
		return(lastTypedNoun);
#else // LAST_TYPED_NOUN_STATS
		local max, r;

		// If we've somehow contrived to be called before we have
		// any stats, then we return lastTypedNoun().  This should
		// degrade gracefully, as it'll fall back to self.name
		// if the player has never referred to us.
		if(!_lastTypedNounStats) return(lastTypedNoun);

		// Figure out which term has been used the most frequently.
		max = 0;
		_lastTypedNounStats.forEachAssoc(function(k, v) {
			if(v > max) {
				max = v;
				r = k;
			}
			// If we have a tie, then prefer the most recently
			// used term.
			if((v == max) && (k == lastTypedNoun))
				r = lastTypedNoun;
		});
		if(!r) return(lastTypedNoun);
		return(r);
#endif // LAST_TYPED_NOUN_STATS
	}

	// Add the passed term to our stats.
	//
	// There's an "Employees Only" sign over this method:  as a game
	// implementor you probably won't need to fiddle with this unless
	// you're trying to change the way the library itself behaves.
	_countCanonicalNoun(v) {
#ifndef LAST_TYPED_NOUN_STATS
		// Fail gracefully if we've been compiled without stat support
		return;
#else // LAST_TYPED_NOUN_STATS
		local l;

		// If we don't have a list of matching nouns then we don't
		// have anything to count, so we immediately bail.
		if(!lastTypedNounList || !lastTypedNounList.ofKind(List))
			return;

		// Create the LookupTable to hold the stats if it doesn't
		// already exist.
		l = _lastTypedNounStats;
		if(!l) {
			_lastTypedNounStats = new LookupTable();
			l = _lastTypedNounStats;
			// Initialize the count for each noun in the list
			lastTypedNounList.forEach(function(o) { l[o] = 0; });
		}

		// We only count matching nouns, so if we don't have the
		// passed arg as a key in the table, bail.
		if(!l.isKeyPresent(v))
			return;

		// If we reach this point we're good to go;  count the
		// use.
		l[v] += 1;
#endif // LAST_TYPED_NOUN_STATS
	}

	// Attempt to determine which, if any, bits of the passed list
	// represent a matching noun referring to this object.
	//
	// This is probably not something you need to worry about as an
	// implementor.
	_getCanonicalNoun(lst) {
		local i, j;

		// If we don't have a noun list defined then we
		// have nothing to do; bail.
		if(!lastTypedNounList || !lastTypedNounList.ofKind(List))
			return(nil);

		// Go through the list we were passed as an arg and see
		// if any element of that list matches our noun list.
		// We never attempt to do any elaborate disambiguation,
		// just return the first match we encounter.
		for(j = 1; j <= lst.length(); j++) {
			for(i = 1; i <= lastTypedNounList.length(); i++) {
				if(lastTypedNounList[i].find(lst[j]) != nil)
					return(lastTypedNounList[i]);
			}
		}

		// Oh no, we didn't get a match.  Return nil.
		return(nil);
	}
	// Used by matchName() and matchNameDisambig(), this is called
	// pretty much any time the object is referenced.
	//
	// This is the main point of contact between this library and the
	// stock adv3 stuff.
	//
	// As a game implementor, you almost certainly will never have to
	// fiddle with this unless you're modifying the library or something
	// along those lines.
	matchNameCommon(origTokens, adjustedTokens) {
		local l;

		// If we don't have a noun list, we
		// have nothing to do, so we immediately bail.
		if(!lastTypedNounList)
			return(inherited(origTokens, adjustedTokens));

		// Get a list of everything in the token list that's
		// a string.
		l = [];
		adjustedTokens.forEach(function(o) {
			if(dataTypeXlat(o) == TypeSString) l += o;
		});

		// Run the list of strings we just constructed through
		// our noun canonicalizer.
		_lastTypedNoun = _getCanonicalNoun(l);

		// Pass our canonical noun to our canonical noun counter.
		_countCanonicalNoun(_lastTypedNoun);

		// Do whatever else we might've done otherwise.
		return(inherited(origTokens, adjustedTokens));
	}
;

#else // NO_LAST_TYPED_NOUN

// Just a few stubby little things so we fail gracefully when compiled without
// noun support.
modify Thing
	lastTypedNounList = nil
	lastTypedNoun = name
	mostTypedNoun = name
;

#endif // NO_LAST_TYPED_NOUN
