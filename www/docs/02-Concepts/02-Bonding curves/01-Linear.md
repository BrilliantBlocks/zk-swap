With a linear bonding curve the price of an asset increases or decreases by a constant amount $\delta$ every time the asset supply changes (NFTs are bought from or sold into the pool).
Iff $\delta = 0$, the linear curve becomes a constant one providing stable asset prices.

Let $N_{tokens}$ denote the amount of NFTs inside the pool. The price for the next asset to buy or sell is calculated with the following formula:
$$
\text{NextPrice} = \text{CurrentPrice} \pm \delta * N_{tokens}
$$
