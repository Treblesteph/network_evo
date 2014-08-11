# Generates a table with all combinations of elements from each choice.
# The 'choices' option should be a tuple of length ncols, containing arrays of
# values that each column can take.

###############################################################################
###############################################################################

function fill_column(rows, cols)
  partitionsize::Int64 = (length(rows))/(length(choices[cols]))
  for j = 1:length(choices[cols])
    c = cols
    partitionstart::Int64 = rows[1] + partitionsize * (j - 1)
    partitionend::Int64 = rows[1] - 1 + partitionsize * j
    partitionrange = partitionstart:partitionend
    multimat[partitionrange, cols] = choices[c][j]
    c -= 1
    if c > 0
      fill_column(partitionrange, c)
    end
  end
end

choices = ([2, 40, 74], [5, 7], [10, 11, 5, 4])
ncols = length(choices)
nrows = prod([length(choices[i]) for i in 1:ncols])
multimat = zeros(Int64, nrows, ncols)

fill_column(1:nrows, ncols)
