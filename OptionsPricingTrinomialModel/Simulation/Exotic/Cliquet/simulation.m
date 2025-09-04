% Parameters from the paper for Figure 5.1
Floc = 0;       % Local floor
Cloc = 0.08;    % Local cap
Fglob = 0.16;   % Global floor
Cglob = Inf;    % Global cap (no cap)
T = 5;          % Total time
m = 5;          % Number of reset periods
sigma = 0.2;    % Volatility
r = 0.03;       % Risk-free rate
p = 1/6;        % For trinomial model (p=1/6 gives stable results)

% Range of N values (steps per reset period)
N_values = 10:10:200;

% Preallocate arrays
trinomial_prices = zeros(size(N_values));
binomial_prices = zeros(size(N_values));

% Reference price from Monte Carlo (long-term convergence)
reference_price = 0.174;

% Calculate prices for each N
for i = 1:length(N_values)
    N = N_values(i);
    
    % Trinomial price
    trinomial_prices(i) = CliquetPriceTrinomial(Floc, Cloc, Fglob, Cglob, T, m, N, sigma, r, p);
    
    % Binomial price (set p=0.5)
    binomial_prices(i) = CliquetPriceTrinomial(Floc, Cloc, Fglob, Cglob, T, m, N, sigma, r, 0.5);
    
    fprintf('N=%d: Trinomial=%.6f, Binomial=%.6f\n', N, trinomial_prices(i), binomial_prices(i));
end

% Create the plot
figure;
hold on;
grid on;

% Plot trinomial prices (solid line)
plot(N_values, trinomial_prices, 'b-', 'LineWidth', 2, 'DisplayName', 'Trinomial Model');

% Plot binomial prices (dashed line)
plot(N_values, binomial_prices, 'r--', 'LineWidth', 2, 'DisplayName', 'Binomial Model');

% Plot reference price (horizontal line)
yline(reference_price, 'k:', 'LineWidth', 2, 'DisplayName', 'Reference Price (0.174)');

% Format the plot
xlabel('Number of Steps (N)');
ylabel('Cliquet Option Price');
title('Comparison of Trinomial and Binomial Model Prices for Cliquet Option');
legend('Location', 'best');

% Set appropriate axis limits
xlim([min(N_values), max(N_values)]);
ylim([0.16, 0.19]); % Adjust based on your results

hold off;

% Save the figure if needed
% saveas(gcf, 'CliquetPriceComparison.png');

% Helper functions (included for completeness)

function [price] = CliquetPriceTrinomial(Floc, Cloc, Fglob, Cglob, T, m, N, sigma, r, p)
    q0 = 1 - 2 * p;
    h = T / (N * m);
    u = sigma * sqrt(h / (2 * p));
    
    % Calculate risk-neutral probabilities
    qu = (exp(r * h) - exp(-u)) / (exp(u) - exp(-u)) - q0 * (1 - exp(-u)) / (exp(u) - exp(-u));
    qd = (exp(u) - exp(r * h)) / (exp(u) - exp(-u)) - q0 * (exp(u) - 1) / (exp(u) - exp(-u));
    
    % Alpha and P_j
    alpha = ceil(log(Cloc + 1) / u);
    P_j = 0;
    for Nu = alpha:N
        for Nd = 0:min(Nu - alpha, N - Nu)
            P_j = P_j + nchoosek(N, Nu) * nchoosek(N - Nu, Nd) * qu^Nu * qd^Nd * q0^(N - Nu - Nd);
        end
    end
    
    % Beta and P_0
    beta = floor(log(Floc + 1) / u);
    P_0 = 0;
    for Nd = max(0, -beta):N
        for Nu = 0:min(N - Nd, Nd + beta)
            P_0 = P_0 + nchoosek(N, Nd) * nchoosek(N - Nd, Nu) * qu^Nu * qd^Nd * q0^(N - Nu - Nd);
        end
    end
    
    j = alpha - beta;
    P = zeros(1, m);
    Z = zeros(1, m);
    Q = 0;
    
    % Constants vector
    constants = [u, qu, qd, q0, Floc, Cloc, Fglob, Cglob, m, N, alpha, beta, j, P_j, P_0];
    
    % Start recursive algorithm
    Q = RecursionCliquetTrinomial(Z, P, 1, Q, constants);
    price = Q * exp(-r * T);
end

function [Q] = RecursionCliquetTrinomial(Z, P, i, Q, constants)
    % Extract constants
    u = constants(1); qu = constants(2); qd = constants(3); q0 = constants(4);
    Floc = constants(5); Cloc = constants(6);
    Fglob = constants(7); Cglob = constants(8);
    m = constants(9); N = constants(10);
    alpha = constants(11); beta = constants(12); j = constants(13);
    P_j = constants(14); P_0 = constants(15);
    
    % Treat cases where alpha is reached
    P(i) = P_j;
    Z(i) = Cloc;
    if i == m
        P_final = prod(P);
        Z_final = sum(Z);
        Q = Q + P_final * max(Fglob, min(Cglob, Z_final));
    elseif sum(Z) <= (Fglob - (m - i) * Cloc)
        P_final = prod(P(1:i));
        Q = Q + P_final * Fglob;
    else
        Q = RecursionCliquetTrinomial(Z, P, i + 1, Q, constants);
    end
    
    % Treat cases where beta is reached
    P(i) = P_0;
    Z(i) = Floc;
    if i == m
        P_final = prod(P);
        Z_final = sum(Z);
        Q = Q + P_final * max(Fglob, min(Cglob, Z_final));
    elseif sum(Z) <= (Fglob - (m - i) * Cloc)
        P_final = prod(P(1:i));
        Q = Q + P_final * Fglob;
    else
        Q = RecursionCliquetTrinomial(Z, P, i + 1, Q, constants);
    end
    
    % Treat remaining cases
    for diff = (beta + 1):(beta + j - 1)
        P_temp = 0;
        for Nu = max(0, diff):min(N, floor(N/2 + diff/2))
            Nd = Nu - diff;
            if Nd >= 0 && (Nu + Nd) <= N
                P_temp = P_temp + nchoosek(N, Nu) * nchoosek(N - Nu, Nd) * qu^Nu * qd^Nd * q0^(N - Nu - Nd);
            end
        end
        
        P(i) = P_temp;
        % Calculate return (using expected values)
        expected_return = exp(diff * u) - 1;
        Z(i) = max(Floc, min(expected_return, Cloc));
        
        if i == m
            P_final = prod(P);
            Z_final = sum(Z);
            Q = Q + P_final * max(Fglob, min(Cglob, Z_final));
        elseif sum(Z) <= (Fglob - (m - i) * Cloc)
            P_final = prod(P(1:i));
            Q = Q + P_final * Fglob;
        else
            Q = RecursionCliquetTrinomial(Z, P, i + 1, Q, constants);
        end
    end
end