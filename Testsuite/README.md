# Trinomial model


- trinomial model stock price converges to the geometric brownian motion:
    - trinomial stock price -> `S(0)e^{u*M_{N}}`
    - geometric brownian motion -> `S(0)e^{sigma*W(t)}`

    since `u = sigma*sqrt(h/2*p)` we have
    `S(0)*e^{{sigma*sqrt(h/2*p)}*M_{N}}` `~` `S(0)e^{sigma*W(t)}`
