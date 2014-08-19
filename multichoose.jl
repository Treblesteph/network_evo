# Generates a table with all combinations of elements from each choice.
# The 'choices' option should be a tuple of arrays containing values that
# each column can take.

function multichoose(choices::Array{Array{Int64}})
  ncols::Int64 = length(choices)
  nrows::Int64 = prod([length(choices[i]) for i in 1:ncols])
  multimat::Array{Int64} = zeros(Int64, nrows, ncols)
  fill_column(choices, 1:nrows, ncols, multimat)
  return multimat
end

function fill_column(choices::Array{Array{Int64}}, rows,
                     cols, multimat::Array{Int64})
  partitionsize::Int64 = (length(rows))/(length(choices[cols]))
  for j = 1:length(choices[cols])
    c::Int64 = cols
    partitionstart::Int64 = rows[1] + partitionsize * (j - 1)
    partitionend::Int64 = rows[1] - 1 + partitionsize * j
    partitionrange::UnitRange{Int64} = partitionstart:partitionend
    multimat[partitionrange, cols] = choices[c][j]
    c -= 1
    if c > 0
      fill_column(choices, partitionrange, c, multimat)
    end
  end
end

function call_multi()
  x1::Array{Int64} = [1, 0]
  x2::Array{Int64} = [1, 0]
  x3::Array{Int64} = [1, 0]
  x4::Array{Int64} = [0, 1, -1]
  x::Array{Array{Int64}} = Array[x1, x2, x3, x4]
  multichoose(x)
end

call_multi()