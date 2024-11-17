// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TalentCommunitySale {
    address public owner;
    IERC20 public paymentToken;
    uint256 private tokenDecimals;
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

    uint256 public totalRaised;

    bool public saleActive;

    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    event Tier1Bought(address indexed buyer, uint256 amount);
    event Tier2Bought(address indexed buyer, uint256 amount);
    event Tier3Bought(address indexed buyer, uint256 amount);
    event Tier4Bought(address indexed buyer, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    mapping(address => bool) public listOfBuyers;

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
        saleActive = true;
    }

    function disableSale() external {
        onlyOwner();
        saleActive = false;
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
        _nonReentrantBefore();

        if (!saleActive) {
            revert SaleIsNotActive();
        }

        if (tier1Bought >= TIER1_MAX_BUYS) {
            revert Tier1SoldOut();
        }

        if (listOfBuyers[msg.sender]) {
            revert AddressAlreadyBought(msg.sender);
        }

        paymentToken.transferFrom(msg.sender, receivingWallet, TIER1_AMOUNT);

        tier1Bought++;
        listOfBuyers[msg.sender] = true;
        totalRaised += TIER1_AMOUNT;
        emit Tier1Bought(msg.sender, TIER1_AMOUNT);

        _nonReentrantAfter();
    }

    function buyTier2() external {
        _nonReentrantBefore();

        if (!saleActive) {
            revert SaleIsNotActive();
        }

        if (tier2Bought >= TIER2_MAX_BUYS) {
            revert Tier2SoldOut();
        }

        if (listOfBuyers[msg.sender]) {
            revert AddressAlreadyBought(msg.sender);
        }

        paymentToken.transferFrom(msg.sender, receivingWallet, TIER2_AMOUNT);

        tier2Bought++;
        listOfBuyers[msg.sender] = true;
        totalRaised += TIER2_AMOUNT;
        emit Tier2Bought(msg.sender, TIER2_AMOUNT);

        _nonReentrantAfter();
    }

    function buyTier3() external {
        _nonReentrantBefore();

        if (!saleActive) {
            revert SaleIsNotActive();
        }

        if (tier3Bought >= TIER3_MAX_BUYS) {
            revert Tier3SoldOut();
        }

        if (listOfBuyers[msg.sender]) {
            revert AddressAlreadyBought(msg.sender);
        }

        paymentToken.transferFrom(msg.sender, receivingWallet, TIER3_AMOUNT);

        tier3Bought++;
        listOfBuyers[msg.sender] = true;
        totalRaised += TIER3_AMOUNT;
        emit Tier3Bought(msg.sender, TIER3_AMOUNT);

        _nonReentrantAfter();
    }

    function buyTier4() external {
        _nonReentrantBefore();

        if (!saleActive) {
            revert SaleIsNotActive();
        }

        if (tier4Bought >= TIER4_MAX_BUYS) {
            revert Tier4SoldOut();
        }

        if (listOfBuyers[msg.sender]) {
            revert AddressAlreadyBought(msg.sender);
        }

        paymentToken.transferFrom(msg.sender, receivingWallet, TIER4_AMOUNT);

        tier4Bought++;
        listOfBuyers[msg.sender] = true;
        totalRaised += TIER4_AMOUNT;
        emit Tier4Bought(msg.sender, TIER4_AMOUNT);

        _nonReentrantAfter();
    }

    function onlyOwner() internal view {
        if (msg.sender != owner) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }
}
