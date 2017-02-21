require 'engtagger'
require 'nori'

def parse_pos_tags(string)
  tgr = EngTagger.new
  prs = Nori.new
  tagged = tgr.add_tags(string)
  result = {}
  tagged.split.each do |word|
    parsed = prs.parse(word)
    pos = parsed.keys.first
    if result.key?(pos)
      result[pos] << parsed.values.first
    else
      result[pos] = [parsed.values.first]
    end
  end
  result
end

def remove_modals(string)
  parsed = parse_pos_tags(string)

  return string if !parsed.key?("md")

  string.split.map do |w|
    if parsed['md'].flatten.include?(w)
       nil
     else w
    end
  end.compact.join(" ")
end

def naive_parse(string)
  string = keep_alphanum(string)
  naive_handle_or(string).sample if string.include?(" or ")
end

def normalize(string)
  alphanum = string.gsub(/[^0-9a-z ]/i, '')
  arr = alphanum.split
  arr[0] = arr.first.downcase
  arr.join(" ")
end

def naive_handle_or(string)
  string.split(" or ").map do |part|
    part.strip
    part.split.last
  end
end

# TODO: REMOVE MODAL AND PRONOUNS AUTOMATICALLY
# TODO: RECOGNIZE SEMICOLON

def nlp_parse(string)
  normalized = normalize(string)
  #essence = keep_essential_words(no_punctuation)
  nlp_handle_or(normalized) if normalized.include?(" or ")
end

def nlp_handle_or(string)
  p demodalized = remove_modals(string)
  splitted = demodalized.split(" or ")

  # take an easy way if there are no phrases at all. TODO: rewrite in better style?
  if string.gsub(" or ", " ").split.size == (string.scan(/(?= or )/).count + 1)
    return splitted
  end

  # handle  more complicated cases
  if detect_pos(splitted) == "mixed"
    option_no = splitted.each_with_index.map { |e, i| i + 1 }.sample
    "You should go with option number #{option_no}"
  elsif detect_pos(splitted) == "nouns"
    handle_nouns(splitted)
  else
    handle_verbs(splitted)
  end
end

def handle_nouns(strings)
  # this handles nouns with adjectives/adverbs just fine
  strings.map do |part|
    reversed = part.split.reverse
    main_word = [reversed.first]
    rest = reversed[(1..-1)]
    adj_adv = []
    rest.map do |word|
      adj_adv << word if has_adjectives(word) or has_adverbs(word)
    end
    (main_word + adj_adv).reverse.join(" ")
  end
end

# TODO: rewrite compliment logic to use any nouns and pronouns too
def handle_verbs(strings)
  # handle verb + adv/adj pair
  strings.map do |part|
    verb = find_verb(part)
    splitted = part.split
    compliment = splitted[splitted.index(verb) + 1]
    # TODO: that shit is kind of fucked up
    if !compliment
      verb
    elsif has_adverbs(compliment) || has_adjectives(compliment)
      verb + " " + compliment
    else
      verb
    end
  end
end

# based on a hunch, need to check later
def detect_pos(strings)
  nouns_detected = strings.all? do |string|
    has_nouns(string)
  end
  verbs_detected = strings.all? do |string|
    has_verbs(string)
  end

  result = {nouns: nouns_detected, verbs: verbs_detected}

  if result[:verbs] == result[:nouns]
    return "mixed"
  else
    return result.select { |k, v| v == true }.keys.first.to_s
  end
end

def find_verb(string)
  string = string.split.map { |w| "to " + w }.join(" ")
  tgr = EngTagger.new
  tagged = tgr.add_tags(string)
  tgr.get_verbs(tagged).keys.first
end

# Helpers to detect POS:

def has_nouns(string)
  tgr = EngTagger.new
  tagged = tgr.add_tags(string)
  !tgr.get_nouns(tagged).empty?
end

def has_verbs(string)
  string = string.split.map { |w| "to " + w }.join(" ")
  tgr = EngTagger.new
  tagged = tgr.add_tags(string)
  !tgr.get_verbs(tagged).empty?
end

def has_adjectives(string)
  tgr = EngTagger.new
  tagged = tgr.add_tags(string)
  !tgr.get_adjectives(tagged).empty?
end

def has_adverbs(string)
  tgr = EngTagger.new
  tagged = tgr.add_tags(string)
  !tgr.get_adverbs(tagged).empty?
end


#p parse_pos_tags("should I stay or should I go")

# p detect_pos(["Should I go", "swim"])
 p nlp_parse("should we go right away or should I call first?")
# p nlp_parse("nice salary or bad treatment")
# p nlp_parse("take it or leave it?")
# p nlp_parse("apples or red oranges?")
# p parse("Should I stay or should I go?")
# p parse ("Should I have candy or steak for breakfast?")
# tgr = EngTagger.new
#
# p mixed = tgr.add_tags('should I call you Mike or Andy or dear John?')
# p tgr.get_verbs(mixed)
