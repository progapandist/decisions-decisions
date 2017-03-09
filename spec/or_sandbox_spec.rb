require_relative '../or_sandbox'
require_relative '../my_tagger'

tagger = MyTagger.new

RSpec.describe 'Handling interrogative structures with adjectives' do
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
