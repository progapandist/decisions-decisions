require 'rbtagger'

tagger = Brill::Tagger.new

# ALL METHODS WORK ON _PART_ OF SENTENCE (i.e. separated by 'or')

# Determines if phrase starts with modal + prep + verb structure
def detect_modal_question(rbtagged)
  !rbtagged.map { |tagged| tagged.last }.join(' ').match(/MD (PRP|NN.*) VB.*/).nil?
end

# Detects if the inversion signals a yes/no question
# TODO: Needs some work to filter out imperative statements 
def detect_yes_no_question(rbtagged)
  !rbtagged.map { |tagged| tagged.last }.join(' ').match(/(MD|VB.*) (PRP|NN.*) (VB.*|NN.*|JJ|DT)/ ).nil?
end

p detect_yes_no_question(tagger.tag("is he a good teacher"))

# Reverses "modal + prep + verb" structure
def invert_modals(rbtagged)
  rs = [] # result
  rbtagged.each do |tagged|
    rs << tagged.first if !tagged.last.match(/\)/) # weird ")" that rbtagger generates. strip it elswhere
  end
  rs[0], rs[1] = rs[1], rs[0]
  # Change to second person
  if %w(I me we us).include?(rs[0])
    rs[0] = 'you'
  end
  rs
end


# Extracts meaningful words which follow a noun (extra nouns should be stripped)
def extract_noun_phrase(rbtagged)
  result = []
  up_to_noun = []
  rbtagged.each_with_index do |tagged, i|
    up_to_noun = rbtagged[0..i] if tagged.last.match(/NN/)
  end
  return rbtagged if up_to_noun.empty? # noun was not detected, return early
  reversed = up_to_noun.reverse
  reversed.each do |tagged|
    result << tagged if tagged.last.match(/(NN|DT|JJ|PRP|CD)/)
  end
  return result.reverse.map { |tagged| tagged.first }
end

modals = tagger.tag("should I stay at home and study")
p invert_modals(modals) if detect_modal_question(modals)

# p extract_noun_phrase(tagger.tag("stay at home"))
