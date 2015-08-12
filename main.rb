# coding: utf-8

require './cvb0_lda'

unless ARGV.length == 4
  puts "Usage: #{__FILE__} docword vocab num_topics num_iteration"
  exit
end
docword, vocab = ARGV[0, 2]
num_topics, num_iteration = ARGV[2, 2].map(&:to_i)

lda = LDA.new(num_topics)
lda.setup(docword, vocab)
1.upto(num_iteration) do |i|
  puts "iteration #{i}"
  lda.cvb0
  p lda.perplexity
end
lda.print_result
