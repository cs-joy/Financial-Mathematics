% Parameters from the paper (Table 5.1)
S0 = 10;
K = 8;
r = 0.01;
T = 0.062;   % Time to maturity
sigma = 0.2;
p = 0.25;    % Probability for up/down (p_u = p_d = p)

N = 11;

h = T / N;   % Time step
u = sigma * sqrt(h/(2*p)); % up factor % h/2p->0.0212 h>0.0150
fprintf("u= %.4f\n", u);

q0 = 1 - 2*p;
qu = (exp(r*h) - exp(-u) - q0*(1 - exp(-u))) / (exp(u) - exp(-u));
qd = (exp(u) - exp(r*h) - q0*(exp(u)-1)) / (exp(u) - exp(-u));

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
    
% Call recursive function
[V, P_tot] = RecursiveAsian(V, N, K, n, P_tot, P, Q, M, allS);
    
% Discount the price
price = exp(-r*T) * V;
fprintf("fair-price: %.4f\n", price);