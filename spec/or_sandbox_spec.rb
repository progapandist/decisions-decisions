require_relative '../or_sandbox'
require_relative '../my_tagger'

tagger = MyTagger.new


describe "Helpers" do
  it 'detect that phrase starts with a verb' do
    phrase = tagger.tag("go home")
    expect(starts_with_verb?(phrase)).to be_truthy
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


# p handle_or_question("Am I sick or am I ok?", tagger)
# p handle_or_question("Are you sick or still fine?", tagger)
# p handle_or_question("Is she beautiful or what?", tagger)
# p handle_or_question("Is she nuts or what?", tagger)
# p handle_or_question("Is Ann sick or is she fine?", tagger)
# p handle_or_question("Should I go out or am I sick?", tagger)
# p handle_or_question("Should I stay or should I go?", tagger)
# p handle_or_question("Should I stay or go?", tagger)
# p handle_or_question("Should I stay or is it fine to go?", tagger)
# p handle_or_question("Should I take it or leave it?", tagger)
# p handle_or_question("Do I stay or do I go?", tagger)
# p handle_or_question("Does he wish me harm or does he love me?", tagger)
# p handle_or_question("Is he a good man or a bad man?", tagger)
# p handle_or_question("Heads or tails?", tagger)


describe "Initial verb matching" do
  it 'attaches initial sequences while avoiding conflict with single verbs' do
    expect(match_initial_verbs(["you should stay", "go"], tagger)).to eq(["you should stay", "you should go"])
  end

  it 'attaches longer initial sequences while avoiding conflict with single verbs' do
    expect(match_initial_verbs(["you should have been staying", "going"], tagger)).to eq(["you should have been staying", "you should have been going"])
  end
end

describe "Handling or questions" do

  context "Edge cases" do
    it 'Should I stay or what'
    it 'Should I stay or not'
  end

  context "with modal structures" do
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


  context 'with an interrogative verb + adjective' do
    it 'with verb present in all parts' do
      expect(handle_or_question("is she beautiful or is she ugly", tagger)).to eq(["she is beautiful", "she is ugly"])
    end
    it 'with verb present in only one part (verb matching)' do
      expect(handle_or_question("is it green or red or blue", tagger)).to eq(["it is green", "it is red", "it is blue"])
    end
  end

end
