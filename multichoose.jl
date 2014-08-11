# Generates a table with all combinations of elements from each choice.
# The 'choices' option should be a tuple of arrays containing values that
# each column can take.

function multichoose(choices::Tuple{Array{Int64}})
  ncols::Int64 = length(choices)
  nrows::Int64 = prod([length(choices[i]) for i in 1:ncols])
  multimat::Array{Int64} = zeros(Int64, nrows, ncols)
  fill_column(1:nrows, ncols)
end

function fill_column(rows, cols)
  partitionsize::Int64 = (length(rows))/(length(choices[cols]))
  for j = 1:length(choices[cols])
    c::Int64 = cols
    partitionstart::Int64 = rows[1] + partitionsize * (j - 1)
    partitionend::Int64 = rows[1] - 1 + partitionsize * j
    partitionrange::UnitRange{Int64} = partitionstart:partitionend
    multimat[partitionrange, cols] = choices[c][j]
    c -= 1
    if c > 0
      fill_column(partitionrange, c)
    end
  end
end
