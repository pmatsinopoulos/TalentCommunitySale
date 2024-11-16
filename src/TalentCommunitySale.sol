// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TalentCommunitySale is ReentrancyGuard {
    using Math for uint256;

    address public owner;
    IERC20 public paymentToken;
    uint256 private tokenDecimals;
    address public receivingWallet;

    uint32 public constant TIER1_MAX_BUYS = 100;
    uint32 public constant TIER2_MAX_BUYS = 580;
    uint32 public constant TIER3_MAX_BUYS = 1250;
    uint32 public constant TIER4_MAX_BUYS = 520;

    uint32 public tier1Bought;
    uint32 public tier2Bought;
    uint32 public tier3Bought;
    uint32 public tier4Bought;

    uint256 public totalRaised;

    bool public saleActive;

    event Tier1Bought(address indexed buyer, uint256 amount);
    event Tier2Bought(address indexed buyer, uint256 amount);
    event Tier3Bought(address indexed buyer, uint256 amount);
    event Tier4Bought(address indexed buyer, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    mapping(address => bool) public listOfBuyers;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    constructor(address initialOwner, address _paymentToken, address _receivingWallet, uint256 _tokenDecimals)
    {
        owner = initialOwner;
        paymentToken = IERC20(_paymentToken);
        receivingWallet = _receivingWallet;
        tokenDecimals = _tokenDecimals;
        totalRaised = 0;
        saleActive = false;
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
    function renounceOwnership() public {
        onlyOwner();
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public {
        onlyOwner();
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }
    // ------------------------------------------------

    function buyTier1() external nonReentrant {
        require(saleActive, "TalentCommunitySale: Sale is not active");
        require(
            paymentToken.allowance(msg.sender, address(this)) >= 100 * 10 ** tokenDecimals,
            "TalentCommunitySale: Insufficient allowance"
        );
        require(tier1Bought < TIER1_MAX_BUYS, "TalentCommunitySale: Tier 1 sold out");
        require(!listOfBuyers[msg.sender], "TalentCommunitySale: Address already bought");
        require(paymentToken.transferFrom(msg.sender, receivingWallet, 100 * 10 ** tokenDecimals), "Transfer failed");

        tier1Bought++;
        listOfBuyers[msg.sender] = true;
        totalRaised += 100 * 10 ** tokenDecimals;
        emit Tier1Bought(msg.sender, 100 * 10 ** tokenDecimals);
    }

    function buyTier2() external nonReentrant {
        require(saleActive, "TalentCommunitySale: Sale is not active");
        require(
            paymentToken.allowance(msg.sender, address(this)) >= 250 * 10 ** tokenDecimals,
            "TalentCommunitySale: Insufficient allowance"
        );
        require(tier2Bought < TIER2_MAX_BUYS, "TalentCommunitySale: Tier 2 sold out");
        require(!listOfBuyers[msg.sender], "TalentCommunitySale: Address already bought");
        require(paymentToken.transferFrom(msg.sender, receivingWallet, 250 * 10 ** tokenDecimals), "Transfer failed");

        tier2Bought++;
        listOfBuyers[msg.sender] = true;
        totalRaised += 250 * 10 ** tokenDecimals;
        emit Tier2Bought(msg.sender, 250 * 10 ** tokenDecimals);
    }

    function buyTier3() external nonReentrant {
        require(saleActive, "TalentCommunitySale: Sale is not active");
        require(
            paymentToken.allowance(msg.sender, address(this)) >= 500 * 10 ** tokenDecimals,
            "TalentCommunitySale: Insufficient allowance"
        );
        require(tier3Bought < TIER3_MAX_BUYS, "TalentCommunitySale: Tier 3 sold out");
        require(!listOfBuyers[msg.sender], "TalentCommunitySale: Address already bought");
        require(paymentToken.transferFrom(msg.sender, receivingWallet, 500 * 10 ** tokenDecimals), "Transfer failed");

        tier3Bought++;
        listOfBuyers[msg.sender] = true;
        totalRaised += 500 * 10 ** tokenDecimals;
        emit Tier3Bought(msg.sender, 500 * 10 ** tokenDecimals);
    }

    function buyTier4() external nonReentrant {
        require(saleActive, "TalentCommunitySale: Sale is not active");
        require(
            paymentToken.allowance(msg.sender, address(this)) >= 1000 * 10 ** tokenDecimals,
            "TalentCommunitySale: Insufficient allowance"
        );
        require(tier4Bought < TIER4_MAX_BUYS, "TalentCommunitySale: Tier 4 sold out");
        require(!listOfBuyers[msg.sender], "TalentCommunitySale: Address already bought");
        require(paymentToken.transferFrom(msg.sender, receivingWallet, 1000 * 10 ** tokenDecimals), "Transfer failed");

        tier4Bought++;
        listOfBuyers[msg.sender] = true;
        totalRaised += 1000 * 10 ** tokenDecimals;
        emit Tier4Bought(msg.sender, 1000 * 10 ** tokenDecimals);
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
}
