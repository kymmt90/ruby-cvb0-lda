# coding: utf-8

require './cvb0_lda'
require 'test/unit'

class Cvb0LDATest < Test::Unit::TestCase
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
    assert_equal 10, @@sut.num_topics
  end

  test 'alpha is 0.1' do
    assert_equal 0.1, @@sut.alpha
  end

  test 'beta is 0.01' do
    assert_equal 0.01, @@sut.beta
  end

  sub_test_case 'building parameters containers' do
    setup do
      @@sut.build_parameter_containers
    end

    test 'n_dt is built correctly' do
      sut_vector = @@sut.n_dt[0]
      sut_vector.each do |val|
        assert_equal @@sut.alpha, val
      end
      assert_equal @@sut.num_topics, sut_vector.column_size
    end

    test 'n_vt is built correctly' do
      sut_vector = @@sut.n_vt[0]
      sut_vector.each do |val|
        assert_equal @@sut.beta, val
      end
      assert_equal @@sut.num_topics, sut_vector.column_size
    end

    test 'n_t is built correctly' do
      @@sut.n_t.each do |val|
        assert_equal @@sut.beta * @@sut.num_vocabs, val
      end
      assert_equal @@sut.num_topics, @@sut.n_t.column_size
    end
  end

  sub_test_case 'building the initial gamma vector' do
    setup do
      @init_gamma_t = @@sut.initial_gamma_vector
    end

    test 'the vector size equals to the number of topics' do
      assert_equal @@sut.num_topics, @init_gamma_t.column_size
    end

    test 'the sum of sampled values is almost 1.0' do
      sum = @init_gamma_t.to_a.flatten.reduce(:+)
      assert_in_delta 1.0, sum, 0.00001
    end
  end
end
