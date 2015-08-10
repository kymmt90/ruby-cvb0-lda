# coding: utf-8

require './dataset'
require 'test/unit'

class TestSample < Test::Unit::TestCase
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
    assert_equal @@sut.num_docs, 3430
  end

  test 'the number of vocabs is 6906' do
    assert_equal @@sut.num_docs, 3430
  end

  test 'dataset[1] returns doc' do
    assert_not_nil @@sut[1]
  end

  test 'dataset[0] returns nil' do
    assert_nil @@sut[0]
  end

  test 'dataset[3430] returns doc' do
    assert_not_nil @@sut[3430]
  end

  test 'dataset[3431] returns nil' do
    assert_nil @@sut[3431]
  end

  test 'doc-1 has 2 vocab-61' do
    assert_equal @@sut[1][61], 2
  end

  test 'doc-1 has 1 vocab-6905' do
    assert_equal @@sut[1][6905], 1
  end

  test 'doc-2 has 2 vocab-232' do
    assert_equal @@sut[2][232], 2
  end

  test 'doc-3430 has 1 vocab-6822' do
    assert_equal @@sut[3430][6822], 1
  end

  test 'vocab-1 is aarp' do
    assert_equal @@sut.vocabs['aarp'], 1
  end

  test 'vocab-3453 is knowledge' do
    assert_equal @@sut.vocabs['knowledge'], 3453
  end

  test 'vocab-6906 is zones' do
    assert_equal @@sut.vocabs['zones'], 6906
  end

  test 'invalid vocab' do
    assert_nil @@sut.vocabs['invalid_vocab']
  end

  test 'get each doc' do
    count = 0
    @@sut.each_doc_with_index do |doc, doc_index|
      count += 1
    end
    assert_equal count, 3430
  end

  test 'check each doc index' do
    count = 0
    @@sut.each_doc_with_index do |doc, doc_index|
      count += 1
      assert_equal doc_index, count
    end
  end

  test 'check each doc data' do
    @@sut.each_doc_with_index do |doc, doc_index|
      assert_not_nil doc
    end
  end

  test 'check each words in docs' do
    data_size = 0
    @@sut.each_doc_with_index do |doc, doc_index|
      doc.each do |count|
        data_size += count
      end
    end
    assert_equal data_size, @@sut.num_words
  end
end
