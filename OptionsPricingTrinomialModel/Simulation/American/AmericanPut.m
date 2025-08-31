% AmericanPut computes the price of an American put option
% by using the trinomial model. S is the trinomial tree
% prices of the underlying stock computed with the function
% StockPrices, r>=0 is the risk-free interest rate, K is the
% strike price, N is the number of steps, p is the probability
% that the stock price goes up, h is the length of each time step,
% and u is price change when the stock price goes up.
function A=AmericanPut(S,K,r,N,p,h,u)
    A=zeros(2*N+1,N+1);
    A(:,N+1)=max(K-S(:,N+1),0);

    q0=1-2*p;
    qu=(exp(r*h)-exp(-u))/(exp(u)-exp(-u))-q0*(1-exp(-u))/(exp(u)-exp(-u));
    qd=(exp(u)-exp(r*h))/(exp(u)-exp(-u))-q0*(exp(u)-1)/(exp(u)-exp(-u));
    
    for j=N:-1:1
        for i=N+1-(j-1):N+1+(j-1)
            A(i,j)=max(max(K-S(i,j),0),exp(-r*h)*(qu*A(i-1,j+1)+q0*A(i,j+1)+qd*A(i+1,j+1)));
        end
    end
end