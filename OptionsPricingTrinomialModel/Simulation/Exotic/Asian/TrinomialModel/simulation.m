% Parameters from the paper (Table 5.1)
S0 = 10;
K = 8;
r = 0.01;
T = 0.062;   % Time to maturity
sigma = 0.2;
p = 0.25;    % Probability for up/down (p_u = p_d = p)

% Since the trinomial model requires u and risk-neutral probabilities:
% We set u = sigma * sqrt(T/N) (adjust for each N) but note: in the paper they use a fixed u?
% Actually, in the trinomial model, u is often chosen as u = sigma * sqrt(3 * dt) for stability, but we follow the paper.

% List of N (number of steps) to test
N_list = [10, 11, 12, 13, 14];   % As in Table 5.1

% Preallocate arrays for results
comp_times = zeros(size(N_list));
prices = zeros(size(N_list));

% Loop over different N
for i = 1:length(N_list)
    N = N_list(i);
    h = T / N;   % Time step
    
    % Calculate u: we use u = sigma * sqrt(h) (as in the paper for convergence)
    u = sigma * sqrt(h);
    
    % Risk-neutral probabilities
    % qu = (exp(r*h) - exp(-u)) / (exp(u) - exp(-u)) - q0 * (1 - exp(-u)) / (exp(u) - exp(-u));
    % qd = (exp(u) - exp(r*h)) / (exp(u) - exp(-u)) - q0 * (exp(u)-1) / (exp(u) - exp(-u));
    % But note: the paper uses p_u = p_d = p = 0.25, and q0 = 1 - 2p = 0.5?
    % Actually, the risk-neutral probabilities are computed with q0 free? But in the function we pass Q = [qu, q0, qd].
    % However, the paper sets p_u = p_d = p = 0.25, so we set q0 = 1 - 2p = 0.5? But wait: the risk-neutral probabilities are different.
    % Alternatively, we can set the risk-neutral probabilities to match the paper's condition for convergence?
    % Actually, the function RecursiveAsian uses risk-neutral probabilities Q = [qu, q0, qd].
    % We need to compute qu, q0, qd such that the martingale condition holds.
    
    % We set q0 = 1 - 2p = 0.5 (since p=0.25) but this is not necessarily risk-neutral.
    % Instead, we compute the risk-neutral probabilities correctly:
    q0 = 1 - 2*p;   % This is actually the physical probability for no move? But we need risk-neutral.
    % Actually, the risk-neutral probabilities must satisfy: qu * e^u + q0 + qd * e^{-u} = e^{r*h}
    % and qu + q0 + qd = 1.
    % We have q0 = 1 - 2p (given), and we set qu = qd = p (for symmetry) but this may not be risk-neutral.
    % Alternatively, we solve for qu and qd given q0:
    % qu = (exp(r*h) - exp(-u) - q0*(1 - exp(-u))) / (exp(u) - exp(-u));
    % qd = (exp(u) - exp(r*h) - q0*(exp(u)-1)) / (exp(u) - exp(-u));
    qu = (exp(r*h) - exp(-u) - q0*(1 - exp(-u))) / (exp(u) - exp(-u));
    qd = (exp(u) - exp(r*h) - q0*(exp(u)-1)) / (exp(u) - exp(-u));
    
    % Check: qu + q0 + qd should be 1.
    tol = 1e-10;
    if abs(qu + q0 + qd - 1) > tol
        error('Probabilities do not sum to 1.');
    end
    
    Q = [qu, q0, qd];   % Risk-neutral probabilities
    M = [u, 0, -u];     % Moves: up, same, down
    
    % Initialize for recursion
    V = 0;
    P_tot = 0;
    n = 1;   % Start at step 1
    P = 1;   % Initial probability
    allS = [S0];   % Initial stock price
    
    % Start timer
    tic;
    
    % Call recursive function
    [V, P_tot] = RecursiveAsian(V, N, K, n, P_tot, P, Q, M, allS);
    
    % Discount the price
    price = exp(-r*T) * V;
    
    % Record time
    comp_time = toc;
    
    % Store results
    comp_times(i) = comp_time;
    prices(i) = price;
end

% Display results in a table
fprintf('N\tComputational Time (s)\tInitial Price\n');
for i = 1:length(N_list)
    fprintf('%d\t%.4f s\t\t\t%.4f\n', N_list(i), comp_times(i), prices(i));
end

figure;
plot(N_list, comp_times, 'o-');
xlabel('Number of Steps (N)');
ylabel('Computational Time (s)');
title('Computational Time for Trinomial Model (Asian Option)');
grid on;