addpath("Asian/TrinomialModel/");
addpath("Asian/MonteCarlo/");

% Parameters from Table 5.3
S0 = 10;
K = 8;
r = 0.01;
T = 0.062;
N = 12;         % Number of steps for trinomial and Monte Carlo
p = 0.25;       % For trinomial model
reps = 10000;   % Number of replicates for Monte Carlo

% Volatilities to test
sigma_list = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6];

% Preallocate arrays for results
T_price = zeros(size(sigma_list));   % Trinomial price
MC_price = zeros(size(sigma_list));  % Monte Carlo price
MC_var = zeros(size(sigma_list));    % Monte Carlo variance
BS_price = zeros(size(sigma_list));  % Black-Scholes European call price

% Loop over different volatilities
for i = 1:length(sigma_list)
    sigma = sigma_list(i);
    h = T / N;
    u = sigma * sqrt(h);
    
    % Calculate risk-neutral probabilities for trinomial model
    q0 = 1 - 2*p;
    qu = (exp(r*h) - exp(-u) - q0*(1 - exp(-u))) / (exp(u) - exp(-u));
    qd = (exp(u) - exp(r*h) - q0*(exp(u)-1)) / (exp(u) - exp(-u));
    
    Q = [qu, q0, qd];
    M = [u, 0, -u];
    
    % Compute trinomial price
    V = 0;
    P_tot = 0;
    n = 1;
    P_init = 1;
    allS = S0;
    
    [V, P_tot] = RecursiveAsian(V, N, K, n, P_tot, P_init, Q, M, allS);
    T_price(i) = exp(-r*T) * V;
    
    % Compute Monte Carlo price (run multiple times to get variance)
    n_runs = 100;  % Number of MC runs to calculate variance
    mc_prices = zeros(1, n_runs);
    
    for j = 1:n_runs
        mc_prices(j) = AsianCall(S0, K, r, T, sigma, N, reps);
    end
    
    MC_price(i) = mean(mc_prices);
    MC_var(i) = var(mc_prices);
    
    % Compute Black-Scholes European call price
    d1 = (log(S0/K) + (r + sigma^2/2)*T) / (sigma*sqrt(T));
    d2 = d1 - sigma*sqrt(T);
    BS_price(i) = S0*normcdf(d1) - K*exp(-r*T)*normcdf(d2);
end

% Display results in a table
fprintf('Sigma\tT-price\tMC-price\tVar\t\tB-S price\n');
for i = 1:length(sigma_list)
    fprintf('%.1f\t%.4f\t%.4f\t%.2e\t%.4f\n', ...
            sigma_list(i), T_price(i), MC_price(i), MC_var(i), BS_price(i));
end

% Plot results for visual comparison
figure;
subplot(2,1,1);
plot(sigma_list, T_price, 'DisplayName', 'Trinomial'); % o-
hold on;
plot(sigma_list, MC_price, 'DisplayName', 'Monte Carlo'); % s-
plot(sigma_list, BS_price, 'DisplayName', 'Black-Scholes'); % ^-
xlabel('Volatility (\sigma)');
ylabel('Option Price');
title('Asian Option Prices vs Volatility');
legend('show');
grid on;

subplot(2,1,2);
semilogy(sigma_list, MC_var, 'o-', 'LineWidth', 2);
xlabel('Volatility (\sigma)');
ylabel('Variance');
title('Monte Carlo Variance vs Volatility');
grid on;

% AsianCall function for Monte Carlo simulation
function AC = AsianCall(S0, K, r, T, sigma, N, reps)
    dt = T/N;
    R = exp(-r*T);
    S = zeros(reps, N);
    S(:,1) = S0;
    drift = (r - 0.5*sigma^2)*dt;

    for n = 1:reps
        for t = 2:N
            dW = randn(1)*sqrt(dt);
            S(n,t) = S(n,t-1)*exp(drift + sigma*dW);
        end
        Average(n) = mean(S(n,:));
    end

    Payoff = max(Average - K, 0);
    AC = R * mean(Payoff);
end

% RecursiveAsian function for trinomial model
function [V, P_tot] = RecursiveAsian(V, N, K, n, P_tot, P, Q, M, allS)
    allS_prev = allS;
    S_prev = allS(end);
    P_prev = P;

    for i = 1:3
        allS = [allS_prev, S_prev * exp(M(i))];
        P = P_prev * Q(i);

        if n == N
            P_tot = P_tot + P;
            % Calculate payoff using arithmetic average
            V = V + P * max(mean(allS(2:end)) - K, 0);
        else
            [V, P_tot] = RecursiveAsian(V, N, K, n+1, P_tot, P, Q, M, allS);
        end
    end
end