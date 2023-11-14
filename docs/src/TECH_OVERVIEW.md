# Green Bond V2 Technical Overview

### Green Bond Contract on Arbitrum ([ERC4626 compatible](https://ethereum.org/en/developers/docs/standards/tokens/erc-4626/))

### Deployed at [0xD24644Ca8cB5D67E776291b37896Bc3D557A47B8](https://arbiscan.io/address/0xd24644ca8cb5d67e776291b37896bc3d557a47b8)

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

- Reward Accumulation: Users deposit stablecoins (USDT) into the GreenBond contract to earn rewards over time. These rewards are automatically accumulated, based on both passive income from Aave lending and active income from active projects.

- Income Receipt: The Projects generate income for the investors either in a fixed payment agreement or through re-sale of the project.

- Supplier Payment: The GreenBond contract, under governance control, can pay the registered project admin. Governance initiates the payment by calling the payProject function, specifying the project details.

- Activation and Completion: Each project can be activated by governance, marking the start of the payment process. Once the term of the agreement is over, the company can complete the project by calling the completeProject function.

- Governance Control: The GreenBond contract is under governance control, allowing designated addresses to manage contract parameters, such as the fixed interest rate, lock-up period, and governance address.

By combining the features of the GreenBond and project finance agreements, investors can earn rewards for providing liquidity, while the contract benefits from a flexible payment processing solution that supports income receipt, project payments, and project completion.

## Project Finance Operations

- [Project Finance](PROJECT_FINANCE.md)
- [XStructure](XSTRUCTURE.md)
