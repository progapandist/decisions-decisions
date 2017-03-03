require 'rbtagger'

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

tagger = Brill::Tagger.new # This is our tagger

def normalize(string)
  alphanum = string.gsub(/[^0-9a-z\: ]/i, '')
  arr = alphanum.split
  arr[0] = arr.first.downcase if arr.first != 'I'
  arr.join(" ")
end

def make_decision(arr) # make a decision
  arr.sample
end

# Determines if phrase starts with modal + prep + verb structure
def modal_question?(rbtagged)
  !rbtagged.map { |tagged| tagged.last }.join(' ').match(/MD (PRP|NN.*) VB.*/).nil?
end

def simple_case?(string)
  string.gsub(" or ", " ").split.size == (string.scan(/(?= or )/).count + 1)
end

def split_at_or(string)
  string.split(" or ")
end

def or_detected?(string)
  string.include?(" or ")
end

def invert_modals(rbtagged)
  rs = rbtagged.map { |tagged| tagged.first }.drop(1) # drop first element as it contains weird ")"
  rs[0], rs[1] = rs[1], rs[0]
  # Change to second person
  rs[0] = 'you' if %w(I i me we us).include?(rs[0])
  rs.join(" ")
end

def handle_or_question(string, tagger) # already has an or, check elsewhere
  choices = []
  # Normalize a string
  normalized = normalize(string)
  # Early return if we have a simple case
  if simple_case?(normalized)
    return split_at_or(normalized)
  end
  # Split at or and process both parts
  split_at_or(normalized).map do |part|
    tagged = tagger.tag(part)
    if modal_question?(tagged)
      choices << invert_modals(tagged)
    elsif interrogative_adj?(tagged)
      choices << invert_interrogative_adj(tagged)
    else
      choices << part
    end
  end
  choices
end

# Detect interrogative mood with an adjective
# e.g. "is it OK to stay", "is it fine", "does that count", "Am I sick"
def interrogative_adj?(rbtagged)
  # capitalize OK and change its POS if detected
  transformed = rbtagged.map { |tagged| tagged.first.match(/ok/) ? ["OK", "JJ"] : tagged }
  !transformed.map { |tagged| tagged.last }.join(' ').match(/VB.* (PRP|NN.*)( DT)* JJ.*/).nil?
end

# Changes to indicative mood
def invert_interrogative_adj(rbtagged)
  rs = rbtagged.map { |tagged| tagged.first }.drop(1) # drop first element as it contains weird ")"
  rs[0], rs[1] = rs[1], rs[0]
  # Change to second person
  rs[0] = 'you' if %w(I i me we us).include?(rs[0])
  rs[1] = 'are' if rs[1] == 'am'
  rs.join(" ")
end

# TODO: Match verbs
def match_initial_verbs(arr) # takes an array of strings
end

# Detects interrogative mood with auxiliary verbs
# e.g. "Do I stay?", "Has he decided?"
def interrogative_aux?
end

# Changes to indicative mood
def invert_interrogative_aux
end


p handle_or_question("Am I sick or am I ok?", tagger)
p handle_or_question("Should I go out or am I sick?", tagger)
p handle_or_question("Should I stay or should I go?", tagger)
p handle_or_question("Should I stay or is it fine to go?", tagger)
p handle_or_question("Should I take it or leave it?", tagger)
p handle_or_question("Do I stay or do I go?", tagger)
p handle_or_question("Does he wish me harm or does he love me?", tagger)
p handle_or_question("Is he a good man or a bad man?", tagger)
p handle_or_question("Heads or tails?", tagger)
