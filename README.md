## `TalentCommunitySale`

### Introduction

We took the source code of a public contract. This is the original contract
here:

[Original `TalentCommunitySale` Contract](https://github.com/talentprotocol/contracts/blob/master/contracts/talent/TalentCommunitySale.sol)

We cloned it here:

[Cloned `TalentCommunitySale` Contract](https://github.com/pmatsinopoulos/TalentCommunitySale)

### Foundry Tests

First we implemented a full test coverage using Foundry Tests:

| File                        | % Lines         | % Statements    | % Branches     | % Funcs       |
|-----------------------------|-----------------|-----------------|----------------|---------------|
| src/TalentCommunitySale.sol | 100.00% (43/43) | 100.00% (43/43) | 90.00% (36/40) | 100.00% (7/7) |

**Important:** We had to write tests to cover for `Ownable` and for `ReentrancyGuard`. This is necessary
because inheriting from these contracts is an implementation detail. We want to test cover their functionality
in case we want to replace these abstract contracts with our own implementation.

### Storage Layout Optimization

#### Before Any Optimization

forge inspect --pretty src/TalentCommunitySale.sol:TalentCommunitySale storageLayout
| Name            | Type                     | Slot | Offset | Bytes | Contract                                        |
|-----------------|--------------------------|------|--------|-------|-------------------------------------------------|
| _owner          | address                  | 0    | 0      | 20    | src/TalentCommunitySale.sol:TalentCommunitySale |
| _status         | uint256                  | 1    | 0      | 32    | src/TalentCommunitySale.sol:TalentCommunitySale |
| paymentToken    | contract IERC20          | 2    | 0      | 20    | src/TalentCommunitySale.sol:TalentCommunitySale |
| tokenDecimals   | uint256                  | 3    | 0      | 32    | src/TalentCommunitySale.sol:TalentCommunitySale |
| receivingWallet | address                  | 4    | 0      | 20    | src/TalentCommunitySale.sol:TalentCommunitySale |
| tier1Bought     | uint32                   | 4    | 20     | 4     | src/TalentCommunitySale.sol:TalentCommunitySale |
| tier2Bought     | uint32                   | 4    | 24     | 4     | src/TalentCommunitySale.sol:TalentCommunitySale |
| tier3Bought     | uint32                   | 4    | 28     | 4     | src/TalentCommunitySale.sol:TalentCommunitySale |
| tier4Bought     | uint32                   | 5    | 0      | 4     | src/TalentCommunitySale.sol:TalentCommunitySale |
| totalRaised     | uint256                  | 6    | 0      | 32    | src/TalentCommunitySale.sol:TalentCommunitySale |
| saleActive      | bool                     | 7    | 0      | 1     | src/TalentCommunitySale.sol:TalentCommunitySale |
| listOfBuyers    | mapping(address => bool) | 8    | 0      | 32    | src/TalentCommunitySale.sol:TalentCommunitySale |

#### After Optimization

| Name            | Type                     | Slot | Offset | Bytes | Contract                                        |
|-----------------|--------------------------|------|--------|-------|-------------------------------------------------|
| tokenDecimals   | uint256                  | 0    | 0      | 32    | src/TalentCommunitySale.sol:TalentCommunitySale |
| totalRaised     | uint256                  | 1    | 0      | 32    | src/TalentCommunitySale.sol:TalentCommunitySale |
| listOfBuyers    | mapping(address => bool) | 2    | 0      | 32    | src/TalentCommunitySale.sol:TalentCommunitySale |
| owner           | address                  | 3    | 0      | 20    | src/TalentCommunitySale.sol:TalentCommunitySale |
| paymentToken    | contract IERC20          | 4    | 0      | 20    | src/TalentCommunitySale.sol:TalentCommunitySale |
| receivingWallet | address                  | 5    | 0      | 20    | src/TalentCommunitySale.sol:TalentCommunitySale |
| tier1Bought     | uint32                   | 5    | 20     | 4     | src/TalentCommunitySale.sol:TalentCommunitySale |
| tier2Bought     | uint32                   | 5    | 24     | 4     | src/TalentCommunitySale.sol:TalentCommunitySale |
| tier3Bought     | uint32                   | 5    | 28     | 4     | src/TalentCommunitySale.sol:TalentCommunitySale |
| tier4Bought     | uint32                   | 6    | 0      | 4     | src/TalentCommunitySale.sol:TalentCommunitySale |
| saleActive      | bool                     | 6    | 4      | 1     | src/TalentCommunitySale.sol:TalentCommunitySale |
| _status         | uint8                    | 6    | 5      | 1     | src/TalentCommunitySale.sol:TalentCommunitySale |

### Gas Optimization

#### Before Any Optimization

When running the tests locally with the command:

```bash
$ forge test -vvv --summary --gas-report
```
we get:

`buyTier1: 97,894`


| src/TalentCommunitySale.sol:TalentCommunitySale contract |                 |       |        |        |         |
|----------------------------------------------------------|-----------------|-------|--------|--------|---------|
| Deployment Cost                                          | Deployment Size |       |        |        |         |
| 1411071                                                  | 6243            |       |        |        |         |
| Function Name                                            | min             | avg   | median | max    | # calls |
| TIER1_MAX_BUYS                                           | 283             | 283   | 283    | 283    | 1       |
| TIER2_MAX_BUYS                                           | 238             | 238   | 238    | 238    | 1       |
| TIER3_MAX_BUYS                                           | 239             | 239   | 239    | 239    | 1       |
| TIER4_MAX_BUYS                                           | 261             | 261   | 261    | 261    | 1       |
| buyTier1                                                 | 28605           | 80150 | 79761  | 113961 | 111     |
| buyTier2                                                 | 28582           | 79811 | 79738  | 113938 | 591     |
| buyTier3                                                 | 28550           | 79751 | 79717  | 113917 | 1261    |
| buyTier4                                                 | 28561           | 81928 | 81636  | 132936 | 531     |
| disableSale                                              | 23496           | 24965 | 25659  | 25659  | 6       |
| enableSale                                               | 23472           | 44975 | 45541  | 45541  | 39      |
| listOfBuyers                                             | 585             | 1585  | 1585   | 2585   | 8       |
| owner                                                    | 2399            | 2399  | 2399   | 2399   | 1       |
| paymentToken                                             | 2405            | 2405  | 2405   | 2405   | 1       |
| receivingWallet                                          | 2426            | 2426  | 2426   | 2426   | 1       |
| saleActive                                               | 355             | 855   | 355    | 2355   | 4       |
| tier1Bought                                              | 363             | 1696  | 2363   | 2363   | 3       |
| tier2Bought                                              | 407             | 1407  | 1407   | 2407   | 2       |
| tier3Bought                                              | 386             | 1386  | 1386   | 2386   | 2       |
| tier4Bought                                              | 349             | 1349  | 1349   | 2349   | 2       |
| totalRaised                                              | 384             | 1584  | 2384   | 2384   | 10      |

And this is the `.gas-snapshot` running the tests:

```
TalentCommunitySaleTest:testTier1WithinLimit() (gas: 10612)
TalentCommunitySaleTest:test_BuyTier1_AddsBuyerToListOfBuyers() (gas: 148432)
TalentCommunitySaleTest:test_BuyTier1_EmitsTier1Bought() (gas: 147487)
TalentCommunitySaleTest:test_BuyTier1_IncreasesTotalRaisedBy100() (gas: 148290)
TalentCommunitySaleTest:test_BuyTier1_ReceivingWalletGetsTheAmountFromBuyer() (gas: 152616)
TalentCommunitySaleTest:test_BuyTier1_Tier1BoughtIsIncrementedByOne() (gas: 147922)
TalentCommunitySaleTest:test_BuyTier1_WhenCallerDoesNotHaveEnoughBalance_ItReverts() (gas: 116187)
TalentCommunitySaleTest:test_BuyTier1_WhenCallerHasAlreadyBought_ItReverts() (gas: 199862)
TalentCommunitySaleTest:test_BuyTier1_WhenCallerHasNotAllowedContractToSpendMoney_ItReverts() (gas: 49148)
TalentCommunitySaleTest:test_BuyTier1_WhenTier1BoughtIsGreaterThanTIER1_MAX_BUYS_ItReverts() (gas: 7324427)
TalentCommunitySaleTest:test_BuyTier1_whenSaleIsNotActiveItReverts() (gas: 18923)
TalentCommunitySaleTest:test_BuyTier2_AddsBuyerToListOfBuyers() (gas: 148396)
TalentCommunitySaleTest:test_BuyTier2_EmitsTier2Bought() (gas: 147452)
TalentCommunitySaleTest:test_BuyTier2_IncreasesTotalRaisedBy250() (gas: 148288)
TalentCommunitySaleTest:test_BuyTier2_ReceivingWalletGetsTheAmountFromBuyer() (gas: 152572)
TalentCommunitySaleTest:test_BuyTier2_Tier2BoughtIsIncrementedByOne() (gas: 147953)
TalentCommunitySaleTest:test_BuyTier2_WhenCallerDoesNotHaveEnoughBalance_ItReverts() (gas: 116184)
TalentCommunitySaleTest:test_BuyTier2_WhenCallerHasAlreadyBought_ItReverts() (gas: 199838)
TalentCommunitySaleTest:test_BuyTier2_WhenCallerHasNotAllowedContractToSpendMoney_ItReverts() (gas: 49072)
TalentCommunitySaleTest:test_BuyTier2_WhenTier2BoughtIsGreaterThanTIER2_MAX_BUYS_ItReverts() (gas: 41889239)
TalentCommunitySaleTest:test_BuyTier2_whenSaleIsNotActiveItReverts() (gas: 18889)
TalentCommunitySaleTest:test_BuyTier3_AddsBuyerToListOfBuyers() (gas: 148378)
TalentCommunitySaleTest:test_BuyTier3_EmitsTier3Bought() (gas: 147470)
TalentCommunitySaleTest:test_BuyTier3_IncreasesTotalRaisedBy500() (gas: 148236)
TalentCommunitySaleTest:test_BuyTier3_ReceivingWalletGetsTheAmountFromBuyer() (gas: 152529)
TalentCommunitySaleTest:test_BuyTier3_Tier3BoughtIsIncrementedByOne() (gas: 147904)
TalentCommunitySaleTest:test_BuyTier3_WhenCallerDoesNotHaveEnoughBalance_ItReverts() (gas: 116142)
TalentCommunitySaleTest:test_BuyTier3_WhenCallerHasAlreadyBought_ItReverts() (gas: 199773)
TalentCommunitySaleTest:test_BuyTier3_WhenCallerHasNotAllowedContractToSpendMoney_ItReverts() (gas: 49095)
TalentCommunitySaleTest:test_BuyTier3_WhenTier3BoughtIsGreaterThanTIER3_MAX_BUYS_ItReverts() (gas: 90136816)
TalentCommunitySaleTest:test_BuyTier3_whenSaleIsNotActiveItReverts() (gas: 18879)
TalentCommunitySaleTest:test_BuyTier4_AddsBuyerToListOfBuyers() (gas: 167191)
TalentCommunitySaleTest:test_BuyTier4_BuyingTier4IncreasesTotalRaisedBy1000() (gas: 167000)
TalentCommunitySaleTest:test_BuyTier4_EmitsTier4Bought() (gas: 166022)
TalentCommunitySaleTest:test_BuyTier4_ReceivingWalletGetsTheAmountFromBuyer() (gas: 171613)
TalentCommunitySaleTest:test_BuyTier4_Tier4BoughtIsIncrementedByOne() (gas: 166512)
TalentCommunitySaleTest:test_BuyTier4_WhenCallerDoesNotHaveEnoughBalance_ItReverts() (gas: 118193)
TalentCommunitySaleTest:test_BuyTier4_WhenCallerHasAlreadyBought_ItReverts() (gas: 218802)
TalentCommunitySaleTest:test_BuyTier4_WhenCallerHasNotAllowedContractToSpendMoney_ItReverts() (gas: 49028)
TalentCommunitySaleTest:test_BuyTier4_WhenTier4BoughtIsGreaterThanTIER4_MAX_BUYS_ItReverts() (gas: 37540611)
TalentCommunitySaleTest:test_BuyTier4_whenSaleIsNotActiveItReverts() (gas: 18868)
TalentCommunitySaleTest:test_DisableSale() (gas: 24702)
TalentCommunitySaleTest:test_DisableSale_OnlyByOwner() (gas: 11447)
TalentCommunitySaleTest:test_EnableSale() (gas: 34983)
TalentCommunitySaleTest:test_EnableSale_OnlyByOwner() (gas: 11423)
TalentCommunitySaleTest:test_InitialTotalRaisedIsZero() (gas: 10629)
TalentCommunitySaleTest:test_OwnerIsGivenAsFirstArgument() (gas: 12808)
TalentCommunitySaleTest:test_PaymentTokenIsGivenAsArgument() (gas: 12814)
TalentCommunitySaleTest:test_ReceivingWalletReturnsTheWalletWeDeployedWith() (gas: 12878)
TalentCommunitySaleTest:test_TotalRaisedUpdatesCorrectly() (gas: 10607)
```

The contract has been deployed on Base network on this address:

```
https://basescan.org/address/0xcd2fbec25b07f065bc905051c801df66a5b48512
```

with the following transaction:

```
https://basescan.org/tx/0x90cc2d62bf1518c4a87684810e9efefb12cb081873497ece74b767c65076286f
```

The gas used by the deployment transaction was:

```
1_411_679 Gwei
```

On production we can see that:

`buyTier1()` costs `97,894` gas.
`buyTier2()` costs `97,871` gas.
`buyTier3()` costs `97,850` gas.
`buyTier4()` costs `99,769` gas.

...

## After Optimization

### Optimizations We Did

We are listing here the optimizations we did in the order applied:

1. Removed dependency to Ownable and ReentrancyGuard.
1. Removed dependency to Math.
1. Removed `require` calls and converted to condition checks and `revert` statements with custom errors.
1. Reorganized the storage state properties to use 2 slots less.
1. Big portion of the function has been implemented in Yul.

| src/TalentCommunitySale.sol:TalentCommunitySale contract |                 |       |        |        |         |
|----------------------------------------------------------|-----------------|-------|--------|--------|---------|
| Deployment Cost                                          | Deployment Size |       |        |        |         |
| 692277                                                   | 3292            |       |        |        |         |
| Function Name                                            | min             | avg   | median | max    | # calls |
| TIER1_AMOUNT                                             | 240             | 240   | 240    | 240    | 1       |
| TIER1_MAX_BUYS                                           | 261             | 261   | 261    | 261    | 1       |
| TIER2_AMOUNT                                             | 240             | 240   | 240    | 240    | 1       |
| TIER2_MAX_BUYS                                           | 261             | 261   | 261    | 261    | 1       |
| TIER3_AMOUNT                                             | 261             | 261   | 261    | 261    | 1       |
| TIER3_MAX_BUYS                                           | 283             | 283   | 283    | 283    | 1       |
| TIER4_AMOUNT                                             | 239             | 239   | 239    | 239    | 1       |
| TIER4_MAX_BUYS                                           | 239             | 239   | 239    | 239    | 1       |
| buyTier1                                                 | 26574           | 72283 | 72160  | 106360 | 112     |
| buyTier2                                                 | 26595           | 72204 | 72181  | 106381 | 592     |
| buyTier3                                                 | 26597           | 72193 | 72183  | 106383 | 1262    |
| buyTier4                                                 | 26617           | 72221 | 72203  | 106403 | 532     |
| disableSale                                              | 23463           | 25742 | 25638  | 28438  | 6       |
| enableSale                                               | 23461           | 28326 | 28442  | 28442  | 43      |
| listOfBuyers                                             | 563             | 1563  | 1563   | 2563   | 8       |
| owner                                                    | 383             | 1049  | 383    | 2383   | 3       |
| paymentToken                                             | 2383            | 2383  | 2383   | 2383   | 1       |
| receivingWallet                                          | 2426            | 2426  | 2426   | 2426   | 1       |
| renounceOwnership                                        | 23176           | 23318 | 23318  | 23461  | 2       |
| saleActive                                               | 411             | 911   | 411    | 2411   | 4       |
| tier1Bought                                              | 402             | 1735  | 2402   | 2402   | 3       |
| tier2Bought                                              | 423             | 1423  | 1423   | 2423   | 2       |
| tier3Bought                                              | 403             | 1403  | 1403   | 2403   | 2       |
| tier4Bought                                              | 349             | 349   | 349    | 349    | 2       |
| totalRaised                                              | 340             | 1540  | 2340   | 2340   | 10      |
| transferOwnership                                        | 23769           | 26803 | 28321  | 28321  | 3       |

The `.gas-snapshot`

TalentCommunitySaleTest:testTier1WithinLimit() (gas: 10685)
TalentCommunitySaleTest:test_BuyTier1_AddsBuyerToListOfBuyers() (gas: 126430)
TalentCommunitySaleTest:test_BuyTier1_EmitsTier1Bought() (gas: 125469)
TalentCommunitySaleTest:test_BuyTier1_IncreasesTotalRaisedBy100() (gas: 126193)
TalentCommunitySaleTest:test_BuyTier1_OnReentrancy_ItReverts() (gas: 89275)
TalentCommunitySaleTest:test_BuyTier1_ReceivingWalletGetsTheAmountFromBuyer() (gas: 129960)
TalentCommunitySaleTest:test_BuyTier1_Tier1BoughtIsIncrementedByOne() (gas: 125976)
TalentCommunitySaleTest:test_BuyTier1_WhenCallerDoesNotHaveEnoughBalance_ItReverts() (gas: 90071)
TalentCommunitySaleTest:test_BuyTier1_WhenCallerHasAlreadyBought_ItReverts() (gas: 171038)
TalentCommunitySaleTest:test_BuyTier1_WhenCallerHasNotAllowedContractToSpendMoney_ItReverts() (gas: 30617)
TalentCommunitySaleTest:test_BuyTier1_WhenTier1BoughtIsGreaterThanTIER1_MAX_BUYS_ItReverts() (gas: 6791667)
TalentCommunitySaleTest:test_BuyTier1_whenSaleIsNotActiveItReverts() (gas: 16796)
TalentCommunitySaleTest:test_BuyTier2_AddsBuyerToListOfBuyers() (gas: 126430)
TalentCommunitySaleTest:test_BuyTier2_EmitsTier2Bought() (gas: 125504)
TalentCommunitySaleTest:test_BuyTier2_IncreasesTotalRaisedBy250() (gas: 126209)
TalentCommunitySaleTest:test_BuyTier2_OnReentrancy_ItReverts() (gas: 89297)
TalentCommunitySaleTest:test_BuyTier2_ReceivingWalletGetsTheAmountFromBuyer() (gas: 129996)
TalentCommunitySaleTest:test_BuyTier2_Tier2BoughtIsIncrementedByOne() (gas: 126059)
TalentCommunitySaleTest:test_BuyTier2_WhenCallerDoesNotHaveEnoughBalance_ItReverts() (gas: 90048)
TalentCommunitySaleTest:test_BuyTier2_WhenCallerHasAlreadyBought_ItReverts() (gas: 171102)
TalentCommunitySaleTest:test_BuyTier2_WhenCallerHasNotAllowedContractToSpendMoney_ItReverts() (gas: 30661)
TalentCommunitySaleTest:test_BuyTier2_WhenTier2BoughtIsGreaterThanTIER2_MAX_BUYS_ItReverts() (gas: 38918982)
TalentCommunitySaleTest:test_BuyTier2_whenSaleIsNotActiveItReverts() (gas: 16805)
TalentCommunitySaleTest:test_BuyTier3_AddsBuyerToListOfBuyers() (gas: 126449)
TalentCommunitySaleTest:test_BuyTier3_EmitsTier3Bought() (gas: 125524)
TalentCommunitySaleTest:test_BuyTier3_IncreasesTotalRaisedBy500() (gas: 126246)
TalentCommunitySaleTest:test_BuyTier3_OnReentrancy_ItReverts() (gas: 89276)
TalentCommunitySaleTest:test_BuyTier3_ReceivingWalletGetsTheAmountFromBuyer() (gas: 129980)
TalentCommunitySaleTest:test_BuyTier3_Tier3BoughtIsIncrementedByOne() (gas: 125976)
TalentCommunitySaleTest:test_BuyTier3_WhenCallerDoesNotHaveEnoughBalance_ItReverts() (gas: 90051)
TalentCommunitySaleTest:test_BuyTier3_WhenCallerHasAlreadyBought_ItReverts() (gas: 171083)
TalentCommunitySaleTest:test_BuyTier3_WhenCallerHasNotAllowedContractToSpendMoney_ItReverts() (gas: 30663)
TalentCommunitySaleTest:test_BuyTier3_WhenTier3BoughtIsGreaterThanTIER3_MAX_BUYS_ItReverts() (gas: 83782252)
TalentCommunitySaleTest:test_BuyTier3_whenSaleIsNotActiveItReverts() (gas: 16873)
TalentCommunitySaleTest:test_BuyTier4_AddsBuyerToListOfBuyers() (gas: 124182)
TalentCommunitySaleTest:test_BuyTier4_BuyingTier4IncreasesTotalRaisedBy1000() (gas: 124020)
TalentCommunitySaleTest:test_BuyTier4_EmitsTier4Bought() (gas: 123300)
TalentCommunitySaleTest:test_BuyTier4_OnReentrancy_ItReverts() (gas: 89299)
TalentCommunitySaleTest:test_BuyTier4_ReceivingWalletGetsTheAmountFromBuyer() (gas: 127755)
TalentCommunitySaleTest:test_BuyTier4_Tier4BoughtIsIncrementedByOne() (gas: 123683)
TalentCommunitySaleTest:test_BuyTier4_WhenCallerDoesNotHaveEnoughBalance_ItReverts() (gas: 90136)
TalentCommunitySaleTest:test_BuyTier4_WhenCallerHasAlreadyBought_ItReverts() (gas: 168347)
TalentCommunitySaleTest:test_BuyTier4_WhenCallerHasNotAllowedContractToSpendMoney_ItReverts() (gas: 30638)
TalentCommunitySaleTest:test_BuyTier4_WhenTier4BoughtIsGreaterThanTIER4_MAX_BUYS_ItReverts() (gas: 34909565)
TalentCommunitySaleTest:test_BuyTier4_whenSaleIsNotActiveItReverts() (gas: 16872)
TalentCommunitySaleTest:test_DisableSale() (gas: 16358)
TalentCommunitySaleTest:test_DisableSale_OnlyByOwner() (gas: 11459)
TalentCommunitySaleTest:test_EnableSale() (gas: 18019)
TalentCommunitySaleTest:test_EnableSale_OnlyByOwner() (gas: 11435)
TalentCommunitySaleTest:test_InitialTotalRaisedIsZero() (gas: 10596)
TalentCommunitySaleTest:test_OwnerIsGivenAsFirstArgument() (gas: 12815)
TalentCommunitySaleTest:test_PaymentTokenIsGivenAsArgument() (gas: 12858)
TalentCommunitySaleTest:test_ReceivingWalletReturnsTheWalletWeDeployedWith() (gas: 12878)
TalentCommunitySaleTest:test_RenounceOwnerhip_OnlyOwner() (gas: 11433)
TalentCommunitySaleTest:test_RenounceOwnership_TransfersOwnershipToAddressZero() (gas: 11331)
TalentCommunitySaleTest:test_TotalRaisedUpdatesCorrectly() (gas: 10575)
TalentCommunitySaleTest:test_TransferOwnership_EmitsEventForTransferOwnership() (gas: 16813)
TalentCommunitySaleTest:test_TransferOwnership_OnlyOwner() (gas: 11577)
TalentCommunitySaleTest:test_TransferOwnership_TransfersOwnershipToNewOwner() (gas: 16294)

## General Instructions on Foundry

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
$ forge test
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
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
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

# Deployment

## Anvil Locally

1st deploy the USDTMock:

```
forge script --rpc-url 127.0.0.1:8545 script/DeployTalentCommunitySale.s.sol:DeployUSDTMock --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

which deployed on address : 0x5FbDB2315678afecb367f032d93F642f64180aa3

2nd deploy the contract:

```
forge script --rpc-url 127.0.0.1:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 script/DeployTalentCommunitySale.s.sol:DeployTalentCommunitySale 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 0x5FbDB2315678afecb367f032d93F642f64180aa3 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 6 --sig 'run(address,address,address,uint256)'
```

which deployed on address : 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512

Then we enable the sale on the contract:

```
forge script --rpc-url 127.0.0.1:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 script/DeployTalentCommunitySale.s.sol:DeployTalentCommunitySale 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 --sig 'enableSale(address)'
```

But then we started `chisel` to interact with Anvil.

```bash
chisel --rpc-url 127.0.0.1:8545 --use 0.8.24
```

And we did `t.approve(...)` and then `t.buyTier1()` ... and it worked.

## 2nd Deploy to Base Sepolia

We know the USDC address: 0x036CbD53842c5426634e7929541eC2318f3dCF7e (paymentToken)
InitialOwner:             0xec4a93E2e955d97F0bE36e3E3533259629EaE7cA
ReceivingWallet:          0x6D2Dd04bF065c8A6ee9CeC97588AbB0f967E0df9
decimals:                 6


```
forge script --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --private-key $PRIVATE_KEY script/DeployTalentCommunitySale.s.sol:DeployTalentCommunitySale 0xec4a93E2e955d97F0bE36e3E3533259629EaE7cA 0x036CbD53842c5426634e7929541eC2318f3dCF7e 0x6D2Dd04bF065c8A6ee9CeC97588AbB0f967E0df9 6 --sig 'run(address,address,address,uint256)'
```

Deployed with transaction hash: [0x809b3e1839b8d5d092d7ceb3b887c74337c9eda66450da74f8314efb8a14625f](https://sepolia.basescan.org/tx/0x809b3e1839b8d5d092d7ceb3b887c74337c9eda66450da74f8314efb8a14625f)
Contract address: [0x0fC7A12693811Ee5c99c99c63913506a432f55fb](https://sepolia.basescan.org/address/0x0fC7A12693811Ee5c99c99c63913506a432f55fb)
Gas: `692_699`

We redeployed so that tier1 amount is `5` instead of `100`.

Transaction hash: [0x4c9162e419e3b9f780bbbf730270536ace15a6c523cfe051ee0b9a6e0eac68e1](https://sepolia.basescan.org/tx/0x4c9162e419e3b9f780bbbf730270536ace15a6c523cfe051ee0b9a6e0eac68e1)
Contract address: [0x76ECF5faB5Ce2B0a62718d101b944022C74FEA4A](https://sepolia.basescan.org/address/0x76ECF5faB5Ce2B0a62718d101b944022C74FEA4A)

This allowed us to run a script to buyTier1():

1. We enable the sale with:

```
forge script --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --private-key $PRIVATE_KEY script/DeployTalentCommunitySale.s.sol:DeployTalentCommunitySale 0x76ECF5faB5Ce2B0a62718d101b944022C74FEA4A --sig 'enableSale(address)'
```

which gave us the transaction hash 0x8dfeffc7a1f14114feb00d0902094e44166222b0c922051c386783b6e4f019e8
with gas used `28,442`. This is equal to the `median` reported by `forge test`. Compare that to the
`45,541` which was used on `Base` with the original non-optimized version of the contract (transaction: https://basescan.org/tx/0xf17e1d3085b208edb5258e070de80cef5e0257a1295b18fa1a326480352f04a9).

1. We then approve the `TalentCommunitySale` to spend `5 USDC` for the account that does the `buyTier1()`.

```
forge script --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --private-key $PRIVATE_KEY script/DeployTalentCommunitySale.s.sol:DeployTalentCommunitySale 0x76ECF5faB5Ce2B0a62718d101b944022C74FEA4A 0x036CbD53842c5426634e7929541eC2318f3dCF7e 5000000 --sig 'approve(address,address,uint256)'
```

Transaction: [0x0dc3b3ea9d89b0fab3d643dbae3068dde77b4e4e1f4e0e90c0c30c3098f0f9fc](https://sepolia.basescan.org/tx/0x0dc3b3ea9d89b0fab3d643dbae3068dde77b4e4e1f4e0e90c0c30c3098f0f9fc)

1. We then call `buyTier1()` which will transfer `5 USDC` from account `0x036CbD53842c5426634e7929541eC2318f3dCF7e` to account `0x6D2Dd04bF065c8A6ee9CeC97588AbB0f967E0df9`

```
forge script --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --private-key $PRIVATE_KEY script/DeployTalentCommunitySale.s.sol:DeployTalentCommunitySale 0x76ECF5faB5Ce2B0a62718d101b944022C74FEA4A --sig 'buyTier1(address)'
```

Transaction hash: [0xf7633b809fc2fff6d0c43fc98037c25f9664d89bd412605a2c965abcbf77201a](https://sepolia.basescan.org/tx/0xf7633b809fc2fff6d0c43fc98037c25f9664d89bd412605a2c965abcbf77201a)

Gas used `123,926`. This is actually quite higher to the numbers reported by `forge test --gas-report` (median: `72,160`). **Why?**

**WE REPEAT** `buyTier1()` for another account.

Then we funded with `5 USDC` the account `0x436cA2299e7fDF36C4b1164cA3e80081E68c318A`

1. We then approve the `TalentCommunitySale` to spend `5 USDC` for the account `0x436cA2299e7fDF36C4b1164cA3e80081E68c318A` that does the `buyTier1()`.

```
forge script --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --private-key $PRIVATE_KEY_SECOND_ACCOUNT script/DeployTalentCommunitySale.s.sol:DeployTalentCommunitySale 0x76ECF5faB5Ce2B0a62718d101b944022C74FEA4A 0x036CbD53842c5426634e7929541eC2318f3dCF7e 5000000 --sig 'approve(address,address,uint256)'
```

Transaction hash: [0x84fd58c890920bf14816e675103864f27c2a1b6255ca27a11f485d951254ead8](https://sepolia.basescan.org/tx/0x84fd58c890920bf14816e675103864f27c2a1b6255ca27a11f485d951254ead8)

1. We then call `buyTier1()` which will transfer `5 USDC` from account `0x436cA2299e7fDF36C4b1164cA3e80081E68c318A` to account `0x6D2Dd04bF065c8A6ee9CeC97588AbB0f967E0df9`

```
forge script --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --private-key $PRIVATE_KEY_SECOND_ACCOUNT script/DeployTalentCommunitySale.s.sol:DeployTalentCommunitySale 0x76ECF5faB5Ce2B0a62718d101b944022C74FEA4A --sig 'buyTier1(address)'
```

Transaction hash: [0x55c422045a3fc126d03cd69f232d982b11115d69558949087aee4057e6793ff6](https://sepolia.basescan.org/tx/0x55c422045a3fc126d03cd69f232d982b11115d69558949087aee4057e6793ff6)

Gas used `89,726`. This is again quite higher to the numbers reported by `forge test --gas-report` (median: `72,160`). **Why?**
