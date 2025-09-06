

% Parameters
S0 = 500;
K1 = 300;
K2 = 150;
T1 = 5/12;
T2 = 30/12;
r = 0.05;
sigma = 0.3;
p = 0.3;

% Range of N values
N_values = 10:10:200;  % Adjust as needed for smoothness

% Preallocate arrays
geske_prices = zeros(size(N_values));
trinomial_prices = zeros(size(N_values));

% Calculate Geske price (constant for all N)
% Using the closed-form Geske formula for CoC option
% Note: We need to implement the Geske formula
geske_price = geske_coe_price(S0, K1, K2, T1, T2, r, sigma);
geske_prices(:) = geske_price;  % Same for all N

% Calculate trinomial price for each N
for i = 1:length(N_values)
    N = N_values(i);
    trinomial_prices(i) = EUCompound_Tri(S0, T1, T2, N, K1, K2, p, r, sigma);
end

% Plot
figure;
plot(N_values, trinomial_prices, 'b-', 'LineWidth', 1.5);
hold on;
plot(N_values, geske_prices, 'r--', 'LineWidth', 1.5);
xlabel('Number of steps N');
ylabel('Option price');
legend('Trinomial price', 'Geske theoretical price');
title('CoC Compound Option Price vs Number of Steps');
grid on;