clear all;
clc;


T = 10/252;
S0 = 10;
K = 10;
r = 0.01;
sigma = 0.2;
N_values = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
p_values = [0.1, 0.2, 0.3, 0.4, 0.5];

%% calculate Black-Scholes price
BS_price = blsprice(S0, K, r, T, sigma);

%% error table for storing the value
error_table = zeros(length(N_values), length(p_values));


for i = 1:length(N_values)
    N = N_values(i);
    h = T / N;
    
    
    for j = 1:length(p_values)
        p = p_values(j);
        u = sigma * sqrt(h / (2*p));   %% from Theorem 4.1.1
        q0 = 1 - 2*p;                  %% from Theorem 4.1.1
        
        %% generate trinomial stock price tree
        %S_tree = generate_trinomial_tree(S0, u, N);
        S_tree = StockPrices(S0, N, u);
        
        %% payoff
        payoff_func = @(x) max(x - K, 0);
        
        %% compute trinomial option price
        trinomial_price = OptionPrices_h(S_tree, payoff_func, r, p, h, u);
        
        %% extract initial price (center of first column)
        M = size(trinomial_price, 1);
        trinomial_price_initial = trinomial_price((M+1)/2, 1);
        
        %% compute absolute error
        error_table(i, j) = abs(trinomial_price_initial - BS_price);
    end
end

%% display Table 4.1
disp('Table 4.1: Error (|Trinomial - BS|) for different N and p');
disp('N     p=0.1    p=0.2    p=0.3    p=0.4    p=0.5');
for i = 1:length(N_values)
    fprintf('%2d    ', N_values(i));
    for j = 1:length(p_values)
        fprintf('%.6f  ', error_table(i, j));
    end
    fprintf('\n');
end

%% plot Error vs. p for N=20
N_fixed = 20;
h_fixed = T / N_fixed;
errors_fixed = zeros(size(p_values));

for j = 1:length(p_values)
    p = p_values(j);
    u = sigma * sqrt(h_fixed / (2*p));
    q0 = 1 - 2*p;
    
    %% generate tree and compute price
    S_tree = StockPrices(S0, N_fixed, u);
    payoff_func = @(x) max(x - K, 0);
    trinomial_price = OptionPrices_h(S_tree, payoff_func, r, p, h_fixed, u);
    M = size(trinomial_price, 1);
    trinomial_price_initial = trinomial_price((M+1)/2, 1);
    
    errors_fixed(j) = abs(trinomial_price_initial - BS_price);
end

figure;
plot(p_values, errors_fixed, 'o-', 'LineWidth', 1.5);
hold on;
binomial_error = errors_fixed(end); % p=0.5
plot(p_values, binomial_error * ones(size(p_values)), '--', 'LineWidth', 0.2);
xlabel('p');
ylabel('Error');
title('Error for the trinomial model as a function of p (N=20)');
legend('Trinomial error', 'Binomial error (p=0.5)');
grid on;
