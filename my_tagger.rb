require 'rbtagger'

class MyTagger < Brill::Tagger
  def tag(string)
    super.drop(1)
  end
end
