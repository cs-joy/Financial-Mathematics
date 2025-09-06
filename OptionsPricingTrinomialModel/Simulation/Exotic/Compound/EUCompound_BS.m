% EUCompound_BS returns the current price (at time t=0) of the European CoC option
%
% Computing each input parameter in turn
% Critical value of S calculated by using CP=undPayoff as seen below
function P=EUCompound_BS(S0, r, sigma, T1, T2, K1, K2)
    % Checking input arguments
    if (r<0) || (T1<0) || (T2<0) || (K1<0) || (K2<0)
        disp('Error: invalid input parameters');
        P=0;

        return
    end

    % Calculating critical value of S
    maxiter=5000;
    
    tol=1e-6;
    Sstar=fzero(@undPayoff,[0.000000001 100*S0],optimset('MaxIter', maxiter,'TolFun', tol),K1,K2,r,T2-T1,sigma);
    
    D2star=(log(S0/Sstar)+(r+0.5*sigma^2)*T1)/(sigma*sqrt(T1));
    D1star=D2star-sigma*sqrt(T1);
    
    D2=(log(S0/K2)+(r+0.5*sigma^2)*T2)/(sigma*sqrt(T2));
    D1=D2-sigma*sqrt(T2);
    
    rho=sqrt(T1/T2);

    % Calculating price as calculated by Geske
    P=S0*mvncdf([D2star D2],[0 0],[1 rho; rho 1])-K2*exp(-r*T2)*mvncdf([D1star D1], [0 0],[1 rho; rho 1])-K1*exp(-r*T1)*normcdf(D1star);
end

function CP=undPayoff(Sint,K1,K2,r,T,sigma)
    [callprice,putprice]=blsprice(Sint,K2,r,T,sigma,0);
    
    % Select appropriate function
    CP=callprice-K1;
end