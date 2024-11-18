// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TalentCommunitySale {
    uint256 private tokenDecimals;
    uint256 public totalRaised;
    mapping(address => bool) public listOfBuyers;

    address public owner;
    IERC20 public paymentToken;
    address public receivingWallet;

    uint32 public constant TIER1_MAX_BUYS = 100;
    uint32 public constant TIER2_MAX_BUYS = 580;
    uint32 public constant TIER3_MAX_BUYS = 1250;
    uint32 public constant TIER4_MAX_BUYS = 520;

    uint256 public immutable TIER1_AMOUNT;
    uint256 public immutable TIER2_AMOUNT;
    uint256 public immutable TIER3_AMOUNT;
    uint256 public immutable TIER4_AMOUNT;

    uint32 public tier1Bought;
    uint32 public tier2Bought;
    uint32 public tier3Bought;
    uint32 public tier4Bought;

    bool public saleActive;

    uint8 private constant NOT_ENTERED = 1;
    uint8 private constant ENTERED = 2;

    uint8 private _status;

    event Tier1Bought(address indexed buyer, uint256 amount);
    event Tier2Bought(address indexed buyer, uint256 amount);
    event Tier3Bought(address indexed buyer, uint256 amount);
    event Tier4Bought(address indexed buyer, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    error SaleIsNotActive();
    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);
    error ReentrancyGuardReentrantCall();
    error Tier1SoldOut();
    error Tier2SoldOut();
    error Tier3SoldOut();
    error Tier4SoldOut();
    error AddressAlreadyBought(address buyer);

    constructor(address initialOwner, address _paymentToken, address _receivingWallet, uint256 _tokenDecimals) {
        owner = initialOwner;
        paymentToken = IERC20(_paymentToken);
        receivingWallet = _receivingWallet;
        tokenDecimals = _tokenDecimals;
        totalRaised = 0;
        saleActive = false;
        _status = NOT_ENTERED;

        uint256 decimalsTenths = 10 ** tokenDecimals;

        TIER1_AMOUNT = 100 * decimalsTenths;
        TIER2_AMOUNT = 250 * decimalsTenths;
        TIER3_AMOUNT = 500 * decimalsTenths;
        TIER4_AMOUNT = 1000 * decimalsTenths;
    }

    function enableSale() external {
        onlyOwner();
        assembly {
            let slot6 := sload(6)
            let offsetBits := mul(4, 8)
            let zeroMask := not(shl(offsetBits, 0xFF)) // 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFF
            let setMask := shl(offsetBits, 0x01) // 0x0000000000000000000000000000000000000000000000000000000100000000
            sstore(6, or(and(slot6, zeroMask), setMask))
        }
    }

    function disableSale() external {
        onlyOwner();
        assembly {
            let slot6 := sload(6)
            let offsetBits := mul(4, 8)
            let zeroMask := not(shl(offsetBits, 0xFF)) // 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFF
            let setMask := 0x00 // 0x0000000000000000000000000000000000000000000000000000000000000000
            sstore(6, or(and(slot6, zeroMask), setMask))
        }
    }

    // ---------
    // Ownership
    // ---------
    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() external {
        onlyOwner();
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external {
        onlyOwner();
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }
    // ------------------------------------------------

    function buyTier1() external {
        // "Tier1Bought(address,uint256)": "0xd0ec74678527414a67543ab9b58cade4fbf20e05b82789647832b15ac4fb2997"
        // "Tier1SoldOut()": "1c2ec185",
        buyTierX(
            5,
            20,
            TIER1_MAX_BUYS,
            TIER1_AMOUNT,
            0xd0ec74678527414a67543ab9b58cade4fbf20e05b82789647832b15ac4fb2997,
            0x1c2ec185
        );
    }

    function buyTier2() external {
        // "Tier2Bought(address,uint256)": "0x9adc2453231d9e55fe52222bb5166bb8e4e4a5deb9ad19ca1c30f7d247deb880"
        // "Tier2SoldOut()": "3a7f8bbe",
        buyTierX(
            5,
            24,
            TIER2_MAX_BUYS,
            TIER2_AMOUNT,
            0x9adc2453231d9e55fe52222bb5166bb8e4e4a5deb9ad19ca1c30f7d247deb880,
            0x3a7f8bbe
        );
    }

    function buyTier3() external {
        // "Tier3Bought(address,uint256)": "0x9e23d4a7f5fc8f2dedbd7bdee234e901efa73d99951af297a1f72f9eee5078cb"
        // "Tier3SoldOut()": "3a7f8bbe",
        buyTierX(
            5,
            28,
            TIER3_MAX_BUYS,
            TIER3_AMOUNT,
            0x9e23d4a7f5fc8f2dedbd7bdee234e901efa73d99951af297a1f72f9eee5078cb,
            0xf46219ea
        );
    }

    function buyTier4() external {
        // "Tier4Bought(address,uint256)": "0x5f426b0d5c5130a87e887be8c0965f389528c60f814e98bb1fa671915770151a"
        // "Tier4SoldOut()": "362f206a",
        buyTierX(
            6,
            0,
            TIER4_MAX_BUYS,
            TIER4_AMOUNT,
            0x5f426b0d5c5130a87e887be8c0965f389528c60f814e98bb1fa671915770151a,
            0x362f206a
        );
    }

    function onlyOwner() internal view {
        assembly {
            let storedOwner := sload(3)

            if iszero(eq(caller(), storedOwner)) {
                let freeMemoryPointer := mload(0x40)
                let initialFreeMemoryPointer := freeMemoryPointer

                mstore(freeMemoryPointer, shl(mul(28, 8), 0x118cdaa7))
                freeMemoryPointer := add(freeMemoryPointer, 4)

                mstore(freeMemoryPointer, caller())

                freeMemoryPointer := add(freeMemoryPointer, 32)
                mstore(0x40, freeMemoryPointer)

                revert(initialFreeMemoryPointer, 36)
            }
        }
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal {
        assembly {
            let oldOwner := sload(3)

            sstore(3, newOwner)
            // 0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0
            // it is taken from forge inspect --pretty TalentCommunitySale events
            log3(0x00, 0x00, 0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0, oldOwner, newOwner)
        }
    }

    function _nonReentrantBefore() private {
        assembly {
            let slot6 := sload(6)
            let offsetBits := mul(5, 8)
            let entered := shl(offsetBits, 0x02) // 0x0000000000000000000000000000000000000000000000000000020000000000 // ENTERED

            if eq(and(slot6, entered), entered) {
                let freePointer := mload(0x40)
                let initialFreePointer := freePointer

                mstore(freePointer, shl(mul(28, 8), 0x3ee5aeb5)) //0x3ee5aeb500000000000000000000000000000000000000000000000000000000) // ReentrancyGuardReentrantCall()
                freePointer := add(freePointer, 32)
                mstore(0x40, freePointer)

                revert(initialFreePointer, 32)
            }

            let zeroMask := not(shl(offsetBits, 0xFF)) // 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFF
            sstore(6, or(and(slot6, zeroMask), entered))
        }
    }

    function _nonReentrantAfter() private {
        assembly {
            let slot6 := sload(6)
            let offsetBits := mul(5, 8)
            let notEntered := shl(offsetBits, 0x01) // 0x0000000000000000000000000000000000000000000000000000010000000000 // NOT_ENTERED

            let setToZeroMask := not(shl(offsetBits, 0xFF)) // 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFF

            sstore(6, or(and(slot6, setToZeroMask), notEntered))
        }
    }

    function buyTierX(
        uint8 tierSlot,
        uint8 tierOffset,
        uint256 maxBuys,
        uint256 tierAmount,
        uint256 boughtEvent,
        uint32 tierSoldOutError
    ) private {
        _nonReentrantBefore();

        assembly {
            // check for sale being active
            let saleActiveSlot := sload(6)
            let offsetBits := mul(4, 8) // offset 4, 8 bits per byte
            let isSaleActive := shr(offsetBits, and(saleActiveSlot, shl(offsetBits, 0xFF)))

            if iszero(isSaleActive) {
                let freeMemoryPointer := mload(0x40)
                let initialFreeMemoryPointer := freeMemoryPointer
                mstore(freeMemoryPointer, shl(mul(28, 8), 0x00ecac01)) // SaleIsNotActive()

                freeMemoryPointer := add(freeMemoryPointer, 4)
                mstore(0x40, freeMemoryPointer)

                revert(initialFreeMemoryPointer, 4)
            }

            // check that number of buys are less than maximum

            let tierSlotValue := sload(tierSlot)

            offsetBits := mul(tierOffset, 8)
            let fourBytesMask := 0xFFFFFFFF

            let tierBought := and(shr(offsetBits, tierSlotValue), fourBytesMask)

            if gt(tierBought, sub(maxBuys, 1)) {
                let freeMemoryPointer := mload(0x40)
                let initialFreeMemoryPointer := freeMemoryPointer

                mstore(freeMemoryPointer, shl(mul(28, 8), tierSoldOutError)) // Tier1SoldOut()

                freeMemoryPointer := add(freeMemoryPointer, 4)
                mstore(0x40, freeMemoryPointer)

                revert(initialFreeMemoryPointer, 4)
            }

            // check that buyer has not bought again

            let buyerAddress := caller()
            let freeMemoryPointer := mload(0x40)
            let initialFreeMemoryPointer := freeMemoryPointer

            mstore(freeMemoryPointer, buyerAddress) // 32 bytes
            freeMemoryPointer := add(freeMemoryPointer, 32)

            mstore(freeMemoryPointer, 2) // slot of mapping for listOfBuyers
            freeMemoryPointer := add(freeMemoryPointer, 32)
            mstore(0x40, freeMemoryPointer)

            let listOfBuyersSlotForBuyer := keccak256(initialFreeMemoryPointer, 64)

            if sload(listOfBuyersSlotForBuyer) {
                initialFreeMemoryPointer := freeMemoryPointer
                mstore(freeMemoryPointer, shl(mul(28, 8), 0x784dcf7a)) // Store the error selector for "AddressAlreadyBought(address)"
                freeMemoryPointer := add(freeMemoryPointer, 4)

                mstore(freeMemoryPointer, buyerAddress) // 32 bytes
                freeMemoryPointer := add(freeMemoryPointer, 32)
                mstore(0x40, freeMemoryPointer)

                revert(initialFreeMemoryPointer, 36)
            }
        }

        paymentToken.transferFrom(msg.sender, receivingWallet, tierAmount);

        assembly {
            // increase tierBought by 1
            let tierSlotValue := sload(tierSlot)

            let offsetBits := mul(tierOffset, 8)
            let fourBytesMask := 0xFFFFFFFF

            let tierBought := and(shr(offsetBits, tierSlotValue), fourBytesMask)

            tierBought := add(tierBought, 1)

            // store the +tierBought+ back into the correct Slot and Offset
            sstore(tierSlot, or(and(tierSlotValue, not(shl(offsetBits, fourBytesMask))), shl(offsetBits, tierBought)))

            // flag the buyer as having bought

            // TODO: finding the slot number of the buyer can be a function.

            let buyerAddress := caller()
            let freeMemoryPointer := mload(0x40)
            let initialFreeMemoryPointer := freeMemoryPointer

            mstore(freeMemoryPointer, buyerAddress) // 32 bytes
            freeMemoryPointer := add(freeMemoryPointer, 32)

            mstore(freeMemoryPointer, 2) // slot of mapping for listOfBuyers
            freeMemoryPointer := add(freeMemoryPointer, 32)
            mstore(0x40, freeMemoryPointer)

            let listOfBuyersSlotForBuyer := keccak256(initialFreeMemoryPointer, 64)

            sstore(listOfBuyersSlotForBuyer, 1)

            // increate totalRaised by tierAmount

            let totalRaisedSlotValue := sload(1) // read the totalRaised value
            totalRaisedSlotValue := add(totalRaisedSlotValue, tierAmount)
            sstore(1, totalRaisedSlotValue)

            // emit Tier4Bought(msg.sender, tierAmount);
            initialFreeMemoryPointer := freeMemoryPointer
            mstore(freeMemoryPointer, tierAmount)

            freeMemoryPointer := add(freeMemoryPointer, 32)
            mstore(0x40, freeMemoryPointer)

            log2(initialFreeMemoryPointer, 32, boughtEvent, caller())
        }

        _nonReentrantAfter();
    }
}
