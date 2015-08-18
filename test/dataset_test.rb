# coding: utf-8

require './dataset'
require 'test/unit'

class DatasetTest < Test::Unit::TestCase
  NUM_DOCS   = 3430
  NUM_VOCABS = 6906
  NUM_WORDS  = 467714

  class << self
    def startup
      @@sut = Dataset.new
      @@sut.read('docword.kos.txt', 'vocab.kos.txt')
    end

    def shutdown
    end
  end

  def setup
  end

  def teardown
  end

  test 'the number of docs is 3430' do
    assert_equal NUM_DOCS, @@sut.num_docs
  end

  test 'the number of vocabs is 6906' do
    assert_equal NUM_VOCABS, @@sut.num_vocabs
  end

  test 'the number of words is 467714' do
    assert_equal NUM_WORDS, @@sut.num_words
  end

  test 'dataset[1] returns doc' do
    assert_not_nil @@sut[1]
  end

  test 'dataset[0] returns nil' do
    assert_nil @@sut[0]
  end

  test 'dataset[3430] returns doc' do
    assert_not_nil @@sut[NUM_DOCS]
  end

  test 'dataset[3431] returns nil' do
    assert_nil @@sut[NUM_DOCS + 1]
  end

  test 'doc-1 has 2 vocab-61' do
    assert_equal 2, @@sut[1][61]
  end

  test 'doc-1 has 1 vocab-6905' do
    assert_equal 1, @@sut[1][6905]
  end

  test 'doc-2 has 2 vocab-232' do
    assert_equal 2, @@sut[2][232]
  end

  test 'doc-3430 has 1 vocab-6822' do
    assert_equal 1, @@sut[3430][6822]
  end

  test 'vocab-1 is aarp' do
    assert_equal 1, @@sut.vocabs['aarp']
  end

  test 'vocab-3453 is knowledge' do
    assert_equal 3453, @@sut.vocabs['knowledge']
  end

  test 'vocab-6906 is zones' do
    assert_equal NUM_VOCABS, @@sut.vocabs['zones']
  end

  test 'invalid vocab' do
    assert_nil @@sut.vocabs['invalid_vocab']
  end

  test 'get each doc' do
    count = 0
    @@sut.each_doc do |doc|
      count += 1
    end
    assert_equal NUM_DOCS, count
  end

  test 'check each doc data' do
    @@sut.each_doc do |doc|
      assert !doc.empty?
    end
  end

  test 'check each words in docs' do
    data_size = 0
    @@sut.each_doc do |doc|
      doc.each_value do |count|
        data_size += count
      end
    end
    assert_equal NUM_WORDS, data_size
  end

  test 'get each doc with index' do
    count = 0
    @@sut.each_doc_with_index do |doc, doc_index|
      count += 1
    end
    assert_equal NUM_DOCS, count
  end

  test 'check each doc index' do
    count = 0
    @@sut.each_doc_with_index do |doc, doc_index|
      count += 1
      assert_equal doc_index, count
    end
  end

  test 'check each doc data with index' do
    @@sut.each_doc_with_index do |doc, doc_index|
      assert !doc.empty?
    end
  end

  test 'check each words in docs with index' do
    data_size = 0
    @@sut.each_doc_with_index do |doc, doc_index|
      doc.each_value do |count|
        data_size += count
      end
    end
    assert_equal NUM_WORDS, @@sut.num_words
  end
end
