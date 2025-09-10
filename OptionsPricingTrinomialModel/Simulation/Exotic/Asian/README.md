# Asian Options

Asian options were invented in the late 1980's, initially for
trading crude oil with purposes of 
- reducing the risk of market manipulation at the maturity day
- to decrease the effect of volatility

An asian option is a path-dependent exotic option. Hence, pricine an [Asian Option](https://en.wikipedia.org/wiki/Asian_option) is 
more difficult than pricing a standard European or American
option. The payoff of an Asian option depends on the 
average price of the underlying asset during a certain time period,
hence it is also sometimes known as an **average option**.

## Numerical results
I use `S_0=10`, `K=8`, `r=0.01`, `T=0.062`, `σ=0.2` and `p=0.25`


### Trinomial model
**Table:** The computation time for different number of steps in the trinomial model
| N | Computational Time (s) | Initial Price |
|:---:|:---:|:---:|
| **10** | 0.1113 s	| 2.0022 |
| **11** | 0.1539 s	| 2.0021 |
| **12** | 0.4347 s	| 2.0021 |
| **13** | 1.2928 s	| 2.0021 |
| **14** | 3.7576 s	| 2.0021 |

<img src="https://raw.githubusercontent.com/cs-joy/Financial-Mathematics/main/OptionsPricingTrinomialModel/Simulation/Exotic/Asian/TrinomialModel/output/Fig of Computation time (Table5_1).svg" alt="Computational time for different number of steps in the Trinomial model"  style="width:100%; height:auto">

As we can see, the trinomial model has an issue; when the number of time steps
increases the number of possible paths increases rapidly,
making the computational time very demanding. 


### Monte Carlo Simulation
One major issue with Monte Carlo simulations is that they do not provide an exact
result, instead we need to simulate several times and then take
the expected value of all simulations. Here we focus on the number of replicates
instead of the number of steps.

`simulation is in progress....`