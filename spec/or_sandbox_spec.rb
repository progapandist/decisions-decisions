require_relative '../or_sandbox'
require 'rbtagger'

tagger = Brill::Tagger.new

RSpec.describe 'Working with interrogative structures' do
  it 'Correctly determines interrogation with an adjective' do
    expect(interrogative_adj?(tagger.tag("Are you fine?"))).to be_truthy
  end
  it 'correctly determines lower case "ok"' do
    expect(interrogative_adj?(tagger.tag("Is she ok?"))).to be_truthy
  end
end
