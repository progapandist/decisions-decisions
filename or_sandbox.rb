require_relative 'my_tagger'
require 'linguistics'
require 'verbs'


# Sanity check: detect if language is English. Use segmenter to find sentences.
# If there are more than three sentences, ask the user to be more concise.
# Find a first sentence that contains "ORs" and work with it.
# 1. Normalize: remove punctuation from input and decapitalize the first letter
# (if this letter is not I). TODO: REMOVE DOUBLE SPACES
# 2. Test if it's the simplest case: i.e. number of words is number of 'or's +1
#   — If that's the case — split into array and randomly choose one
#   - If not: process further

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
  rs = rbtagged.map { |tagged| tagged.first }
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
  match_initial_verbs(choices, tagger)
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
  rs = rbtagged.map { |tagged| tagged.first }
  rs[0], rs[1] = rs[1], rs[0]
  # Change to second person
  rs[0] = 'you' if %w(I i me we us).include?(rs[0])
  rs[1] = 'are' if rs[1] == 'am'
  rs.join(" ")
end

# ["you should stay", "go"] => ["you should stay", "you should go"]
# takes an array of strings, assumes they're all in indicative mood
def match_initial_verbs(arr, tagger)
  initial_verbs = ""
  result = []
  tagged_arr = arr.map { |string| tagger.tag(string) }
  tagged_arr.each do |tagged|
    if simple_indicative_clause?(tagged)
      initial_verbs += tagged.first.first
      initial_verbs += " "
      initial_verbs += tagged.map { |t| t.first if t.last =~ /(MD|VB.*)/ }.compact.join(" ")
      initial_verbs += " "
    end
  end
  tagged_arr.each do |tagged|
    if starts_with_verb?(tagged)
      result << initial_verbs.split[0..-2].join(" ") + " " + tagged.map { |t| t.first }.join(" ")
    elsif !simple_indicative_clause?(tagged)
      result << initial_verbs + tagged.map { |t| t.first }.join(" ")
    else
      result << tagged.map { |t| t.first }.join(" ")
    end
  end
  result
end


def simple_indicative_clause?(rbtagged)
  rbtagged.take(2).map { |t| t.last }.join(' ').match(/(PRP|NN.*) (MD|VB.*)/)
end

def starts_with_verb?(rbtagged)
  rbtagged.first.last =~ /VB.*/
end

# Detects interrogative mood with auxiliary verbs
# e.g. "Do I stay?", "Has he decided?"
def interrogative_aux?(rbtagged) # VBZ, VBP
  rbtagged.take(3).map { |t| t.last }.join(' ').match(/(VBZ|VBP) (PRP|NN.*) (VB.*)/)
end

# TODO: use https://github.com/rossmeissl/verbs and/or https://deveiate.org/code/linguistics/Linguistics/EN.html to conjugate verbs ??
# Changes to indicative mood by removing auxiliary verb and adding "s" to 3rd person
# "does he stay" => "he stays"
# "was he working" => "he was working"
# "has he been" => "he has been"
# "did he stay" => "he stayed"
def handle_interrogative_aux(rbtagged)
  verbs = rbtagged.select { |t| t.last =~ /VB.*/  }
  auxiliary = verbs.first.first
  main_verb = verbs.last.first
  infinitive = find_infinitive(main_verb)
  subj = rbtagged.select { |t| t.last =~ /(PRP|NN.*)/  }.first.first

  person = :third
  case subj
  when "I", "i", "me", "we", "us"
    person = :first
  when "you"
    person = :second
  end

  tense = :present
  aspect = :habitual
  if %w(did had was were).include?(auxiliary)
    tense = :past
    aspect = :perfective
  end

  infinitive.verb.conjugate(subject: subj, tense: tense, aspect: aspect, person: person)
end

def find_infinitive(verb)
  Linguistics.use( :en )
  infinitive = verb.en.infinitive.to_s # make it a String again
  return verb if infinitive == ""
  # quick and dirty fix for strange Linguistics bug when "e" is not removed from the verb
  # on tense change
  infinitive.chop! if infinitive[-2, 2] =~ /(a|o|u|i|e|y|w|k|y|d|g)e/i
  infinitive
end

p handle_interrogative_aux(MyTagger.new.tag("did he ring"))
