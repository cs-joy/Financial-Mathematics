 %Appendix B:Matlab function for European Call prices as a function of q0

u = 0.3; %price change when the stock price goesup,
S0 = 10; %initial stock price
k = 15;  %Strike price
r = 0.02;%Interest Rate
q0 = 0.0001:0.04:0.9402;  %q0 is free parameter which is from 0.0001 to 0.9402

for N = [50 100 150 200]  %N is the number of steps
	P11 = zeros(1,length(q0));%zeros is defining a matrix
	for n = 1:length(q0)      %loop from column 1 to through 24  
		syms x;                   %symbolic variable define
		g=x-k;                    %payoff
		S=StockPricesnew(S0,N,u); %Trinomial tree price of the stock 
		P=OptionPricesnew(S,N,g,u,r,q0(n));%option price
		P11(n) = P(N+1,1);%the initial can be found in the position (N+1,1)
	end
	
	plot(q0,P11); hold on
	xlabel('Free parameter q0')
	ylabel('Initial European Call Option')
end

axis([0 1 0 12])
legend('N = 50','N = 100','N = 150','N = 200');
title(['k = ' num2str(k)]);
grid on