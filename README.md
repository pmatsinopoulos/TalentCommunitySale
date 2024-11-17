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

... to be provided ...

### Gas Optimization

#### Before Any Optimization

When running the tests locally with the command:

```bash
$ forge test -vvv --summary --gas-report
```
we get:

buyTier1: 97,894
97,894
97,894


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
