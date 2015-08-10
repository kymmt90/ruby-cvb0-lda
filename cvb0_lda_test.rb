# coding: utf-8

require './cvb0_lda'
require 'test/unit'

class TestSample < Test::Unit::TestCase
  class << self
    def startup
      @@sut = LDA.new(10)
      @@sut.read('docword.kos.txt', 'vocab.kos.txt')
    end

    def shutdown
    end
  end

  def setup

  end

  def teardown
  end

  test 'the number of topics is 10' do
    assert_equal @@sut.num_topics, 10
  end

  test 'alpha is 0.1' do
    assert_equal @@sut.alpha, 0.1
  end

  test 'beta is 0.01' do
    assert_equal @@sut.beta, 0.01
  end

  test 'gamma_jik has 3430 elements' do
    assert_equal @@sut.gamma_jik.size, 3430
  end
end
