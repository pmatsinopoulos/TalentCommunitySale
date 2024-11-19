// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {TalentCommunitySale} from "../src/TalentCommunitySale.sol";
import {USDTMock} from "./ERC20Mock.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployUSDTMock is Script {
    function run() public {
        vm.startBroadcast();

        new USDTMock();

        vm.stopBroadcast();
    }
}

contract DeployTalentCommunitySale is Script {
    function setUp() public {}

    function run(address initialOwner, address _paymentToken, address _receivingWallet, uint256 _tokenDecimals)
        public
    {
        vm.startBroadcast();

        new TalentCommunitySale(initialOwner, _paymentToken, _receivingWallet, _tokenDecimals);

        vm.stopBroadcast();
    }

    function enableSale(address talentCommunitySaleAddress) public {
        vm.startBroadcast();

        TalentCommunitySale talentCommunitySale = TalentCommunitySale(talentCommunitySaleAddress);

        talentCommunitySale.enableSale();

        vm.stopBroadcast();
    }

    function approve(address talentCommunitySaleAddress, address paymentTokenAddress, uint256 amountWei) public {
      vm.startBroadcast();

      IERC20 paymentToken = IERC20(paymentTokenAddress);

      paymentToken.approve(talentCommunitySaleAddress, amountWei);

      vm.stopBroadcast();
    }

    function buyTier1(address talentCommunitySaleAddress) public {
      vm.startBroadcast();

      TalentCommunitySale talentCommunitySale = TalentCommunitySale(talentCommunitySaleAddress);

      talentCommunitySale.buyTier1();

      vm.stopBroadcast();
    }
}
