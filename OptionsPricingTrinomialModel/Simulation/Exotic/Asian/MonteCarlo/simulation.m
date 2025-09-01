% Parameters
S0 = 10;
K = 8;
r = 0.01;
T = 0.062;  % Time to maturity
sigma = 0.2;
N = 12;     % Number of steps (fixed)

%% list of replicates to test
reps_list = [1500, 2500, 7500, 10000, 15000];

% Preallocate arrays for results
comp_times = zeros(size(reps_list));
prices = zeros(size(reps_list));

% Loop over different numbers of replicates
for i = 1:length(reps_list)
    reps = reps_list(i);
    
    % Start timer
    tic;
    
    % Calculate Asian call price
    price = AsianCall(S0, K, r, T, sigma, N, reps);
    
    % Record time
    comp_time = toc;
    
    % Store results
    comp_times(i) = comp_time;
    prices(i) = price;
end

% Display results in a table
fprintf('Replicates\tComputational Time (s)\tPrice\n');
for i = 1:length(reps_list)
    fprintf('%d\t\t%.4f\t\t\t%.4f\n', reps_list(i), comp_times(i), prices(i));
end

% Optionally, plot computational time vs replicates
figure;
plot(reps_list, comp_times, 'o-');
xlabel('Number of Replicates');
ylabel('Computational Time (s)');
title('Computational Time for Monte Carlo Simulation (Asian Option)');
grid on;