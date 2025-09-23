% Parameters
% S0 = 500;
% K1 = 300;
% K2 = 150;
% T1 = 5/12;
% T2 = 30/12;
% r = 0.05;
% sigma = 0.3;
% p = 0.3;

S0 = 100;
K1 = 15;
K2 = 100;
T1 = 0.5;
T2 = 1.0;
r = 0.05;
sigma = 0.25;
p = 0.3;

N_values = 10:10:450;

% Preallocate arrays
geske_prices = zeros(size(N_values));
trinomial_prices = zeros(size(N_values));

% Calculate Geske price (constant for all N)
% Using the closed-form Geske formula for CoC option
geske_price = EUCompound_BS(S0, r, sigma, T1, T2, K1, K2);
geske_prices(:) = geske_price;  % Same for all N

% Calculate trinomial price for each N
% for i = 1:length(N_values)
%     N = N_values(i);
%     trinomial_prices(i) = EUCompound_Tri(S0, T1, T2, N, K1, K2, p, r, sigma);
% end
N = 450;
s_trinomial_prices = EUCompound_Tri(S0, T1, T2, N, K1, K2, p, r, sigma);

g_price = geske_prices;
fprintf("gprice= %.4f\n", geske_price);
% n = 450/10;
% t_price = trinomial_prices(n);
fprintf("s_trinomial_prices= %.4f\n", s_trinomial_prices);

% Plot
% figure;
% plot(N_values, trinomial_prices, 'b-');
% hold on;
% plot(N_values, geske_prices, 'r--');
% xlabel('N');
% ylabel('Option price');
% legend('Trinomial price', 'Theoretical price');