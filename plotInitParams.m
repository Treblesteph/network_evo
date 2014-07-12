function plotInitParams(ALL_NETWORKS, INDICES, PARAMS)
%PLOTINITPARAMS - Plots the distributions of all the parameters in initial
%populations of networks.
%   Takes the ALL_NETWORKS file and makes a histogram of each column
%   (parameter) distribution. Should be uniform.
PARAMS_TITLE = cell(size(ALL_NETWORKS(1, : )));
counteri = 1;
for i = 1 : length(PARAMS)
    param = PARAMS{i}; indexi = INDICES(param); lengthi = length(indexi);
    for j = 1 : lengthi
        PARAMS_TITLE{counteri} = PARAMS{i};
        counteri = counteri + 1;
    end
end
[ ~ , ncol] = size(ALL_NETWORKS);
for n1 = 1 : ncol/2
        figure(1)
        subplot(8, 4, n1)
        hist(ALL_NETWORKS( : , n1))
        title(PARAMS_TITLE(n1))
end
ind1 = 1;
for n2 = 1 + ncol/2 : ncol
    figure(2)
    subplot(8, 4, ind1)
    hist(ALL_NETWORKS( : , n2))
    title(PARAMS_TITLE(n2))
    ind1 = 1 + ind1;
end

