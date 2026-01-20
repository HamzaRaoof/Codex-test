# Land Tokenization MVP (Solidity)

This repository contains the smart contract MVP for a platform where land owners
register plots, issue fractional ERC-20 shares per plot, and distribute variable
profits to token holders using USDC payouts.

## Contracts

- `LandOwnerRegistry`: registers land owners and metadata (crop, cycle, payout wallet).
- `LandOfferingFactory`: deploys a new ERC-20 share token, offering contract, and
  profit distributor for each land plot.
- `LandOffering`: sells shares for USDC, transferring proceeds directly to the
  land owner's payout wallet.
- `ProfitDistributor`: lets land owners fund payouts and token holders claim
  variable profits.

## Notes on Profit Distribution

The `ProfitDistributor` uses a cumulative reward-per-share model based on the
current token balance at the time of claiming. For a production deployment,
consider snapshot-based accounting or transfer hooks to prevent transferring
unclaimed rewards with the tokens.

## Getting Started

```bash
npm install
npm run build
```

## Local Demo (Hardhat)

Start a local node:

```bash
npx hardhat node
```

Deploy the contracts and a mock USDC:

```bash
npm run deploy:local
```

Run the example flow (register owner, create offering, buy shares, fund payout, claim):

```bash
npm run example:flow
```

## Sepolia Deployment

Set the following environment variables:

```bash
export SEPOLIA_RPC_URL="https://sepolia.infura.io/v3/<key>"
export PRIVATE_KEY="<deployer-private-key>"
export USDC_ADDRESS="<sepolia-usdc-address>"
```

Then run:

```bash
npm run deploy:sepolia
```

## Next Steps (Suggested)

- Add a front-end (Next.js + wagmi) to handle wallet connect, owner registration,
  offerings, and claims.
- Expand automated tests to cover edge cases and security checks.
