require 'engtagger'
require 'nori'

# PREFER BRILL TAGGER?

# DETERMINE MODALS AND INVERT THEM: Should I stay -> you should stay

# We have an "OR"

# Sanity check: detect if language is English. Use segmenter to find sentences.
# If there are more than three sentences, ask the user to be more concise.
# Find a first sentence that contains "ORs" and work with it.
# 1. Normalize: remove punctuation from input and decapitalize the first letter
# (if this letter is not I)
# 2. Test if it's the simplest case: i.e. number of words is number of 'or's +1
#   — If that's the case — split into array and randomly choose one
#   - If not: process further
# 3. Put a sentence through tagger.
# 4. Test if have any modal structures. If so — remove them
# 5. Did it become the simplest case? If yes, see 2. If not — process further
# 6. Test if the case contains nouns.
#   - If so: run through TextAnalysis API (Key phrase extractor)
#   — if not: run logic for verbs ??????


# We don't have an "OR"
