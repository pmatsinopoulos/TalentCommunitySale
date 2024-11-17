// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {TalentCommunitySale} from "../src/TalentCommunitySale.sol";
import {USDTMock} from "./ERC20Mock.sol";
import {USDTMockBad} from "./ERC20MockBad.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TalentCommunitySaleTest is Test {
    TalentCommunitySale talentCommunitySale;
    TalentCommunitySale talentCommunitySaleBad;

    address initialOwner = address(this);
    IERC20 paymentToken = new USDTMock();
    IERC20 paymentTokenBad = new USDTMockBad();
    address receivingWallet = address(1337);
    uint256 tokenDecimals = 6;

    event Tier1Bought(address indexed buyer, uint256 amount);
    event Tier2Bought(address indexed buyer, uint256 amount);
    event Tier3Bought(address indexed buyer, uint256 amount);
    event Tier4Bought(address indexed buyer, uint256 amount);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    error ERC20InsufficientBalance(address from, uint256 balance, uint256 required);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error OwnableUnauthorizedAccount(address account);

    function setUp() public {
        talentCommunitySale =
            new TalentCommunitySale(initialOwner, address(paymentToken), receivingWallet, tokenDecimals);
        talentCommunitySaleBad =
            new TalentCommunitySale(initialOwner, address(paymentTokenBad), receivingWallet, tokenDecimals);
    }

    function test_OwnerIsGivenAsFirstArgument() public view {
        assertEq(talentCommunitySale.owner(), initialOwner);
    }

    function test_PaymentTokenIsGivenAsArgument() public view {
        assertEq(address(talentCommunitySale.paymentToken()), address(paymentToken));
    }

    function testTier1WithinLimit() public view {
        assertEq(talentCommunitySale.tier1Bought(), 0);
    }

    function test_ReceivingWalletReturnsTheWalletWeDeployedWith() public view {
        address result = talentCommunitySale.receivingWallet();

        assertEq(result, receivingWallet);
    }

    function test_InitialTotalRaisedIsZero() public view {
        uint256 initialTotalRaised = talentCommunitySale.totalRaised();
        assertEq(initialTotalRaised, 0);
    }

    function test_TotalRaisedUpdatesCorrectly() public view {
        uint256 updatedTotalRaised = talentCommunitySale.totalRaised();
        assertEq(updatedTotalRaised, 0);
    }

    function test_EnableSale() public {
        assertEq(talentCommunitySale.saleActive(), false);

        talentCommunitySale.enableSale();

        assertEq(talentCommunitySale.saleActive(), true);
    }

    function test_EnableSale_OnlyByOwner() public {
        vm.prank(address(0));

        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0)));
        talentCommunitySale.enableSale();
    }

    function test_DisableSale() public {
        talentCommunitySale.enableSale();

        assertEq(talentCommunitySale.saleActive(), true);

        talentCommunitySale.disableSale();

        assertEq(talentCommunitySale.saleActive(), false);
    }

    function test_DisableSale_OnlyByOwner() public {
        vm.prank(address(0));

        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0)));
        talentCommunitySale.disableSale();
    }

    // ---------- Ownership --------------------------
    function test_RenounceOwnerhip_OnlyOwner() public {
        vm.prank(address(0));

        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0)));
        talentCommunitySale.renounceOwnership();
    }

    function test_RenounceOwnership_TransfersOwnershipToAddressZero() public {
        talentCommunitySale.renounceOwnership();

        assertEq(talentCommunitySale.owner(), address(0));
    }

    function test_TransferOwnership_OnlyOwner() public {
        vm.prank(address(0));

        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0)));
        address newOwner = address(9994939);
        talentCommunitySale.transferOwnership(newOwner);
    }

    function test_TransferOwnership_TransfersOwnershipToNewOwner() public {
        address newOwner = address(9994939);
        talentCommunitySale.transferOwnership(newOwner);

        assertEq(talentCommunitySale.owner(), newOwner);
    }

    function test_TransferOwnership_EmitsEventForTransferOwnership() public {
        address newOwner = address(9994939);

        vm.expectEmit(true, true, false, false);
        emit OwnershipTransferred(address(this), newOwner);
        talentCommunitySale.transferOwnership(newOwner);
    }
    // --- end of Ownership --------------------------

    // -----------------------------------------------
    // buyTier1() ------------------------------------

    function test_BuyTier1_whenSaleIsNotActiveItReverts() public {
        talentCommunitySale.disableSale();

        vm.expectRevert(TalentCommunitySale.SaleIsNotActive.selector);
        talentCommunitySale.buyTier1();
    }

    function test_BuyTier1_WhenCallerHasNotAllowedContractToSpendMoney_ItReverts() public {
        talentCommunitySale.enableSale();

        vm.expectRevert(
            abi.encodeWithSelector(
                ERC20InsufficientAllowance.selector, talentCommunitySale, 0, talentCommunitySale.TIER1_AMOUNT()
            )
        );

        talentCommunitySale.buyTier1();
    }

    function test_BuyTier1_WhenTier1BoughtIsGreaterThanTIER1_MAX_BUYS_ItReverts() public {
        talentCommunitySale.enableSale();
        uint32 tier1MaxBuys = talentCommunitySale.TIER1_MAX_BUYS(); // 100

        for (uint256 i = 1; i <= tier1MaxBuys + 1; i++) {
            address caller = address(uint160(uint256(keccak256(abi.encodePacked(i)))));
            // Panos address
            // John address
            // ... more address

            uint256 amount = 100 * 10 ** tokenDecimals;
            paymentToken.transfer(caller, amount);
            // Panos now has 100M USDT
            // John 100M USDT
            // ..100 addresses everything goes well.

            // Panos approves the contract TalentCommunitySale to spend that 100M
            // John approve....
            vm.prank(caller); // sets the "msg.sender" of the next contract call.
            paymentToken.approve(address(talentCommunitySale), amount);

            if (i == tier1MaxBuys + 1) {
                // i is 101
                vm.expectRevert(TalentCommunitySale.Tier1SoldOut.selector);
            }

            // Panos is asking the contract TaletnCommunitySale to buyAtTier1 100M
            // John is asking...
            vm.prank(caller);
            talentCommunitySale.buyTier1();
        }
    }

    function test_BuyTier1_WhenCallerHasAlreadyBought_ItReverts() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 100 * 10 ** tokenDecimals;

        for (uint256 i = 1; i <= 2; i++) {
            paymentToken.transfer(caller, amount);

            vm.prank(caller);
            paymentToken.approve(address(talentCommunitySale), amount);

            if (i == 2) {
                vm.expectRevert(abi.encodeWithSelector(TalentCommunitySale.AddressAlreadyBought.selector, caller));
            }
            vm.prank(caller);
            talentCommunitySale.buyTier1();
        }
    }

    function test_BuyTier1_WhenCallerDoesNotHaveEnoughBalance_ItReverts() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 100 * 10 ** tokenDecimals; // 100

        // I am setting the +caller+ balance to lower than +amount+ by just
        // 1 cent.
        paymentToken.transfer(caller, amount - 1); // 99

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.expectRevert(abi.encodeWithSelector(ERC20InsufficientBalance.selector, caller, amount - 1, amount));
        vm.prank(caller);

        talentCommunitySale.buyTier1();
    }

    function test_BuyTier1_ReceivingWalletGetsTheAmountFromBuyer() public {
        // SETUP phase
        // -----------
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 100 * 10 ** tokenDecimals;

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);
        //--------------------------------------------------------

        paymentToken.transfer(caller, amount);

        uint256 receivingWalletBalanceBefore = paymentToken.balanceOf(receivingWallet);
        uint256 buyerBalanceBefore = paymentToken.balanceOf(caller);

        // now that requirements are met, we fire test method
        // FIRE phase

        vm.prank(caller);
        talentCommunitySale.buyTier1();

        // TEST phase
        uint256 receivingWalletBalanceAfter = paymentToken.balanceOf(receivingWallet);

        assertEq(receivingWalletBalanceAfter, receivingWalletBalanceBefore + amount);

        uint256 buyerBalanceAfter = paymentToken.balanceOf(caller);

        assertEq(buyerBalanceAfter, buyerBalanceBefore - amount);
    }

    function test_BuyTier1_Tier1BoughtIsIncrementedByOne() public {
        // SETUP phase
        // -----------
        talentCommunitySale.enableSale(); // satisfies line 56

        uint32 tier1BoughtBefore = talentCommunitySale.tier1Bought();

        address caller = address(12347);

        uint256 amount = 100 * 10 ** tokenDecimals;

        // satisfy line 57, 58, 59, 60
        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);
        //--------------------------------------------------------

        // line 61 is already satisfied because +tier1Bought+ is already 0 < TIER1_MAX_BUYS

        // line 62 is already satisfied because +caller+ has not bought yet, so he is not
        // in the list of buyers

        // satisfies link 63, by setting enough balance for the +caller+, who is the
        // +msg.sender+ on that line
        paymentToken.transfer(caller, amount);

        // now that requirements are met, we fire test method
        // FIRE phase

        vm.prank(caller);
        talentCommunitySale.buyTier1();

        // TEST phase

        // we test whether the method under test did the job well.
        uint32 tier1BoughtAfter = talentCommunitySale.tier1Bought();

        assertEq(tier1BoughtAfter, tier1BoughtBefore + 1);
    }

    function test_BuyTier1_AddsBuyerToListOfBuyers() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 100 * 10 ** tokenDecimals;
        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        // before buying, we make sure caller is not in the list
        // of buyers
        assertEq(talentCommunitySale.listOfBuyers(caller), false);

        vm.prank(caller);
        talentCommunitySale.buyTier1();

        assertEq(talentCommunitySale.listOfBuyers(caller), true);
    }

    function test_BuyTier1_IncreasesTotalRaisedBy100() public {
        talentCommunitySale.enableSale();

        uint256 totalRaisedBefore = talentCommunitySale.totalRaised();

        address caller = address(12347);

        uint256 amount = 100 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        // FIRE phase
        vm.prank(caller);
        talentCommunitySale.buyTier1();

        // TEST
        uint256 totalRaisedAfter = talentCommunitySale.totalRaised();

        assertEq(totalRaisedAfter, totalRaisedBefore + (100 * 10 ** tokenDecimals));
    }

    function test_BuyTier1_EmitsTier1Bought() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 100 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.prank(caller);
        vm.expectEmit(true, false, false, true);
        emit Tier1Bought(caller, amount);

        talentCommunitySale.buyTier1();
    }

    function test_BuyTier1_OnReentrancy_ItReverts() public {
        talentCommunitySaleBad.enableSale();

        address caller = address(12347);

        uint256 amount = 100 * 10 ** tokenDecimals;

        paymentTokenBad.transfer(caller, amount);

        vm.prank(caller);
        paymentTokenBad.approve(address(talentCommunitySaleBad), amount);

        vm.prank(caller);
        try talentCommunitySaleBad.buyTier1() {}
        catch (bytes memory err) {
            assertEq(bytes4(err), TalentCommunitySale.ReentrancyGuardReentrantCall.selector);
        }
    }

    // end of buyTier1() --------------------------------------
    // --------------------------------------------------------

    // -----------------------------------------------
    // buyTier2() ------------------------------------

    function test_BuyTier2_whenSaleIsNotActiveItReverts() public {
        talentCommunitySale.disableSale();

        vm.expectRevert(TalentCommunitySale.SaleIsNotActive.selector);

        talentCommunitySale.buyTier2();
    }

    function test_BuyTier2_WhenCallerHasNotAllowedContractToSpendMoney_ItReverts() public {
        talentCommunitySale.enableSale();

        vm.expectRevert(
            abi.encodeWithSelector(
                ERC20InsufficientAllowance.selector, talentCommunitySale, 0, talentCommunitySale.TIER2_AMOUNT()
            )
        );

        talentCommunitySale.buyTier2();
    }

    function test_BuyTier2_WhenTier2BoughtIsGreaterThanTIER2_MAX_BUYS_ItReverts() public {
        talentCommunitySale.enableSale();
        uint32 tier2MaxBuys = talentCommunitySale.TIER2_MAX_BUYS();

        for (uint256 i = 1; i <= tier2MaxBuys + 1; i++) {
            address caller = address(uint160(uint256(keccak256(abi.encodePacked(i)))));

            uint256 amount = 250 * 10 ** tokenDecimals;
            paymentToken.transfer(caller, amount);

            vm.prank(caller); // sets the "msg.sender" of the next contract call.
            paymentToken.approve(address(talentCommunitySale), amount);

            if (i == tier2MaxBuys + 1) {
                vm.expectRevert(TalentCommunitySale.Tier2SoldOut.selector);
            }

            vm.prank(caller);
            talentCommunitySale.buyTier2();
        }
    }

    function test_BuyTier2_WhenCallerHasAlreadyBought_ItReverts() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 250 * 10 ** tokenDecimals;

        for (uint256 i = 1; i <= 2; i++) {
            paymentToken.transfer(caller, amount);

            vm.prank(caller);
            paymentToken.approve(address(talentCommunitySale), amount);

            if (i == 2) {
                vm.expectRevert(abi.encodeWithSelector(TalentCommunitySale.AddressAlreadyBought.selector, caller));
            }
            vm.prank(caller);
            talentCommunitySale.buyTier2();
        }
    }

    function test_BuyTier2_WhenCallerDoesNotHaveEnoughBalance_ItReverts() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 250 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount - 1);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.expectRevert(abi.encodeWithSelector(ERC20InsufficientBalance.selector, caller, amount - 1, amount));
        vm.prank(caller);

        talentCommunitySale.buyTier2();
    }

    function test_BuyTier2_OnReentrancy_ItReverts() public {
        talentCommunitySaleBad.enableSale();

        address caller = address(12347);

        uint256 amount = 250 * 10 ** tokenDecimals;

        paymentTokenBad.transfer(caller, amount);

        vm.prank(caller);
        paymentTokenBad.approve(address(talentCommunitySaleBad), amount);

        vm.prank(caller);
        try talentCommunitySaleBad.buyTier2() {}
        catch (bytes memory err) {
            assertEq(bytes4(err), TalentCommunitySale.ReentrancyGuardReentrantCall.selector);
        }
    }

    function test_BuyTier2_ReceivingWalletGetsTheAmountFromBuyer() public {
        // SETUP phase
        // -----------
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 250 * 10 ** tokenDecimals;

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);
        //--------------------------------------------------------

        paymentToken.transfer(caller, amount);

        uint256 receivingWalletBalanceBefore = paymentToken.balanceOf(receivingWallet);
        uint256 buyerBalanceBefore = paymentToken.balanceOf(caller);

        // now that requirements are met, we fire test method
        // FIRE phase

        vm.prank(caller);
        talentCommunitySale.buyTier2();

        // TEST phase
        uint256 receiveWalletBalanceAfter = paymentToken.balanceOf(receivingWallet);

        assertEq(receiveWalletBalanceAfter, receivingWalletBalanceBefore + amount);

        uint256 buyerBalanceAfter = paymentToken.balanceOf(caller);

        assertEq(buyerBalanceAfter, buyerBalanceBefore - amount);
    }

    function test_BuyTier2_Tier2BoughtIsIncrementedByOne() public {
        talentCommunitySale.enableSale();

        uint32 tier2BoughtBefore = talentCommunitySale.tier2Bought();

        address caller = address(12347);

        uint256 amount = 250 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.prank(caller);
        talentCommunitySale.buyTier2();

        uint32 tier2BoughtAfter = talentCommunitySale.tier2Bought();

        assertEq(tier2BoughtAfter, tier2BoughtBefore + 1);
    }

    function test_BuyTier2_AddsBuyerToListOfBuyers() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 250 * 10 ** tokenDecimals;
        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        // before buying, we make sure caller is not in the list
        // of buyers
        assertEq(talentCommunitySale.listOfBuyers(caller), false);

        vm.prank(caller);
        talentCommunitySale.buyTier2();

        assertEq(talentCommunitySale.listOfBuyers(caller), true);
    }

    function test_BuyTier2_IncreasesTotalRaisedBy250() public {
        talentCommunitySale.enableSale();

        uint256 totalRaisedBefore = talentCommunitySale.totalRaised();

        address caller = address(12347);

        uint256 amount = 250 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.prank(caller);
        talentCommunitySale.buyTier2();

        uint256 totalRaisedAfter = talentCommunitySale.totalRaised();

        assertEq(totalRaisedAfter, totalRaisedBefore + (250 * 10 ** tokenDecimals));
    }

    function test_BuyTier2_EmitsTier2Bought() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 250 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.prank(caller);
        vm.expectEmit(true, false, false, true);
        emit Tier2Bought(caller, amount);

        talentCommunitySale.buyTier2();
    }

    // -----------------------------------------------
    // buyTier3() ------------------------------------

    function test_BuyTier3_whenSaleIsNotActiveItReverts() public {
        talentCommunitySale.disableSale();

        vm.expectRevert(TalentCommunitySale.SaleIsNotActive.selector);

        talentCommunitySale.buyTier3();
    }

    function test_BuyTier3_WhenCallerHasNotAllowedContractToSpendMoney_ItReverts() public {
        talentCommunitySale.enableSale();

        vm.expectRevert(
            abi.encodeWithSelector(
                ERC20InsufficientAllowance.selector, talentCommunitySale, 0, talentCommunitySale.TIER3_AMOUNT()
            )
        );

        talentCommunitySale.buyTier3();
    }

    function test_BuyTier3_WhenTier3BoughtIsGreaterThanTIER3_MAX_BUYS_ItReverts() public {
        talentCommunitySale.enableSale();
        uint32 tier3MaxBuys = talentCommunitySale.TIER3_MAX_BUYS();

        for (uint256 i = 1; i <= tier3MaxBuys + 1; i++) {
            address caller = address(uint160(uint256(keccak256(abi.encodePacked(i)))));

            uint256 amount = 500 * 10 ** tokenDecimals;
            paymentToken.transfer(caller, amount);

            vm.prank(caller); // sets the "msg.sender" of the next contract call.
            paymentToken.approve(address(talentCommunitySale), amount);

            if (i == tier3MaxBuys + 1) {
                vm.expectRevert(TalentCommunitySale.Tier3SoldOut.selector);
            }

            vm.prank(caller);
            talentCommunitySale.buyTier3();
        }
    }

    function test_BuyTier3_WhenCallerHasAlreadyBought_ItReverts() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 500 * 10 ** tokenDecimals;

        for (uint256 i = 1; i <= 2; i++) {
            paymentToken.transfer(caller, amount);

            vm.prank(caller);
            paymentToken.approve(address(talentCommunitySale), amount);

            if (i == 2) {
                vm.expectRevert(abi.encodeWithSelector(TalentCommunitySale.AddressAlreadyBought.selector, caller));
            }
            vm.prank(caller);
            talentCommunitySale.buyTier3();
        }
    }

    function test_BuyTier3_WhenCallerDoesNotHaveEnoughBalance_ItReverts() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 500 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount - 1);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.expectRevert(abi.encodeWithSelector(ERC20InsufficientBalance.selector, caller, amount - 1, amount));
        vm.prank(caller);

        talentCommunitySale.buyTier3();
    }

    function test_BuyTier3_OnReentrancy_ItReverts() public {
        talentCommunitySaleBad.enableSale();

        address caller = address(12347);

        uint256 amount = 500 * 10 ** tokenDecimals;

        paymentTokenBad.transfer(caller, amount);

        vm.prank(caller);
        paymentTokenBad.approve(address(talentCommunitySaleBad), amount);

        vm.prank(caller);
        try talentCommunitySaleBad.buyTier3() {}
        catch (bytes memory err) {
            assertEq(bytes4(err), TalentCommunitySale.ReentrancyGuardReentrantCall.selector);
        }
    }

    function test_BuyTier3_ReceivingWalletGetsTheAmountFromBuyer() public {
        // SETUP phase
        // -----------
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 500 * 10 ** tokenDecimals;

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);
        //--------------------------------------------------------

        paymentToken.transfer(caller, amount);

        uint256 receivingWalletBalanceBefore = paymentToken.balanceOf(receivingWallet);
        uint256 buyerBalanceBefore = paymentToken.balanceOf(caller);

        // now that requirements are met, we fire test method
        // FIRE phase

        vm.prank(caller);
        talentCommunitySale.buyTier3();

        // TEST phase
        uint256 receiveWalletBalanceAfter = paymentToken.balanceOf(receivingWallet);

        assertEq(receiveWalletBalanceAfter, receivingWalletBalanceBefore + amount);

        uint256 buyerBalanceAfter = paymentToken.balanceOf(caller);

        assertEq(buyerBalanceAfter, buyerBalanceBefore - amount);
    }

    function test_BuyTier3_Tier3BoughtIsIncrementedByOne() public {
        talentCommunitySale.enableSale();

        uint32 tier3BoughtBefore = talentCommunitySale.tier3Bought();

        address caller = address(12347);

        uint256 amount = 500 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.prank(caller);
        talentCommunitySale.buyTier3();

        uint32 tier3BoughtAfter = talentCommunitySale.tier3Bought();

        assertEq(tier3BoughtAfter, tier3BoughtBefore + 1);
    }

    function test_BuyTier3_AddsBuyerToListOfBuyers() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 500 * 10 ** tokenDecimals;
        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        // before buying, we make sure caller is not in the list
        // of buyers
        assertEq(talentCommunitySale.listOfBuyers(caller), false);

        vm.prank(caller);
        talentCommunitySale.buyTier3();

        assertEq(talentCommunitySale.listOfBuyers(caller), true);
    }

    function test_BuyTier3_IncreasesTotalRaisedBy500() public {
        talentCommunitySale.enableSale();

        uint256 totalRaisedBefore = talentCommunitySale.totalRaised();

        address caller = address(12347);

        uint256 amount = 500 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.prank(caller);
        talentCommunitySale.buyTier3();

        uint256 totalRaisedAfter = talentCommunitySale.totalRaised();

        assertEq(totalRaisedAfter, totalRaisedBefore + (500 * 10 ** tokenDecimals));
    }

    function test_BuyTier3_EmitsTier3Bought() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 500 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.prank(caller);
        vm.expectEmit(true, false, false, true);
        emit Tier3Bought(caller, amount);

        talentCommunitySale.buyTier3();
    }

    // -----------------------------------------------
    // buyTier4() ------------------------------------

    function test_BuyTier4_whenSaleIsNotActiveItReverts() public {
        talentCommunitySale.disableSale();

        vm.expectRevert(TalentCommunitySale.SaleIsNotActive.selector);

        talentCommunitySale.buyTier4();
    }

    function test_BuyTier4_WhenCallerHasNotAllowedContractToSpendMoney_ItReverts() public {
        talentCommunitySale.enableSale();

        vm.expectRevert(
            abi.encodeWithSelector(
                ERC20InsufficientAllowance.selector, talentCommunitySale, 0, talentCommunitySale.TIER4_AMOUNT()
            )
        );

        talentCommunitySale.buyTier4();
    }

    function test_BuyTier4_WhenTier4BoughtIsGreaterThanTIER4_MAX_BUYS_ItReverts() public {
        talentCommunitySale.enableSale();
        uint32 tier4MaxBuys = talentCommunitySale.TIER4_MAX_BUYS();

        for (uint256 i = 1; i <= tier4MaxBuys + 1; i++) {
            address caller = address(uint160(uint256(keccak256(abi.encodePacked(i)))));

            uint256 amount = 1000 * 10 ** tokenDecimals;
            paymentToken.transfer(caller, amount);

            vm.prank(caller); // sets the "msg.sender" of the next contract call.
            paymentToken.approve(address(talentCommunitySale), amount);

            if (i == tier4MaxBuys + 1) {
                vm.expectRevert(TalentCommunitySale.Tier4SoldOut.selector);
            }

            vm.prank(caller);
            talentCommunitySale.buyTier4();
        }
    }

    function test_BuyTier4_WhenCallerHasAlreadyBought_ItReverts() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 1000 * 10 ** tokenDecimals;

        for (uint256 i = 1; i <= 2; i++) {
            paymentToken.transfer(caller, amount);

            vm.prank(caller);
            paymentToken.approve(address(talentCommunitySale), amount);

            if (i == 2) {
                vm.expectRevert(abi.encodeWithSelector(TalentCommunitySale.AddressAlreadyBought.selector, caller));
            }
            vm.prank(caller);
            talentCommunitySale.buyTier4();
        }
    }

    function test_BuyTier4_WhenCallerDoesNotHaveEnoughBalance_ItReverts() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 1000 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount - 1);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.expectRevert(abi.encodeWithSelector(ERC20InsufficientBalance.selector, caller, amount - 1, amount));
        vm.prank(caller);

        talentCommunitySale.buyTier4();
    }

    function test_BuyTier4_OnReentrancy_ItReverts() public {
        talentCommunitySaleBad.enableSale();

        address caller = address(12347);

        uint256 amount = 1000 * 10 ** tokenDecimals;

        paymentTokenBad.transfer(caller, amount);

        vm.prank(caller);
        paymentTokenBad.approve(address(talentCommunitySaleBad), amount);

        vm.prank(caller);
        try talentCommunitySaleBad.buyTier4() {}
        catch (bytes memory err) {
            assertEq(bytes4(err), TalentCommunitySale.ReentrancyGuardReentrantCall.selector);
        }
    }

    function test_BuyTier4_ReceivingWalletGetsTheAmountFromBuyer() public {
        // SETUP phase
        // -----------
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 1000 * 10 ** tokenDecimals;

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);
        //--------------------------------------------------------

        paymentToken.transfer(caller, amount);

        uint256 receivingWalletBalanceBefore = paymentToken.balanceOf(receivingWallet);
        uint256 buyerBalanceBefore = paymentToken.balanceOf(caller);

        // now that requirements are met, we fire test method
        // FIRE phase

        vm.prank(caller);
        talentCommunitySale.buyTier4();

        // TEST phase
        uint256 receiveWalletBalanceAfter = paymentToken.balanceOf(receivingWallet);

        assertEq(receiveWalletBalanceAfter, receivingWalletBalanceBefore + amount);

        uint256 buyerBalanceAfter = paymentToken.balanceOf(caller);

        assertEq(buyerBalanceAfter, buyerBalanceBefore - amount);
    }

    function test_BuyTier4_Tier4BoughtIsIncrementedByOne() public {
        talentCommunitySale.enableSale();

        uint32 tier4BoughtBefore = talentCommunitySale.tier4Bought();

        address caller = address(12347);

        uint256 amount = 1000 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.prank(caller);
        talentCommunitySale.buyTier4();

        uint32 tier4BoughtAfter = talentCommunitySale.tier4Bought();

        assertEq(tier4BoughtAfter, tier4BoughtBefore + 1);
    }

    function test_BuyTier4_AddsBuyerToListOfBuyers() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 1000 * 10 ** tokenDecimals;
        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        // before buying, we make sure caller is not in the list
        // of buyers
        assertEq(talentCommunitySale.listOfBuyers(caller), false);

        vm.prank(caller);
        talentCommunitySale.buyTier4();

        assertEq(talentCommunitySale.listOfBuyers(caller), true);
    }

    function test_BuyTier4_BuyingTier4IncreasesTotalRaisedBy1000() public {
        talentCommunitySale.enableSale();

        uint256 totalRaisedBefore = talentCommunitySale.totalRaised();

        address caller = address(12347);

        uint256 amount = 1000 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.prank(caller);
        talentCommunitySale.buyTier4();

        uint256 totalRaisedAfter = talentCommunitySale.totalRaised();

        assertEq(totalRaisedAfter, totalRaisedBefore + (1000 * 10 ** tokenDecimals));
    }

    function test_BuyTier4_EmitsTier4Bought() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 1000 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.prank(caller);
        vm.expectEmit(true, false, false, true);
        emit Tier4Bought(caller, amount);

        talentCommunitySale.buyTier4();
    }
}
