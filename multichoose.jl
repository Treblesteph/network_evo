# Generates a table with all combinations of elements from each choice.
# The 'choices' option should be a tuple of length ncols, containing arrays of
# values that each column can take.

ncols = 3
choices = ([1,0], [1,0], [-1, 1, 0])

nrows = prod([length(choices[k]) for k in 1:ncols])
multimat = zeros(Int64, nrows, ncols)

function fill_column(row, col)
  n = col
  nchoices = length(choices[n])
  println("nchoices: $(nchoices)")
  for k = 1:nchoices
    while n > 1
      partition::Int64 = row/nchoices
      println("partition: $partition")
      partitionrange = (1+partition*(k-1)):(partition*k)
      println("partitionrange: $partitionrange")
      multimat[partitionrange,n] = choices[n][k]
      n -= 1
      fill_column(partition, n)
    end
  end
end

fill_column(nrows, ncols)
