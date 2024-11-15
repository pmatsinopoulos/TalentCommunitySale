// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {TalentCommunitySale} from "../src/TalentCommunitySale.sol";
import {USDTMock} from "./ERC20Mock.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TalentCommunitySaleTest is Test {
    TalentCommunitySale talentCommunitySale;

    address initialOwner = address(this);
    IERC20 paymentToken = new USDTMock();
    address receivingWallet = address(1337);
    uint256 tokenDecimals = 6;

    event Tier1Bought(address indexed buyer, uint256 amount);

    error ERC20InsufficientBalance(address from, uint256 balance, uint256 required);

    function setUp() public {
        talentCommunitySale =
            new TalentCommunitySale(initialOwner, address(paymentToken), receivingWallet, tokenDecimals);
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

    function test_DisableSale() public {
        talentCommunitySale.enableSale();

        assertEq(talentCommunitySale.saleActive(), true);

        talentCommunitySale.disableSale();

        assertEq(talentCommunitySale.saleActive(), false);
    }

    // -----------------------------------------------
    // buyTier1() ------------------------------------

    function test_BuyTier1_whenSaleIsNotActiveItReverts() public {
        talentCommunitySale.disableSale();

        vm.expectRevert("TalentCommunitySale: Sale is not active");

        talentCommunitySale.buyTier1();
    }

    function test_BuyTier1_WhenCallerHasNotAllowedContractToSpendMoney_ItReverts() public {
        talentCommunitySale.enableSale();

        vm.expectRevert("TalentCommunitySale: Insufficient allowance");

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
                vm.expectRevert("TalentCommunitySale: Tier 1 sold out");
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
                vm.expectRevert("TalentCommunitySale: Address already bought");
            }
            vm.prank(caller);
            talentCommunitySale.buyTier1();
        }
    }

    function test_BuyTier1_WhenCallerDoesNotHaveEnoughBalance_ItReverts() public {
        talentCommunitySale.enableSale();

        address caller = address(12347);

        uint256 amount = 100 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount - 1);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.expectRevert(abi.encodeWithSelector(ERC20InsufficientBalance.selector, caller, amount - 1, amount));
        vm.prank(caller);

        talentCommunitySale.buyTier1();
    }

    function test_BuyTier1_Tier1BoughtIsIncrementedByOne() public {
        talentCommunitySale.enableSale();

        uint32 tier1BoughtBefore = talentCommunitySale.tier1Bought();

        address caller = address(12347);

        uint256 amount = 100 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.prank(caller);
        talentCommunitySale.buyTier1();

        uint32 tier1BoughtAfter = talentCommunitySale.tier1Bought();

        assertEq(tier1BoughtAfter, tier1BoughtBefore + 1);
    }

    function test_BuyTier1_Tier1BoughtAddsBuyerToListOfBuyers() public {
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

    function test_BuyTier1_BuyingTier1IncreasesTotalRaisedBy100() public {
        talentCommunitySale.enableSale();

        uint256 totalRaisedBefore = talentCommunitySale.totalRaised();

        address caller = address(12347);

        uint256 amount = 100 * 10 ** tokenDecimals;

        paymentToken.transfer(caller, amount);

        vm.prank(caller);
        paymentToken.approve(address(talentCommunitySale), amount);

        vm.prank(caller);
        talentCommunitySale.buyTier1();

        uint256 totalRaisedAfter = talentCommunitySale.totalRaised();

        assertEq(totalRaisedAfter, totalRaisedBefore + (100 * 10 ** tokenDecimals));
    }

    function test_BuyTier1_BuyingTier1EmitsTier1Bought() public {
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

    // end of buyTier1() --------------------------------------
    // --------------------------------------------------------

    // -----------------------------------------------
    // buyTier2() ------------------------------------

    // ..... TODO .....
}
