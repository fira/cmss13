#define TUTORIAL_ATOM_FROM_TRACKING(path, varname) var##path/##varname = tracking_atoms[##path]

#define TUTORIAL_CATEGORY_BASE "Base" // Shouldn't be used outside of base types
#define TUTORIAL_CATEGORY_MARINE "Marine"
#define TUTORIAL_CATEGORY_XENO "Xenomorph"
