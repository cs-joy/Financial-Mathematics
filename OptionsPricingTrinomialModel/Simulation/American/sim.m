% Main script to calculate American put option price
clear all; close all; clc;

% Parameters
% alpha = 0.01;
% k = 10;
% r = 0.01;
% N = 1:100;
% T = 1/12;
% sigma = 0.02;
% S0 = 10;

alpha = 0.01;
k = 10;
r = 0.01;
N = 1:100;
T = 10/252;
sigma = 0.5;
S0 = 10;

% Initialize arrays to store results
A_trinomial = zeros(length(N), 1);
A_binomial = zeros(length(N), 1);

% Calculate option prices for different N values
for n_idx = 1:length(N)
    n = N(n_idx);
    
    % Trinomial model (p = 0.4)
    p = 0.4;
    h = T/n;
    u = sigma*sqrt(h/2*p);
    S = StockPricesnew(S0, n, u);
    AP = AmericanPut(S, k, r, n, p, h, u);
    A_trinomial(n_idx) = AP(n+1, 1);
    
    % Binomial model (p = 0.5)
    p = 0.5;
    h = T/n;
    u = sigma*sqrt(h/2*p);
    S = StockPricesnew(S0, n, u);
    AP = AmericanPut(S, k, r, n, p, h, u);
    A_binomial(n_idx) = AP(n+1, 1);
end

% Plot results
figure;
plot(N, A_trinomial);
hold on;
plot(N, A_binomial);
legend('Trinomial Model', 'Binomial Model');
xlabel('N (Number of Steps)');
ylabel('American Put Option Price');
title('Convergence of American Put Option Prices');
grid on;

% Display final values
fprintf('Final Trinomial Price (N=%d): %.6f\n', N(end), A_trinomial(end));
fprintf('Final Binomial Price (N=%d): %.6f\n', N(end), A_binomial(end));