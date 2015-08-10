# coding: utf-8

require './vocabularies'

class Dataset
  attr_reader :num_docs, :num_words
  attr_reader :dataset, :vocabs

  def self.valid_docword?(file)
    true
  end

  def initialize
    @num_docs  = 0
    @num_words = 0
    @dataset = Hash.new { |h, k| h[k] = {} }
  end

  def read(docword_file, vocab_file)
    unless Dataset.valid_docword?(docword_file)
      raise '#{docword_file}: invalid file'
    end
    unless Vocabularies.valid_vocab?(docword_file)
      raise '#{vocab_file}: invalid file'
    end

    @vocabs = Vocabularies.new
    @vocabs.read(vocab_file)

    read_docword(docword_file)
  end

  def each_doc_with_index
    1.upto(@num_docs) do |doc_index|
      yield @dataset[doc_index], doc_index if block_given?
    end
  end

  def [](doc)
    if doc <= 0 || @dataset.size < doc
      nil
    else
      @dataset[doc]
    end
  end

  def num_vocabs
    @vocabs.num_vocabs
  end

  private

    def read_docword(docword_file)
      File.open(docword_file) do |file|
        file.each_with_index do |line, index|
          if index < 3
            read_header(line, index)
            next
          end

          read_single_data(line)
        end
      end
    end

    def read_header(line, index)
      @num_docs   = line.strip.to_i if index == 0
      @num_vocabs = line.strip.to_i if index == 1
    end

    def read_single_data(line)
      doc, vocab, count = line.split.map(&:to_i)
      @num_words += count
      @dataset[doc][vocab] ||= 0
      @dataset[doc][vocab] += count
    end
end
