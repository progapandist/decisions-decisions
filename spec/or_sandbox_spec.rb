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
  it 'correctly change person from first to second' do
    expect(interrogative_adj?(tagger.tag("am I fine"))).to eq "you are fine"
  end
end
