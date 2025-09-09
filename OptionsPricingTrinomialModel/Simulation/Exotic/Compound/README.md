# Compound Options
Compound options are options for which the underlying asset is also an option. This means that a compound option has two separet strike prices(`K`) and maturity times(`T`); for the,
- compound option itself and
- underlying option

Here we will refer to the 
- **compound option** as the first option, with 
    - strike price `K_1` and maturity `T_1`

- **underlysing option** as the second option, with
    - striker price `K_2` and maturity `T_2`

- **underlying stock** with
    - price `S(t)` at time `t`, `T_1<=t<=T_2`


## Mathematical Representation
Representing the final price (i.e. the payoff) for a compound option is fairly straightforward. Clearly it will depend on the types of **first** and **second option**.
We might divide compound options ino four types:
1. A call on a call option (`CoC`), 
    - with payoff `max{0, C_und(S(T_1),K_2,T_2-T_1) - K_1}`
2. A call on a put option (`CoP`), 
    - with payoff `max{0, P_und(S(T_1),K_2,T_2-T_1) - K_1}`
3. A put on a call option (`PoC`), 
    - with payoff `max{0, K_1 - C_und(S(T_1),K_2,T_2-T_1)}`
4. A put on a put option (`PoP`), 
    - with payoff `max{0, K_1 - P_und(S(T_1),K_2,T_2-T1)}`

Here the underlying call and put options have the values `C_und` and `P_und`, respectively.

## Pricing methods
As compound options (under certain assumptions) has a 
closed-form pricing formula the question of what the 
definitive price should be becomes very clear. Here we will
look specifically at approximation of the theoretical 
value usng the trinomial model. However, we will first take a
brief look at the closed-form pricing formula.

- Theoretical valuation - [EUCompound_BS.m](https://github.com/cs-joy/Financial-Mathematics/blob/main/OptionsPricingTrinomialModel/Simulation/Exotic/Compound/EUCompound_BS.m)
- Trinomial approximation - [EUCompound_Tri.m](https://github.com/cs-joy/Financial-Mathematics/blob/main/OptionsPricingTrinomialModel/Simulation/Exotic/Compound/EUCompound_Tri.m)

## Numerical results
<img src="https://raw.githubusercontent.com/cs-joy/Financial-Mathematics/main/OptionsPricingTrinomialModel/Simulation/Exotic/Compound/output/FIG5_2.svg" alt="Trinomial model and Theoretical approximation of the CoC European option price"  style="width:auto; height:auto">

## Conclusion
![Compiled price and Computational time](https://raw.githubusercontent.com/cs-joy/Financial-Mathematics/main/OptionsPricingTrinomialModel/Simulation/Exotic/Compound/output/coc_pricing_comparison.svg){: width="200" height="100"}
It is clear that the trinomial model may be used to correctly
approximate the theoretical value of a compound option, for instance
the CoC option as we have shown `output/coc_pricing_results.csv`. However this seems to be suboptimal way of valuating
the option, compared to simply using the theoretical valuation. From this analysis the time to evaluate the CoC option price using the trinomial
approach was significantly longer than `Geske's` closed form valuation model.
