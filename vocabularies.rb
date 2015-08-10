class Vocabularies
  attr_reader :num_vocabs, :vocabs

  def self.valid_vocab?(file)
    true
  end

  def initialize
    @num_vocabs = 0
    @vocabs     = {}
  end

  def read(vocab_file)
    File.open(vocab_file) do |file|
      file.each_with_index do |v, i|
        @vocabs[v.strip.to_sym] = i + 1
      end
    end
    @num_vocabs = @vocabs.size
  end

  def [](vocab)
    @vocabs[vocab.to_sym]
  end

  def each
    @vocabs.each do |v, i|
      yield v, i
    end
  end
end
