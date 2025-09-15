% RecursionCliquetTrinomial calculates the non-discounted trinomial
% price of a cliquet option. This function is recursive and it is called
% by the function CliquetPriceTrinomial.
% Local returns and final payoffs are being calculated as well as their
% associated probabilities.
function [Q]=RecursionCliquetTrinomial(Z,P,i,Q,constants)
    % Define constants
    u=constants(1); qu=constants(2); qd=constants(3); q0=constants(4);
    Floc=constants(5); Cloc=constants(6);
    Fglob=constants(7); Cglob=constants(8);
    m=constants(9); N=constants(10);
    alpha=constants(11); beta=constants(12); j=constants(13);
    P_j=constants(14); P_0=constants(15);

    % Treat all the cases where alpha is reached
    P(i)=P_j;
    Z(i)=Cloc;

    if i==m % If the current reset date is the last one (i.e. maturity)
        P_final=prod(P);
        Z_final=sum(Z);
        Q=Q+P_final*max(Fglob,min(Cglob,Z_final));
    elseif sum(Z)<=(Fglob-(N-i)*Cloc) % No possibility to go higher than Fglob
        P_final=prod(P(1:i));
        Q=Q+P_final*Fglob;
    else
        Q=RecursionCliquetTrinomial(Z,P,i+1,Q,constants);
    end

    % Treat all the cases where beta is reached
    P(i)=P_0;
    Z(i)=Floc;
    if i==m % If the current observation is the last one (i.e. maturity)
        P_final=prod(P);
        Z_final=sum(Z);
        Q=Q+P_final*max(Fglob,min(Cglob,Z_final));
    elseif sum(Z)<=(Fglob-(N-i)*Cloc) % No possibility to go higher than Fglob
        P_final=prod(P(1:i));
        Q=Q+P_final*Fglob;
    else
        Q=RecursionCliquetTrinomial(Z,P,i+1,Q,constants);
    end

    % Treat rest of the cases
    for diff=beta+1:(beta+j-1)
        P_temp=0;
        for Nu=max(0,diff):min(N,N/2+floor(diff/2))
            Nd=Nu-diff;
            P_temp=P_temp+nchoosek(N,Nu)*nchoosek(N-Nu,Nd)*qu^Nu*qd^Nd*q0^(N-Nu-Nd);
        end
        P(i)=P_temp;
        R=exp(Nu*u-Nd*u)-1;
        Z(i)=max(Floc,min(R,Cloc));

        if i==m % If the current observation is the last one (i.e. maturity)
            P_final=prod(P);
            Z_final=sum(Z);
            Q=Q+P_final*max(Fglob,min(Cglob,Z_final));
        elseif sum(Z)<=(Fglob-(N-i)*Cloc) % No possibility to go higher than Fglob
            P_final=prod(P(1:i));
            Q=Q+P_final*Fglob;
        else
            Q=RecursionCliquetTrinomial(Z,P,i+1,Q,constants);
        end
    end
end