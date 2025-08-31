

function [h_s,h_b]=LeastSqrHdgPortfolio(S,N,P,B0,r)
h_s=zeros(2*N+1,N);
h_b=zeros(2*N+1,N);
for j=1:N
for i=N+2-j:N+j
A=[S(i-1,j+1) B0*exp(r*j)
S(i,j+1) B0*exp(r*j)
S(i+1,j+1) B0*exp(r*j)];
y=[P(i-1,j+1);P(i,j+1);P(i+1,j+1)];
h=(A.'*A)\(A.'*y);
h_s(i,j)=h(1);
h_b(i,j)=h(2);
end
end

h_s=h_s(2:2*N,:);

h_b=h_b(2:2*N,:);
end