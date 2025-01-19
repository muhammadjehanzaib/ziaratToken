# Ziarat Token Contract Documentation
### Overview

The Ziarat Token (ZIAR) is an ERC20-based token with added governance and vesting functionalities. This documentation provides an overview of the contract’s features and explains how developers can test the contract using Foundry or other testing frameworks.

### Features
#### 1. Token Details
* Symbol: ZIAR

* Decimals: 18 (default for ERC20)

* Max Supply: 1,000,000,000 tokens

#### 2. Governance 
The token includes a governance system that allows users to:

* Create proposals.

* Vote on proposals using their voting power.

* Execute proposals that pass voting thresholds.

#### 3. Vesting 
The contract integrates a vesting mechanism to release tokens over time, relying on a separate vesting contract.

#### 4. Minting and Burning
* The owner can mint new tokens (capped by the max supply).

* The owner can burn tokens from their balance.

 ### Installation and Setup

#### Prerequisites
* Foundry (for testing and deployment)

* OpenZeppelin Contracts Library

## Installation Steps
1. Clone the repository:
```bash
git clone https://www.github.com/muhammadjehanzaib/ziaratToken
cd ziaratToken
```
2. install dependencies
```bash
forge install OpenZeppelin/openzeppelin-contracts
```
3. Compile the contracts:
```bash
forge build
```
