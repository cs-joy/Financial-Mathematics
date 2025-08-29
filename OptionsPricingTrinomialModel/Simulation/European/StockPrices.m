function S=StockPrices(S_0, N, u)
    S = zeros(2*N+1, N+1);
    S(N+1, 1) = S_0;

    for col=2: (N+1)
        S(:, col) = S(:, col-1);
        S(N+2-col, col) = S(N+3-col, col-1)*exp(u);
        S(N+col, col) = S(N+col-col, col-1)*exp(-u);
    end
end
