

function V=PortfolioValue(S,N,B0,h_s,h_b,u,r,Ri)
S0=S(N+1,1);
V=[];
if N>=2
    switch Ri
        case 1 %  higest value of S(N)
            V=h_s(1,N)*S0*exp((N+1-Ri)*u)+h_b(1,N)*B0*exp(r*(N));
        case 2*N+1 % lowest value of S(N)
            V=h_s(2*N-1,N)*S0*exp((N+1-Ri)*u)+h_b(2*N-1,N)*B0*exp(r*(N));
        case 2 % second higest value of S(N)
            V(1)=h_s(1,N)*S0*exp((N+1-Ri)*u)+h_b(1,N)*B0*exp(r*(N));
            V(2)=h_s(2,N)*S0*exp((N+1-Ri)*u)+h_b(2,N)*B0*exp(r*(N));
        case 2*N % second lowest value of S(N)
            V(1)=h_s(2*N-1,N)*S0*exp((N+1-Ri)*u)+h_b(2*N-1,N)*B0*exp(r*(N));
            V(2)=h_s(2*N-2,N)*S0*exp((N+1-Ri)*u)+h_b(2*N-2,N)*B0*exp(r*(N));
        otherwise 
            V(1)=h_s(Ri-2,N)*S0*exp((N+1-Ri)*u)+h_b(Ri-2,N)*B0*exp(r*(N));
            V(2)=h_s(Ri-1,N)*S0*exp((N+1-Ri)*u)+h_b(Ri-1,N)*B0*exp(r*(N));
            V(3)=h_s(Ri,N)*S0*exp((N+1-Ri)*u)+h_b(Ri,N)*B0*exp(r*(N));
end
elseif N==1 
V=h_s(1)*S0*exp((N+1-Ri)*u)+h_b(1)*B0*exp(r*(N));
else
display('The value of N should be greater than 0')
return;
end
end