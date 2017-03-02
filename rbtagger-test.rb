require 'rbtagger'

tagger = Brill::Tagger.new

# ALL METHODS WORK ON _PART_ OF SENTENCE (i.e. separated by 'or')

# Determines if phrase starts with modal + prep + verb structure and reverses it
# WORKS! TODO: SPLIT IN TWO METHODS? (detect_modals, invert_modals)

def detect_modal_question(rbtagged)
  !rbtagged.map { |tagged| tagged.last }.join(' ').match(/MD (PRP|NN.*) VB.*/).nil?
end

# WIP
def detect_inverted_question(rbtagged)
  !rbtagged.map { |tagged| tagged.last }.join(' ').match(/VB.* (PRP|NN.*)/).nil?
end

p detect_inverted_question(tagger.tag("try me"))

def invert_modals(rbtagged)
  rs = [] # result
  rbtagged.each do |tagged|
    rs << tagged.first if !tagged.last.match(/\)/) # weird ")" that rbtagger generates. strip it elswhere
  end
  rs[0], rs[1], rs[2] = rs[1], rs[0], rs[2]
  # Change pronoun
  if %w(I me we).include?(rs[0])
    rs[0] = 'you'
  end
  rs
end


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

modals = tagger.tag("should I have been trying")
p invert_modals(modals) if detect_modal_question(modals)

extract_noun_phrase(tagger.tag("see a good old movie"))
