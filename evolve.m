function [ALL_NETWORKS, TOP_NETWORKS, TOP_NET_FITNESS] = evolve(STRESS_IN, plots)
%EVOLVE - For evolution of genetic networks. STRESS_IN is an nx3 matrix
%of n stress pulses. Column three contains the stress amplitudes, and columns
%one and two contain the start and stop time points of each stress pulse
%respectively. Plots is boolean, set to 1 for plotting all initial
%population networks, and set to 0 for only plotting the 10 fittest.
%------------------------------------------------------------------------------
%---OTHER FUNCTIONS REQUIRED TO RUN THIS FUNCTION:
%---
%---
%------------------------------------------------------------------------------
%   1. Defines the population, and all parameters and variables:
%       Variables are the N_GENE nodes in the network (default to 3 or 4)
%       Parameters are all the interactions/rates etc. n^3 in total (half
%       boolean and half real-valued) for an n-gene network.
%   2. Define fitness and objective functions, and determine the fitness of
%       all networks in the population.
%   3. Perform selection processes to determine which networks will
%       survive/reproduce to create the next generation.
%   4. Perform clonal reproduction, mutations, and crossovers.
%   5. Terminate the GA and return the successful final population.
%

%---------------------------------Model logic----------------------------------
% Generate fundamental variables, and set random, recordable seed.
[N_GENE, N_NETWORK, N_GENERATION, seed, TOT_DURATION] = fund_init();
rng(seed);                               
% Setting parameter value intervals.
[PARAM, MINS, MAXS, TYPE, INDEX, N_PARAM] = setup_params(N_GENE);
% Setting up the matrix of all networks (encoded by their list of
% parameters).
[ALL_NETWORKS, LENGTH] = make_population(MINS, MAXS, N_NETWORK, ...
    N_PARAM, INDEX, PARAM, TYPE);
% Generating column, FITNESS, of fitness values for each network (row of 
% population), also fitness absolute value, and overall rank of each network.
[FITNESS, FIT_VAL, FIT_RANK, PLOTS] = ...
    fitness_setup(ALL_NETWORKS, INDEX, N_GENE, STRESS_IN, TOT_DURATION, plots);
% Determine the fittest 9 circuits
TOP_NETWORKS = ALL_NETWORKS(FIT_RANK(1 : 9), : );
TOP_NET_FITNESS = FIT_VAL(1 : 9);
% Plotting top 9 networks with their fitness values, and stress indicated
% in greyed out rectangles.
if plots == 0
    for r = 1 : 9
        figure(1)
        subplot(3, 3, r)
        for tt = 1 : length(STRESS_IN( : , 1))
            xVals = STRESS_IN(tt, 1 : 2);
            yVals = 1000 * [STRESS_IN(tt, 3), STRESS_IN(tt, 3)];
            area([xVals, xVals], [yVals, yVals], 'FaceColor', [0.8, 0.8, 0.8])
            hold on
        end
        axis([0, TOT_DURATION, 0, max(PLOTS{FIT_RANK(r)}(:))])
        plot(PLOTS{FIT_RANK(r)}(:, 1), PLOTS{FIT_RANK(r)}(:, 2:end))
        xlabel('time (hours)'); ylabel('gene concentration');
        fitTitle = num2str((FIT_VAL(r)));
        title(['fitness is ' fitTitle])
    end

end

%----------------------------------Functions:----------------------------------

function [N_GENE, SIZE_POPULATION, N_GENERATION, seed, TOT_DURATION] = ...
              fund_init()
% Generate fundamental variables, and set random, recordable seed.
    N_GENE = 4;                     % Number of genes in each network.
    SIZE_POPULATION = 20;   % Number of networks in population.
    N_GENERATION = 500;     % Number of generations to run for.
    TOT_DURATION = 300;     % Number of hours to run each generation for.
    rng('shuffle');                    % Generating a random, recordable
    seed = 1 + round(rand * 100); %     seed to maintain reproducability
                                                   %     without introducing
                                                   %     predictability.
end
function [PARAM, MINS, MAXS, TYPE, INDEX, N_PARAM] = setup_params(N_GENE)
    PARAM = {'BASAL_TRANS', 'MAX_TRANS', 'DEGRADATION', 'DELAY', ...
                     'STRENGTH_INTERACTION', 'REG_INDICATOR', 'ACT_INDICATOR'};
    MINS = containers.Map(PARAM, {1e-3, 1e2, 1e-1, 0.25, 1e-5, 0, 0});
    MAXS = containers.Map(PARAM, {1e3, 1e5, 1e1, 14, 1e-1, 1, 1});
    % Setting parameter value types (real-valued/boolean).
    TYPE = containers.Map(PARAM, {'realV', 'realV', 'realV', 'realV', ...
                                                     'realV', 'bool', 'bool'});
    % Setting index shortcuts for all parameters.
    INDEX = containers.Map(PARAM, ...
                {1 : N_GENE, ...
                 1 + N_GENE : N_GENE * 2, ...
                 1 + 2 * N_GENE : N_GENE * 3, ...
                 1 + 3 * N_GENE : N_GENE * 4, ...
                 1 + 4 * N_GENE : N_GENE * (4 + N_GENE), ...
                 1 + N_GENE * (4 + N_GENE) : N_GENE * (4 + 2 * N_GENE), ...
                 1 + N_GENE * (4 + 2 * N_GENE) : N_GENE * (4 + 3 * N_GENE)});
    % Number of parameters in total (across all variables).
    N_PARAM = N_GENE * (4 + 3 * N_GENE);
end
function [ALL_NETWORKS, LENGTH] = make_population(MINS, MAXS, N_NETWORK, ...
    N_PARAM, INDEX, PARAM, TYPE)
    % Initialising matrix of networks (one per row, with one parameter per
    % column). Also initialising the container map with quantities of each
    % parameter name.
    ALL_NETWORKS = zeros(N_NETWORK, N_PARAM);
    LENGTH = containers.Map();
    % Filling with random starting values (plus recording the number of
    % parameters for each parameter name).
    for nn = 1 : length(PARAM)
        nnIndex = INDEX(PARAM{nn});
        LENGTH(PARAM{nn}) = length(nnIndex);
        nnMin = MINS(PARAM{nn}); nnMax = MAXS(PARAM{nn});
        % Filling real-valued parameters with uniformly distributed random
        % numbers in their specified ranges.
        if strcmp(TYPE(PARAM{nn}), 'realV') 
            ALL_NETWORKS( : , nnIndex) = (nnMax - nnMin) .* ...
                rand(size(ALL_NETWORKS( : , nnIndex))) + nnMin;
        % Filling boolean parameters with uniformly distributed zeros and ones.
        elseif strcmp(TYPE(PARAM{nn}), 'bool')
            ALL_NETWORKS( : , nnIndex) = ...
                randi(2, size(ALL_NETWORKS( : , nnIndex))) - 1;
        end
    end
end
function [FITNESS, FIT_VAL, FIT_RANK, PLOTS] = ...
    fitness_setup(ALL_NETWORKS, INDEX, N_GENE, STRESS_IN, TOT_DURATION, plots)
    [nrow, ~] = size(ALL_NETWORKS);
    % Initialise matrix of all concentrations and times for plotting.
    PLOTS = cell(1, nrow);
    % Initialise column of fitness values for all networks in population.
    FITNESS = zeros(size(ALL_NETWORKS( : , 1)));
    % Add in values for absolute fitness by running fitness calculation for
    % each row of ALL_NETWORKS matrix.
    for row = 1 : nrow
        if plots == 1
            figure(row)
        end
        [FITNESS(row), PLOTS{row}] = fitness_calc(ALL_NETWORKS(row, : ), ...
            INDEX, N_GENE, STRESS_IN, TOT_DURATION, plots);
        if plots == 1
            figure(row)
            fitTitle = num2str(FITNESS(row));
            title(['fitness is ' fitTitle])
        end
    end
    % Rank the network fitnesses in descending order, and keep track of
    % which network each was associated with.
    [FIT_VAL, FIT_RANK] = sort(FITNESS, 'descend');
end
function [FITNESS_ROW, ROW_PLOT] = ...
    fitness_calc(NETWORK, INDEX, N_GENE, STRESS_IN, TOT_DURATION, plots)
% Determining the fitness of each individual network (row).

    % Decoding parameters into variables for clarity in DDEs.
    BASAL_TRANS = NETWORK(INDEX('BASAL_TRANS'));
    MAX_TRANS = NETWORK(INDEX('MAX_TRANS'));
    DEGRADATION = NETWORK(INDEX('DEGRADATION'));
    DELAY = NETWORK(INDEX('DELAY'));
    STRENGTH_INTERACTION = NETWORK(INDEX('STRENGTH_INTERACTION'));
    REG_INDICATOR = NETWORK(INDEX('REG_INDICATOR'));
    ACT_INDICATOR = NETWORK(INDEX('ACT_INDICATOR'));
    % Looping over intervals between stress input pulses and solving ddes
    % between each time point. Then integrating between each time point to
    % give the integrated values for each gene to determine fitness.
    [N_PULSES, ~] = size(STRESS_IN);
    INT_TIMES = sort([0, STRESS_IN( : , 1)', ...
                STRESS_IN(N_PULSES, 2)', TOT_DURATION]);
    historyValues = ones(N_GENE, 1);
    sol = dde23(@ddesetup, DELAY, historyValues, [0, TOT_DURATION]);
    ROW_PLOT = [sol.x', sol.y'];
    % Determining amount of G1 to compute the fitness.
    % Initialising array of G1 integrals to sum over stress/no stress 
    % intervals.
    allG1NoStress = zeros(1, 1 + length(STRESS_IN( : , 1)));
    allG1Stress = zeros(1, length(STRESS_IN( : , 1)));
    for t = 1 : (length(INT_TIMES) - 1) / 2
        % During stress time intervals, if gene 1 is not expressed, the
        % fitness is not affected. If gene 1 is expressed, the fitness
        % increases according to the amount of G1 expressed during the
        % stress period. During no stress periods, if gene 1 is on, there
        % is a slight fitness cost.
        % COST =
        %           _                                         _
        % ''''     |      T                        T           |
        %          |    |^                        |^           |
        %     T    |    | G1 dt                   |  G1 dt     |
        %   _____  |   _|                        _|            |
        %   \      |   0                         0             |
        %    \     | ..............  -- 0.1 x  ..............  |
        %    /     |      2(t+1)                    2t+1       |
        %   /____  |    |^                        |^           |
        %   t = 0  |    | G1 dt                   | G1 dt      |
        %          |   _|                        _|            |
        %          |_ 2t+1                      2t            _|
        %                 
        allG1NoStress(t) = trapz(sol.x(2 * t - 1 : 2 * t), ...
                                 sol.y(1, 2 * t - 1 : 2 * t));
        allG1Stress(t) = trapz(sol.x(2 * t : 2 * t + 1), ...
                               sol.y(1, 2 * t : 2 * t + 1));
    end
    allG1NoStress = sum(allG1NoStress);
    allG1Stress = sum(allG1Stress);
    COST_VALUE = trapz(sol.x, sol.y(1, : )) * ...
                 ((1 / (allG1Stress)) - ...
                 (0.1 / (allG1NoStress)));
    FITNESS_ROW = 1 / COST_VALUE;
    % Marking stress input in grey rectangles on plot.
    top = max(sol.y(:));
    for tt = 1 : length(STRESS_IN( : , 1))
        xVals = STRESS_IN(tt, 1 : 2);
        yVals = [top, top];
        area([xVals, xVals], [yVals, yVals], 'FaceColor', [0.8, 0.8, 0.8])
        hold on
    end
    if plots == 1
        axis([0, TOT_DURATION, 0, max(sol.y(:))])
        plot(sol.x, sol.y)
        xlabel('time (hours)'); ylabel('gene concentration');
    end
    %--------------------------------------------------------------------------
    % Setting up DDE equations to be used by dde23 delay differential
    % equation solver. Where t is the current time, G is the concentrations
    % of all genes at the present time, and G_LAG is the concentration of
    % all genes after a lag.
    function dGdt = ddesetup(~, G, G_LAG)
    % This function is required (by the dde23 solver) in order to define the
    % delay differential equations to be solved.
        
        % Explanation of lags: G_LAG(i, j) = the value of gene j after the
        % response time of gene i. This is computed by the dde solver as long
        % as the DELAY array is fed into that.
    
        % Converting STRENGTH, REG_INDICATOR, and ACT_INDICATOR into matrices
        % of size N_GENE x N_GENE, instead of vectors of length N_GENE^2.
        STRENGTH_MAT = zeros(N_GENE);
        REGULATE_MAT = zeros(N_GENE);
        ACTIVATE_MAT = zeros(N_GENE);
        j = 1;
        for i = 1 : N_GENE
            STRENGTH_MAT(i, : ) = STRENGTH_INTERACTION(j : j + N_GENE - 1);
            REGULATE_MAT(i, : ) = REG_INDICATOR(j : j + N_GENE - 1);
            ACTIVATE_MAT(i, : ) = ACT_INDICATOR(j : j + N_GENE - 1);
            j = j + N_GENE;
        end
        % Now the following are descriptions of all interactions:
        % --- ACTIVATE(i, j) = 1 if gene i is activated by gene j.
        %                                0 if gene i is repressed by gene j.
        % --- REGULATE(i, j) = 1 if gene i is regulated by gene j.
        %                                 0 if gene i is not regulated by gene j.
        % --- STRENGTH(i, j) = the strength of regulation of gene i by gene j.
        %--------------------------Differential equations----------------------
        %                                     __           __ 2
        %                      ____          |   Gj(t - L)   |
        %                      \    Aij Rij  |   ----------  |
        %  dGi           Bi +  /___          |_     Kij     _|
        % -----  = Mi -------------------------------------------   -- Di Gi(t)
        %   dt                                __           __ 2
        %                         _____      |   Gj(t - L)   | 
        %               1 + Bi +  \    Rij   |   ----------  |
        %                         /____      |_     Kij     _|
        %----------------------------------------------------------------------
        dGdt = MAX_TRANS' .* ...
                    ((BASAL_TRANS' + ...
                    (sum(ACTIVATE_MAT' .* REGULATE_MAT' .* ...
                        ((G_LAG ./ STRENGTH_MAT') .^ 2)))') ./ ...
                    (1 + BASAL_TRANS' + ...
                    (sum(REGULATE_MAT' .* ...
                        ((G_LAG ./ STRENGTH_MAT') .^ 2)))')) - ...
                    DEGRADATION' .* G;
    end
end