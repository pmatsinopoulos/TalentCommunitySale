// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract ERC20Mock is ERC20, ERC165 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 ether);
    }

    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return interfaceId == type(ERC165).interfaceId || interfaceId == type(IERC20).interfaceId;
    }
}

contract ERC20MockWithoutErc165 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 ether);
    }
}

contract USDTMockBad is ERC20 {
    using Address for address;

    constructor() ERC20("USDT", "USDT") {
        _mint(msg.sender, 1000000 ether);
    }

    function decimals() public pure override(ERC20) returns (uint8) {
        return 6;
    }

    function transferFrom(address, address, uint256) public override returns (bool) {
        msg.sender.functionCall(abi.encodeWithSignature("buyTier1()"));

        return true;
    }
}
