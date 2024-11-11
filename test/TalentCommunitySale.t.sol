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
    talentCommunitySale = new TalentCommunitySale(
      initialOwner,
      address(paymentToken),
      receivingWallet,
      tokenDecimals
    );
  }

  function test_ReceivingWalletReturnsTheWalletWeDeployedWith() public view {
    address result = talentCommunitySale.receivingWallet();

    assertEq(result, receivingWallet);
  }


  // contract DeployContract is Script {
  //   function run() external returns(SimpleStorage) {
  //       vm.startBroadcast();
  //       SimpleStorage simpleStorage = new SimpleStorage();
  //       vm.stopBroadcast();
  //       return simpleStorage;
  //   }
}
