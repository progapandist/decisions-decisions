require_relative '../or_sandbox'
require_relative '../my_tagger'
require 'linguistics'
require 'verbs'

tagger = MyTagger.new


describe "Detectors and transformators" do
  let(:do_phrase) { tagger.tag("do I stay") }
  let(:have_phrase) { tagger.tag("has Jack been drinking") }
  let(:wrong_phrase) { tagger.tag("you knew") }
  let(:non_infinitives) { ["stayed", "left", "says", "did", "went", "borrowed"] }

  it 'finds infinitives' do
    expect(
      non_infinitives.map { |v| find_infinitive(v) }
    ).to eq(["stay", "leave", "say", "do", "go", "borrow"])
  end

  it 'detects that phrase starts with a verb' do
    phrase = tagger.tag("go home")
    expect(starts_with_verb?(phrase)).to be_truthy
  end

  it 'detects interrogation with auxiliary verbs' do
    expect(interrogative_aux?(do_phrase)).to be_truthy
    expect(interrogative_aux?(have_phrase)).to be_truthy
    expect(interrogative_aux?(wrong_phrase)).to be_falsy
  end

  it 'removes auxiliary verb and reverses interrogation' do
    expect(handle_interrogative_aux(do_phrase)).to eq("you do stay")
    expect(handle_interrogative_aux(have_phrase)).to eq("you stay")
  end
end

describe 'Handling interrogative structures with adjectives' do
  it 'correctly determines interrogation with an adjective' do
    expect(interrogative_adj?(tagger.tag("Are you fine?"))).to be_truthy
  end
  it 'correctly determines lower case "ok"' do
    expect(interrogative_adj?(tagger.tag("Is she ok?"))).to be_truthy
  end

  it 'correctly inverts structure and changes person from first to second' do
    expect(invert_interrogative_adj(tagger.tag("am I fine"))).to eq "you are fine"
  end

  it 'correctly inverts structure and keeps the proverb' do
    expect(invert_interrogative_adj(tagger.tag("is he nice"))).to eq "he is nice"
  end

  it 'correctly inverts structure and keeps the proper noun' do
    expect(invert_interrogative_adj(tagger.tag("is Wendy fine"))).to eq "Wendy is fine"
  end
end

describe "Initial verb matching" do
  it 'attaches initial sequences while avoiding conflict with single verbs' do
    expect(match_initial_verbs(["you should stay", "go"], tagger)).to eq(["you should stay", "you should go"])
  end

  it 'attaches longer initial sequences while avoiding conflict with single verbs' do
    expect(match_initial_verbs(["you should have been staying", "going"], tagger)).to eq(["you should have been staying", "you should have been going"])
  end

  it 'handles non-modal verb structures' do
    expect(match_initial_verbs(["you have been staying", "going"], tagger)).to eq(["you have been staying", "you have been going"])
  end

  it 'matches verb phrases to parts with no verbs' do
    expect(match_initial_verbs(["you should pick this", "that"], tagger)).to eq(["you should pick this", "you should pick that"])
  end
end

describe "Handling or questions" do

  context "Edge cases" do
    it 'Should I stay or what'
    it 'Should I stay or not'
  end

  context "with modal clauses" do
    it 'with two simple modals' do
      expect(handle_or_question("should I stay or may he go", tagger)).to eq(["you should stay", "he may go"])
    end

    it 'with modal present only in one part' do
      expect(handle_or_question("should I stay or go", tagger)).to eq(["you should stay", "you should go"])
    end

    it 'with modal structure that has verbs attached' do
      expect(handle_or_question("should I pick this or that", tagger)).to eq(["you should pick this", "you should pick that"])
    end

    it 'with longer verb sequences' do
      expect(handle_or_question("should I have picked this or that", tagger)).to eq(["you should have picked this", "you should have picked that"])
    end
  end

  context "with non-modal clauses" do
    it "'do I?' questions" do
      expect(handle_or_question("do I stay or do I go", tagger)).to eq(["you do stay", "you do go"])
    end
  end

  context 'with an interrogative verb + adjective' do
    it 'with verb present in all parts' do
      expect(handle_or_question("is she beautiful or is she ugly", tagger)).to eq(["she is beautiful", "she is ugly"])
    end
    it 'with verb present in only one part (verb matching)' do
      expect(handle_or_question("is it green or red or blue", tagger)).to eq(["it is green", "it is red", "it is blue"])
    end
  end

end
