% BermOptionPrices computes Bermudan prices using the Trinomial model.
% There are two possible returns to the function, depending on whether we
% wish to compare the Bermudan price with American/European derivatives or
% if we wish to compare the Trinomial Bermudan price with the Binomial
% Bermudan price.
% The function begins with creating several matrices, one for the payoff
% tree and one each for the European-, American-, and Bermudan derivative.
% All price trees take their bases in the payoff tree, then recursively
% their respective prices based on the properties of the derivatives.
function P=BermOptionPrices(S,u,r,h,p,ex_dates,K,put_True)
    q0 = 1-2*p;
    
    % Check input arguments
    if (r<0) || (q0<0) || (q0>(exp(u)-exp(r))/(exp(u)-1))
        disp('Error: invalid input parameters');
        P=0;
        return
    end

    M=size(S,1);
    N=size(S,2);

    % Price trees for different derivatives
    PTree=zeros(M,N); % Pay-off tree used for american tree later
    PEuro=zeros(M,N); % European tree used later
    PAmer=zeros(M,N); % American tree used later
    PBerm=zeros(M,N); % Bermudan tree used later
    exercise_True = zeros(1,N);
    AmStep = N / ex_dates;

    % Identifying steps at which we treat the Berm option as American
    for i=AmStep:AmStep:N
        exercise_True(i) = 1;
    end

    qu=(exp(r*h)-exp(-u))/(exp(u)-exp(-u))-q0*(1-exp(-u))/(exp(u)-exp(-u));
    qd=(exp(u)-exp(r*h))/(exp(u)-exp(-u))-q0*(exp(u)-1)/(exp(u)-exp(-u));

    % Calculate entire pay-off tree with respect to S
    if put_True == 1
        for j=N:-1:1
            for i=(N-j+1):(M-(N-j))
                PTree(i,j) = max(0,K-S(i,j));
            end
        end
    else
        for j=N:-1:1
            for i=(N-j+1):(M-(N-j))
                PTree(i,j) = max(0,S(i,j)-K);
            end
        end
    end

    % Recurrence formula to calculate the European option prices
    PEuro(:,N) = PTree(:,N);
    for j=N-1:-1:1
        for i=(N-j+1):(M-(N-j))
            PEuro(i,j)=exp(-r)*(qu*PEuro(i-1,j+1)+q0*PEuro(i,j+1)+qd*PEuro(i+1,j+1));
        end
    end

    % Recurrence formula to calculate the American option prices
    PAmer(:,N) = PTree(:,N);
    for j=N-1:-1:1
        for i=(N-j+1):(M-(N-j))
            PAmer(i,j) = max(PTree(i,j),exp(-r)*(PAmer(i-1,j+1)*qu+q0*PAmer(i,j+1) + qd*PAmer(i+1,j+1)));
        end
    end

    % Recurrence formula to calculate the Bermudan option prices
    PBerm(:,N) = PTree(:,N);
    for j=N-1:-1:1
        for i=(N-j+1):(M-(N-j))
            if exercise_True(j) == 1
                PBerm(i,j) = max(PTree(i,j),exp(-r)*(PBerm(i-1, j+1)*qu+q0*PBerm(i,j+1)+qd*PBerm(i+1,j+1)));
            else
                PBerm(i,j) = exp(-r)*(PBerm(i-1, j+1)*qu+q0*PBerm(i,j+1)+qd*PBerm(i+1,j+1));
            end
        end

        % Initial prices
        P = [PEuro(N,1) PBerm(N,1) PAmer(N,1)];
        % Use this for executing the comparison between derivatives
        P = PBerm(N,1)
        % Use this for executing the comparison with the binomial model
    end
end