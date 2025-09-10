% AsianCall calculates the price of an Asian call option by using
% Monte Carlo simulation. 
% T -> is the time to maturity, 
% Nsteps -> is the number of steps, 
% Nreps -> is the number of times a path and a price is calculated, 
% S0 -> is the initial stock price, 
% K -> is the strike price,
% r>=0 is the risk-free interest rate, and 
% sigma -> is the volatility of the underlying stock.
%%%%%%%%%%%%%%%%%%%
% The stock path is calculated as
% S_t = S_0*exp(r-0.5*sigma^2+sigma*sqrt(t)*Z)
% where Z is N(0,1)
function AC=AsianCall(S0,K,r,T,sigma,N,reps)
    dt=T/N;
    R=exp(-r*T);
    S = zeros(reps,N);
    S(:,1) = S0;
    drift = (r-0.5*sigma^2)*dt;

    for n=1:reps
        for t=2:N
            dW = randn(1)*sqrt(dt);
            S(n,t) = S(n,t-1)*exp(drift+sigma*dW);
        end
        Average(n) = mean(S(n,:));
    end

    Payoff= max(Average-K,0);
    % The arithmetic mean of all payoffs discounted with the factor R
    AC=R*mean(Payoff);
end
