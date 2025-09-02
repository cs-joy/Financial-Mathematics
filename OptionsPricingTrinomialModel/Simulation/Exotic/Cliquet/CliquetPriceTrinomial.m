% CliquetPriceTrinomial calculates the trinomial cliquet option price.
% This function calls "RecursionCliquetTrinomial", which is recursive.
% m is the number of reset periods and N is the number of
% steps in each period.
% qu, qd, q0 and u are specified so that the price converges.
% Floc, Cloc, Fglob and Cglob are local and global caps and floors.
% Alpha and Beta are restraints on the number of ups and downs
% in each reset period.
% P_j and P_0 are probabilities associated with Alpha and Beta.
function [price]=CliquetPriceTrinomial(Floc,Cloc,Fglob,Cglob,T,m,N,sigma,r,p)
q0=1-2*p;
h=T/(N*m);
u=sigma*sqrt(h/(2*p));
% Calculate qu and qd (risk neutral meassure)
qu=(exp(r*h)-exp(-u))/(exp(u)-exp(-u))-q0*(1-exp(-u))/(exp(u)-exp(-u));
qd=(exp(u)-exp(r*h))/(exp(u)-exp(-u))-q0*(exp(u)-1)/(exp(u)-exp(-u));
% Alpha and P_j as defined in text
alpha=ceil(log(Cloc+1)/u);
P_j=0;
for Nu=alpha:N
for Nd=0:min(Nu-alpha,N-Nu)
P_j=P_j+nchoosek(N,Nu)*nchoosek(N-Nu,Nd)*qu^(Nu)*qd^(Nd)*q0^(N-Nu-Nd);
end
end
% Beta and P_0 as defined in text
beta=floor(log(Floc+1)/u);
P_0=0;
for Nd=max(0,-beta):N
for Nu=0:min(N-Nd,Nd+beta)
P_0=P_0+nchoosek(N,Nd)*nchoosek(N-Nd,Nu)*qu^(Nu)*qd^(Nd)*q0^(N-Nu-Nd);
end
end
j=alpha-beta;
P=zeros(1,m);
Z=zeros(1,m);
Q=0;
% Put all the constants in a vector
constants=[u qu qd q0 Floc Cloc Fglob Cglob m N alpha beta j P_j P_0];
% Start the recursive algorithm
[price]=RecursionCliquetTrinomial(Z,P,1,Q,constants);
price=price*exp(-r*T);
end