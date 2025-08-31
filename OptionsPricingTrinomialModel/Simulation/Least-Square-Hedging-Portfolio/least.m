%Appendix C: Matlab function for least square hedging portfolio of a
%standard European Derivative
u=0.3;
N=15;
S0=12;
B0=12;
r = 0.01;
q0 = 0.2;
k =8 ;
syms x;
g=x-k;
S=StockPricesnew(S0,N,u);
P=OptionPricesnew(S,N,g,u,r,q0);
[h_s,h_b]=LeastSqrHdgPortfolio(S,N,P,B0,r);
for Ri = 1:1:size(S,1)
VV=PortfolioValue(S,N,B0,h_s,h_b,u,r,Ri);
V1(Ri)=max(VV);
V2(Ri)=min(VV);

end

plot(fliplr(S(:,end))',fliplr(V1-P(:,end)'),'r');hold on;%pause
plot(fliplr(S(:,end))',fliplr(V2-P(:,end)'),'o-');hold off

axis([0 75 -0.5 0.5])
total=length(V1)+length(V2)
V1'
V2'
%plot(S,V); hold on  
