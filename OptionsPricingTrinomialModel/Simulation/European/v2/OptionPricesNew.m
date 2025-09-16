function P=OptionPricesNew(S,g,r,p,h,u)
    M=size(S,1);
    N=size(S,2);
    
    P=zeros(M,N);

    q0=1-2*p;

    syms x;

    f=sym(g);

    qu=(exp(r*h)-exp(-u))/(exp(u)-exp(-u))-q0*(1-exp(-u))/(exp(u)-exp(-u));

    qd=(exp(u)-exp(r*h))/(exp(u)-exp(-u))-q0*(exp(u)-1)/(exp(u)-exp(-u));

    PP = eval(subs(f,x,S(:,N)));

    P(:,N) = (PP>0).*PP;

    for j=N-1:-1:1

        for i=(N-j+1):(M-(N-j))

            P(i,j)=exp(-r*h)*(qu*P(i-1,j+1)+q0*P(i,j+1)+qd*P(i+1,j+1));

        end

    end
end