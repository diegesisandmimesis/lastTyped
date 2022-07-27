#charset "us-ascii"
//
// lastTypedMessageBuilder.t
// Version 1.0
// Copyright 2022 jbg
//
//	Add some new message parameter substitution strings for use in
//	the library.
//
//	This library is distributed under the MIT License, see LICENSE.txt
//	for details.
#include <adv3.h>
#include <en_us.h>
#include "lastTyped.h"

modify MessageBuilder
	execBeforeMe = [ lastTypedMessageBuilder ]
;

lastTypedMessageBuilder: PreinitObject
	execute() {
		langMessageBuilder.paramList_
			= langMessageBuilder.paramList_.append(
				[ 'last/he', &lastTypedNoun, nil, nil, nil ]);
		langMessageBuilder.paramList_
			= langMessageBuilder.paramList_.append(
				[ 'last/she', &lastTypedNoun, nil, nil, nil ]);
		langMessageBuilder.paramList_
			= langMessageBuilder.paramList_.append(
				[ 'last/it', &lastTypedNoun, nil, nil, nil ]);

		langMessageBuilder.paramList_
			= langMessageBuilder.paramList_.append(
				[ 'most/he', &mostTypedNoun, nil, nil, nil ]);
		langMessageBuilder.paramList_
			= langMessageBuilder.paramList_.append(
				[ 'most/she', &mostTypedNoun, nil, nil, nil ]);
		langMessageBuilder.paramList_
			= langMessageBuilder.paramList_.append(
				[ 'most/it', &mostTypedNoun, nil, nil, nil ]);

		// IMPORTANT:
		//
		// This might be a misfeature.  We add a {verb} message
		// param substitution, but there's no way to automagically
		// twiddle the verb endings.
		// Normally in message param substitution you hardcode the
		// verb and when you do you can set up whatever substitution(s)
		// are correct for case and tense.  For example, something like:
		//	{You/he} look{s} around.
		// ...versus...
		//	{You/he} watch{es} the clock.
		// These work because the author is doing the heavy lifting.
		// When we're substituting some random verb typed by the
		// player there is no algorithmic way to determine what
		// ending is appropriate for the case and tense.  Or rather
		// an algorithm to do that is beyond the scope of this library.
		//
		// The design case for this is improving responsiveness of
		// the stock playerMessages, and this works well enough for
		// that:  We can now fairly easily replace, for example,
		// allNotAllowed()'s default
		//	"All" cannot be used with that verb.
		// with something like
		//	{You/he} can only {verb} one thing at a time.
		//
		// You should, however, keep the limitations...that it always
		// returns the canonical form of the verb the player used,
		// without modifying the ending...in mind.
		langMessageBuilder.paramList_
			= langMessageBuilder.paramList_.append(
				[ 'verb', &canonicalVerb, nil, nil, nil ]);
	}
;
