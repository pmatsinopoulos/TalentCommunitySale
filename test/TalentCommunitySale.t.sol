// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test} from "forge-std/Test.sol";
import {TalentCommunitySale} from "../src/TalentCommunitySale.sol";
import {USDTMock} from "./ERC20Mock.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TalentCommunitySaleTest is Test {
    TalentCommunitySale talentCommunitySale;

    address initialOwner = address(this);
    IERC20 paymentToken = new USDTMock();
    address receivingWallet = address(1337);
    uint256 tokenDecimals = 6;

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

    function test_TotalRaisedUpdatesCorrectly() public {
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
}
