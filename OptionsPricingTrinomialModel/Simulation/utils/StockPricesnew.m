 %Matlab function for implementing stock price

 function S=StockPricesnew(S0,N,u)

    S=zeros(2*N+1,N+1);

    S(N+1,1)=S0;

    for i=1:N
        S(:,i+1)=S(:,i);
        S(N+1-i,i+1)=S(N+2-i,i)*exp(u);
        S(N+i+1,i+1)=S(N+i,i)*exp(-u);
    end
end

