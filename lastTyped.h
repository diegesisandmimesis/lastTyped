//
// lastTyped.h
//

// Uncomment to disable noun canonicalization
//#define NO_LAST_TYPED_NOUN

// Uncomment to track noun usage
// If enabled, this just counts how often noun canonicalization resolves
// to each canonical form.
#define LAST_TYPED_NOUN_STATS

// Uncomment to disable verb canonicalization
//#define NO_LAST_TYPED_VERB

// Uncomment the #define lines below to enable debugging output
#ifdef __DEBUG
//#define __DEBUG_LAST_TYPED_VERB
//#define __DEBUG_LAST_TYPED_NOUN
#endif // __DEBUG

#define gVerb (lastTypedVerb.get)
