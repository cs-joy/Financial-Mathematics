% BinomBerm computes Bermudan prices using the binomial model. We begin by
% creating a payoff tree that forms a basis for the price tree. The
% function creates different payoff trees depending on whether we have a
% put or a call option. Then we use the payoff at maturity to recursively
% compute the prices backwards.
function P=BinomBerm(S,u,r,h,ex_dates,K,put_True)
    M=size(S,1);
    N=size(S,2);
    
    exercise_True = zeros(1,N);
    
    PTree=zeros(M,N); % Pay-off tree used for american tree later
    PBerm=zeros(M,N); % Bermudan tree used later
    
    qu=(exp(r*h)-exp(-u))/(exp(u)-exp(-u));
    qd=(exp(u)-exp(r*h))/(exp(u)-exp(-u));
    
    AmStep = N / ex_dates;

    % Identifying steps at which we treat the Berm option as American
    for i=AmStep:AmStep:N
        exercise_True(i) = 1;
    end
    % Here a payoff tree is created, Binomial style
    if put_True == 1
        for j=N:-1:1
            for i=1:(M-(N-j))
                PTree(i,j) = max(0,K-S(i,j));
            end
        end
    else
        for j=N:-1:1
            for i=1:(M-(N-j))
                PTree(i,j) = max(0,S(i,j)-K);
            end
        end
    end
    PBerm(:,N) = PTree(:,N);
    % Here we calculate the Bermudan prices by using the exercise_true variable,
    % Identifying where the derivative becomes American and European
    for j=N-1:-1:1
        for i=1:(M-(N-j))
            if exercise_True(j) == 1
                PBerm(i,j) = max(PTree(i,j),exp(-r)*(PBerm(i+1,j+1)*qu+qd*PBerm(i+1,j+1)));
            else
                PBerm(i,j) = exp(-r)*(PBerm(i,j+1)*qu+qd*PBerm(i+1,j+1));
            end
        end
    end
    P = PBerm(1,1);
end