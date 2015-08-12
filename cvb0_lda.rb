# coding: utf-8

require './dataset'
require 'matrix'
require 'simple-random'

class LDA
  attr_reader   :num_topics, :num_docs, :num_vocabs, :num_words
  attr_accessor :alpha, :beta
  attr_reader   :gamma_dvt, :n_dt, :n_vt, :n_t

  def initialize(num_topics, alpha = 0.1, beta = 0.01)
    @num_topics = num_topics
    @alpha = alpha
    @beta  = beta
    @gamma_dvt = {}
    @random = SimpleRandom.new
  end

  def setup(docword_file, vocab_file)
    read(docword_file, vocab_file)
    initialize_parameters
  end

  def read(docword_file, vocab_file)
    @dataset = Dataset.new
    @dataset.read(docword_file, vocab_file)
  end

  def initialize_parameters
    @n_dt = Hash.new do |h, k|
      h[k] = Matrix.row_vector([@alpha] * @num_topics)
    end
    @n_vt = Hash.new do |h, k|
      h[k] = Matrix.row_vector([@beta] * @num_topics)
    end
    @n_t = Matrix.row_vector([@beta * @dataset.num_vocabs] * @num_topics)

    @dataset.each_doc_with_index do |doc, doc_index|
      gamma_vt = Hash.new do |h, k|
        h[k] = Matrix.row_vector([0.0] * @num_topics)
      end

      doc.each_key do |vocab|
        init_gamma_t = @random.dirichlet(*([@alpha] * @num_topics))
        init_gamma_t = Matrix.row_vector(init_gamma_t)

        count = doc[vocab]
        gamma_vt[vocab] += init_gamma_t * count
        @n_vt[vocab] += count * init_gamma_t
        @n_dt[doc_index] += count * init_gamma_t
        @n_t += count * init_gamma_t
      end

      gamma_vt.each_key do |vocab|
        count = doc[vocab]
        gamma_vt[vocab] = gamma_vt[vocab].map { |val| val / count }
      end
      @gamma_dvt[doc_index] = gamma_vt
    end
  end

  def theta(doc, topic)
    denominator = @n_dt[doc].to_a.flatten.inject(0.0) { |sum, val| sum + val }
    @n_dt[doc][0, topic] / denominator
  end

  def phi(topic, vocab)
    @n_vt[vocab][0, topic] / @n_t[0, topic]
  end

  def cvb0
    new_n_dt = Hash.new do |h, k|
      h[k] = Matrix.row_vector([@alpha] * @num_topics)
    end
    new_n_vt = Hash.new do |h, k|
      h[k] = Matrix.row_vector([@beta] * @num_topics)
    end

    @dataset.each_doc_with_index do |doc, doc_index|
      gamma_vt = @gamma_dvt[doc_index]

      gamma_vt.each_pair do |vocab, gamma_t|
        new_gamma_t = update(doc_index, vocab, gamma_t)
        gamma_vt[vocab] = new_gamma_t.covector
        count = doc[vocab]
        new_n_vt[vocab]     += count * new_gamma_t.covector
        new_n_dt[doc_index] += count * new_gamma_t.covector
      end
    end

    @n_vt = new_n_vt
    @n_dt = new_n_dt
    new_n_t = []
    0.upto(@num_topics - 1) do |topic|
      sum = 0.0
      new_n_vt.each_value do |values|
        sum += values[0, topic]
      end
      new_n_t << sum
    end
    @n_t = Matrix.row_vector(new_n_t)
  end

  def update(doc_index, vocab, gamma_k)
    n_dt = Vector[*@n_dt[doc_index].to_a.flatten]

    new_gamma_k = Vector[*(@n_vt[vocab] - gamma_k).to_a.flatten]
    new_gamma_k = new_gamma_k.map2(n_dt - Vector[*gamma_k.to_a.flatten]) { |x, y| x * y }
    denominator = Vector[*(@n_t - gamma_k).to_a.flatten].map { |val| 1.0 / val }
    new_gamma_k = new_gamma_k.map2(denominator) { |x, y| x * y }
    gamma_sum = new_gamma_k.to_a.flatten.inject(0.0) { |sum, val| sum + val }
    new_gamma_k.map { |x| x / gamma_sum }
  end

  def each_vocab_in_topic(topic, num = 10)
    vocab_probs = Hash.new { |h, k| h[k] = 0.0 }
    @dataset.vocabs.each do |v, v_id|
      vocab_probs[v] = phi(topic, v_id)
    end
    vocab_probs.sort { |a, b| a[1] <=> b[1] }
               .reverse
               .slice(1, num)
               .inject([]) { |vs, v_p| vs << v_p[0] }
               .each { |v| yield(v) }
  end

  def print_result
    0.upto(@num_topics - 1) do |t|
      top_vocabs = []
      each_vocab_in_topic(t) { |v| top_vocabs << v }
      puts "Topic #{t + 1}: [#{top_vocabs.join(' ')}]"
    end
  end

  def perplexity
    log_ll = 0.0
    @dataset.each_doc_with_index do |doc, doc_index|
      doc.each_pair do |vocab, count|
        ll = [*0...@num_topics]
             .inject(0.0) { |sum, topic| sum + theta(doc_index, topic) * phi(topic, vocab) }
        log_ll += count * Math.log(ll)
      end
    end
    Math.exp(-log_ll / @dataset.num_words)
  end
end
