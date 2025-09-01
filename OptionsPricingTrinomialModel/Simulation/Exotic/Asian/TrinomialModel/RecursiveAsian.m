% RecursiveAsian calculates the trinomial price for
% Asian call option. The function is recursive and calculates
% the undiscounted price for a Asian call option.
%
% Q is a vector containing the risk-neutral probabilities qu,q0,and qd
% M is a vector containing u,0,-u
% V calculate the payoff for each potential path in the trinomial tree
%
% qu=(exp(r*h)-exp(-u))/(exp(u)-exp(-u))-q0*(1-exp(-u))/(exp(u)-exp(-u));
% qd=(exp(u)-exp(r*h))/(exp(u)-exp(-u))-q0*(exp(u)-1)/(exp(u)-exp(-u));
function [V P_tot]=RecursiveAsian(V,N,K,n,P_tot,P,Q,M,allS)
    allS_prev=allS;
    S_prev=allS(end);
    P_prev=P;
    
    for i=1:3
        allS=[allS_prev S_prev*exp(M(i))];
        P=P_prev*Q(i);
        if n==N
            P_tot=P_tot+P;
            % Calculates the payoff for each path
            V=V+P*max(mean(allS(2:length(allS)))- K,0);
        else % Increases n until n=N
        [V P_tot]=RecursiveAsian(V,N,K,n+1,P_tot,P,Q,M,allS);
    end
end