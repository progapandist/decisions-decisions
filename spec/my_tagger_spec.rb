require_relative '../my_tagger'

RSpec.describe MyTagger do
  it "returns an array of arrays (word, POS)" do
    expect(MyTagger.new.tag("apple")).to include(["apple", "NN"])
  end
end
