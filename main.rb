# coding: utf-8

require './cvb0_lda'

lda = LDA.new(10)
lda.setup('docword.kos.txt', 'vocab.kos.txt')
# p lda.n_jk[1]
# p lda.n_jk[1].to_a.flatten
# p lda.n_jk[1][0,3]
# p lda.theta(1, 1)
# p lda.phi(1, 3000)
lda.cvb0
# p lda.n_jk[1]
# p lda.n_jk[1].to_a.flatten
# p lda.n_jk[1][0,3]
# p lda.theta(1, 1)
# p lda.phi(1, 3000)
#10.times { lda.cvb0 }
lda.print_result
p lda.perplexity
