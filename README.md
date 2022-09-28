# ZK-Sudo

ZK-Sudo is the implementation of an AMM for NFTs developed in Cairo. 

Instead of trading NFTs on marketplaces with centralized order books, users can buy NFTs from and sell NFTs into on-chain liquidity pools. The asset prices are calculated and adjusted automatically based on the underlying on-chain bonding curve, providing higher NFT liquidity. 

## Overview

Liqudity providers can create an individual pool calling the `mint` function from the `MintPool` contract, which is a modified ERC-721 contract, providing the required pool specifications (as `pool_type_class_hash`, `bonding_curve_class_hash` and `erc20_contract_address`). Currently the available pool types are `BuyPool` and `SellPool` contracts (`TradePool` combining both functionalities coming soon). 

This way an individual pool with the `mint` function caller as owner is deployed and can be configurated by `setPoolParams` indicating the `current_price` for that pool and `delta` to adjust the price. After providing liquidity in the form of tokens via `addNftToPool`, users can trade automatically with the pool calling `buyNfts` or `sellNfts`. LP as pool owner can adjust the pool paramaters and add or remove assets from the pool anytime. 

When minting and deploying a specific pool, the LP must indicate a specific bonding curve (price function), as `LinearCurve` or `ExponentialCurve`, to dynamically calculate and adjust the asset prices depending on the number of bought or sold tokens in the pool. 
