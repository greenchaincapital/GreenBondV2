# Green Bond V2 ![Foundry](https://github.com/greenchaincapital/GreenBondV2/actions/workflows/test.yml/badge.svg?branch=main)

### Green Bond Contract on Arbitrum ([ERC4626 compatible](https://ethereum.org/en/developers/docs/standards/tokens/erc-4626/))

## GreenBond V2 Summary

GreenBond V2 contract builds upon [GreenBond](https://github.com/greenchaincapital/GreenBond) with the following features:
- Fully ERC4626 compatible
- Aave passive income instead of Curve
    - Simplified interfacing (more robust and secure)
    - Better rate of return (currently ~10% APR for Aave as opposed to ~6% for Curve)
    - Automatic rewards as opposed to claiming processes

Overrall design to provide stable returns for renewable energy project financing, in the form of a stablecoin (USDT) bond. It enforces a minimum lock-up period (3-6 months) for deposited assets, in order to establish new projects' active income. Passive income is earned through Aave lending.

Green energy projects are registered for asset deployment. Master contract agreements are publically linked for transparency and accountability of operations. Income is received from these projects to pay dividends to investors. 

### Interaction Between GreenBond and Projects:

- Reward Accumulation: Users deposit stablecoins or LP tokens into the GreenBond contract to earn rewards over time. These rewards are calculated based on the fixed annual interest rate and the amount of time the assets are locked. Users can claim and compound their rewards.

- Income Receipt: The Projects generate income for the investors.

- Supplier Payment: The GreenBond contract, under governance control, can pay suppliers of the company. Governance initiates the payment by calling the paySuppliers function, specifying the project details.

- Activation and Completion: Each project can be activated by governance, marking the start of the payment process. Once the term of the agreement is over, the company can complete the project by calling the completeProject function.

- Governance Control: The GreenBond contract is under governance control, allowing designated addresses to manage contract parameters, such as the fixed interest rate, lock-up period, and governance address.

By combining the features of the GreenBond and project finance agreements, investors can earn rewards for providing liquidity, while the contract benefits from a flexible payment processing solution that supports income receipt, supplier payments, and contract completion.

## Tests

[ERC4626 and project tests](docs/test-results.md)

## Built with Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test --fork-url https://arb1.arbitrum.io/rpc -vvv
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Deploy.s.sol:DeployScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
