require_relative '../or_sandbox'
require 'rbtagger'

tagger = Brill::Tagger.new

RSpec.describe 'Handling interrogative structures' do
  it 'correctly determine interrogation with an adjective' do
    expect(interrogative_adj?(tagger.tag("Are you fine?"))).to be_truthy
  end
  it 'correctly determine lower case "ok"' do
    expect(interrogative_adj?(tagger.tag("Is she ok?"))).to be_truthy
  end

  # That .drop(1) thing completely sucks, but I have to decide where do I get rid of it

  it 'correctly inverts structure and changes person from first to second' do
    expect(invert_interrogative_adj(tagger.tag("am I fine").drop(1))).to eq "you are fine"
  end

  it 'correctly inverts structure and keeps the proverb' do
    expect(invert_interrogative_adj(tagger.tag("is he nice").drop(1))).to eq "he is nice"
  end

  it 'correctly inverts structure and keeps the proper noun' do
    expect(invert_interrogative_adj(tagger.tag("is Wendy fine").drop(1))).to eq "Wendy is fine"
  end
end
