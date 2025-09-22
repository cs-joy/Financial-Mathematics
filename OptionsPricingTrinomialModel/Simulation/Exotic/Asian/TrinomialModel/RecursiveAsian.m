% RecursiveAsian calculates the trinomial price for
% Asian call option. The function is recursive and calculates
% the `undiscounted` price for a Asian `call option`.
%
% Q -> is a vector containing the risk-neutral probabilities qu,q0,and qd
% M ->  A vector containing the log-returns for each move: [u, 0, -u], where u is the size of an up/down move.
% V -> calculate the payoff for each potential path in the trinomial tree
% P_tot -> The running total of probabilities (starts at 0).
% N -> total number of time steps to maturity
% n -> The current time step in the recursion (starts at 1).
% P -> The probability of the specific path taken to reach the current node.
% allS -> A vector that stores the history of stock prices along the current
%           path, starting with the initial price S0
%
% qu=(exp(r*h)-exp(-u))/(exp(u)-exp(-u))-q0*(1-exp(-u))/(exp(u)-exp(-u));
% qd=(exp(u)-exp(r*h))/(exp(u)-exp(-u))-q0*(exp(u)-1)/(exp(u)-exp(-u));
function [V P_tot]=RecursiveAsian(V,N,K,n,P_tot,P,Q,M,allS)
    %% necessary for backtracking in the recursion. 
    allS_prev=allS; % save the current state of the path `allS`
    S_prev=allS(end); % the last stock price in that path `S_prev`
    P_prev=P; % saves the path probability before the new moves.
    
    % loop runs 3 times, corresponding to the three possible moves in the
    % trinomial model: up (i=1), no movement (i=2), and down (i=3).
    for i=1:3 
        %  creates a new path by appending the next stock price to the
        %  history vector `allS`
        allS=[allS_prev S_prev*exp(M(i))];  % S_prev * exp(M(i)) -> calculate new price, since M hold three-different moves, S_prev*e^{u}; S_prev; S_prev*e^{-u}
        P=P_prev*Q(i); % updates the path probability by multiplying the previous probability (P_prev) by the probability of the current move (Q(i)). This uses the risk-neutral probabilities derived in the trinomial model to ensure the price is arbitrage-free.
        if n==N % Check if at Final Time Step (Maturity)
            P_tot=P_tot+P; % adds the probability of this complete path to the running total
            % Calculates the payoff for each path

            % Calculates the `arithmetic average price` of the underlying asset along this specific path. 
            % It starts from index 2 because allS(1) is the initial price S0 at time n=0.
            A_n = mean(allS(2:length(allS)));

            % payoff calculation for an Asian call option
            % max(A_n- K,0) -> intrinsic value of the call option at maturity for this path (payoff)
            % P * ...: weights the payoff by the probability of this path occurring.
            % V = V + ...: Adds this probability-weighted payoff to the running total option value V. 
            % At the end of the recursion, V will be the sum of the discounted expected payoff, 
            % but note: this function calculates the `undiscounted expected` payoff.
            V=V+P*max(K - A_n,0);
            % To get the present value (fair price), it must be discounted by the risk-free rate
            % Price = exp(-r * T) * V
        else %     If it's not the final time step (n < N), the function calls itself 
            % recursively for the next time step (n+1), passing along the updated running totals (V, P_tot),
            %  the new path probability (P), and the extended price path (allS). This continues until every 
            % possible path to maturity has been explored.
            [V P_tot]=RecursiveAsian(V,N,K,n+1,P_tot,P,Q,M,allS);
        end
    end
end

%% Conclusion:
% *) Tree Construction: The code builds a trinomial tree recursively. At each node, the stock can move to one of three new nodes (up, same, down).
% 
% *) Path Dependency: Because it's an Asian option, the code must track the entire history of prices (allS) for each path, not just the final price.
% 
% *) Probability Weighting: Each possible path is assigned a probability (P) calculated by multiplying the risk-neutral probabilities (Q) for each step along the path.
% 
% *) Payoff Calculation: At maturity (n = N), the arithmetic average of the stock prices along the path is computed. The option's payoff for that path is max(average - strike, 0).
% 
% *) Expected Value: The final option value V is the sum of the payoffs for all possible paths, each weighted by their respective risk-neutral probability. Crucially, this value V is the expected payoff at maturity. To get the present value (fair price), it must be discounted by the risk-free rate: Price = exp(-r * T) * V.
% 
% *) Key Limitation: This is a highly inefficient method. The number of paths in a trinomial tree grows as 3^N, 
% which becomes computationally intractable for even moderately large N (e.g., N > 20). This is known as the "curse of 
% dimensionality," which is especially severe for path-dependent options like Asians. In practice, more sophisticated " + ...
%     "methods like Monte Carlo simulation or techniques using state variables (like the running average) are used. This " + ...
%     "    code serves as a clear but computationally expensive illustration of the fundamental pricing principle.