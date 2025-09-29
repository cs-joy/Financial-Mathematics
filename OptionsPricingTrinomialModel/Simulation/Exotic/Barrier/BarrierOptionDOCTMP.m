% BarrierOptionDOCTMP(T,S0,K,r,sigma,p,N,B)
% Computes the trinomial price of barrier option on european down and out
% S0 current stock price
% T is the time to maturity, T=1 is one year
% K is the strike price of the underlying European call
% r>0 is the intrest rate of the bond
% Sigma is the volatility of the underlying stock
% B is the barrier
% p is the probability that the stock goes up or down, 0<p<=1/2 atleast
% N is the number of iterations to compute

function P = BarrierOptionDOCTMP(T, S0, K, r, sigma, p, N, B)
    %N=#Partitions the time interval is divided into
    h = T/N;
    u = sigma * sqrt(h/(2*p));

    %xb= number of steps down to reach barrier
    xb = round(log(S0/B)/u);  % "std error" using round()=0.254286, so round() is better than floor()
                              % "std error" using floor()=0.383078
    %fprintf('xb= %.4f\n', xb);

    %We only need to calculate the stock prices at maturity
    %The stock Nu steps up from the middle S0 is given by
    %exp(log(S0)+Nu*u)
    %The stock Nd steps down from the middle S0 is given by
    %exp(log(S0)-Nd*u)
    SEnd = zeros(2*N+1,1); % initialize stock price at maturity
    for i = 1:N
        SEnd(i) = exp( log(S0) + u*(N-i+1) ); %Starts from the start
        SEnd(end+1-i) = exp( log(S0) - u*(N-i+1) ); %Starts from the bottom
    end
    SEnd(N+1)=S0;

    % payoff for the european call
    g = @(x) max(x-K,0);
 
    %option price matrix
    P = zeros(2*N+1, N+1); % Option prices

    q0 = 1 - 2*p;

    % risk-neutral probabibilities
    qu=(exp(r*h) - exp(-u))/(exp(u) - exp(-u)) - q0*(1-exp(-u))/(exp(u) - exp(-u));
    qd=(exp(u) - exp(r*h))/(exp(u) - exp(-u)) - q0*(exp(u)-1)/(exp(u) - exp(-u));

    % payoff at maturity
    P(1:N+xb,end)=g(SEnd(1:N+xb));

    %Barrier arrives a N+1+xb, if we hit the barrier the values is instantly
    %zero
    % Recurrence formula to calculate option prices
    for j = N:-1:1
        for i = (N+2-j):(N+j)
            if i < (N+1+xb) %If i>=N+1+xb we have reached the barrier -> P=0
                P(i,j) = exp(-r*h) * ( qu * P(i-1,j+1) + q0 * P(i,j+1) + qd * P(i+1,j+1) );
            end
        end
    end

    % Return the option price at time 0 (middle of the tree)
    P = P(N+1, 1);
end