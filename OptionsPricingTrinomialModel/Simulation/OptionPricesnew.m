%Matlab function for European option prices in the trinomial model
function P=OptionPricesnew(S,N,g,u,r,q0)

	P=zeros(2*N+1,N+1);
	syms x;
	f=sym(g);

	qu=(exp(r)-exp(-u))/(exp(u)-exp(-u))-q0*(1-exp(-u))/(exp(u)-exp(-u));
	qd=(exp(u)-exp(r))/(exp(u)-exp(-u))-q0*(exp(u)-1)/(exp(u)-exp(-u));

	PP = eval(subs(f,x,S(:,N+1)));
	P(:,N+1) = (PP>0).*PP;
	
	j=N;
	while 1
		if j>0
			for i=(N-j+2):(N+j)
				P(i,j)=exp(-r)*(qu*P(i-1,j+1)+q0*P(i,j+1)+qd*P(i+1,j+1));
			end
		else
    		break
		end
		j=j-1;

	end
end