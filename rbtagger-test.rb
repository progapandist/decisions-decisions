require 'rbtagger'

tagger = Brill::Tagger.new

modals = tagger.tag("should I be forgiven?")

# WORKS! TODO: SPLIT IN TWO METHODS? (detect_modals, invert_modals)
def detect_and_invert_modals(rbtagged)
  # separate method .modal_structure_detected? to test condition?
  if rbtagged.map { |tagged| tagged.last }.join(' ').match(/MD PRP VB/)
    rs = [] # result
    rbtagged.each do |tagged|
      rs << tagged.first if tagged.last.match(/(MD|PRP|VB|IN)/)
    end
    rs[0], rs[1], rs[2] = rs[1], rs[0], rs[2]
    if rs[0].match(/i/i) or rs[0].match(/me/i)
      rs[0] = 'you'
    end
    rs
  end
end


def extract_noun_phrase(rbtagged)
  result = []
  up_to_noun = []
  rbtagged.each_with_index do |tagged, i|
    p up_to_noun = rbtagged[0..i] if tagged.last.match(/NN/)
  end
  return rbtagged if up_to_noun.empty? # noun was not detected, return early
  reversed = up_to_noun.reverse
  reversed.each do |tagged|
    result << tagged if tagged.last.match(/(NN|DT|JJ|PRP|CD)/)
  end
  return result.reverse.map { |tagged| tagged.first }
end

p detect_and_invert_modals(modals)

p extract_noun_phrase(tagger.tag("watch three cool videos online"))
