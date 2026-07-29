% Test parameters
params = {
    100, 100, 0.05, 0.2, 1, 100, 'call'; % ATM call
    100, 90, 0.05, 0.3, 2, 200, 'put'; % ITM put
    50, 55, 0.02, 0.4, 0.5, 50, 'call'; % OTM call
};

for i = 1:size(params,1)
    [tri, bs] = a(params{i,:});
    fprintf('\nTest Case %d:\n', i);
    fprintf('Trinomial: %.6f\nBlack-Scholes: %.6f\nDifference: %.6f\n', tri, bs, abs(tri-bs));
end