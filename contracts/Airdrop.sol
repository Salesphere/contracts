// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MultiUserAirdropWithPercentageFee is Ownable {
    uint256 public percentageFee = 100; // Initial percentage fee in basis points (1% = 100)

    mapping(address => uint256) public airdropCounts;

    event AirdropExecuted(address indexed distributor, address indexed token, address indexed recipient, uint256 amount);
    event FeeCollected(address indexed from, uint256 feeAmount);
    event PercentageFeeUpdated(uint256 newPercentageFee);

    /**
     * @dev Set a new percentage fee.
     * @param _percentageFee The new percentage fee in basis points (1% = 100 basis points).
     */
    function setPercentageFee(uint256 _percentageFee) external onlyOwner {
        require(_percentageFee <= 1000, "Fee cannot exceed 10%"); // For security, cap the fee at 10%
        percentageFee = _percentageFee;
        emit PercentageFeeUpdated(_percentageFee);
    }

    /**
     * @dev Distributes tokens to multiple addresses with a percentage fee added on top.
     * Users must approve this contract to spend their tokens beforehand.
     * @param token The address of the ERC-20 token to distribute.
     * @param recipients An array of recipient addresses.
     * @param amounts An array of token amounts to distribute to each recipient.
     */
    function distributeTokens(address token, address[] calldata recipients, uint256[] calldata amounts) external {
        require(recipients.length == amounts.length, "Recipients and amounts length mismatch");
        require(recipients.length > 0, "Recipients array is empty");

        IERC20 tokenContract = IERC20(token);
        uint256 totalAmount = 0;
        uint256 totalFee = 0;

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Recipient address cannot be zero address");

            // Calculate the fee in tokens
            uint256 fee = (amounts[i] * percentageFee) / 10000; // 10000 basis points = 100%
            totalFee += fee;
            totalAmount += amounts[i] + fee;

            // Transfer the full amount to the recipient
            require(tokenContract.transferFrom(msg.sender, recipients[i], amounts[i]), "Token transfer failed");

            emit AirdropExecuted(msg.sender, token, recipients[i], amounts[i]);
        }

        // Transfer the total fee to the contract owner
        require(tokenContract.transferFrom(msg.sender, owner(), totalFee), "Fee transfer failed");
        emit FeeCollected(msg.sender, totalFee);

        // Increment the airdrop count for the sender
        airdropCounts[msg.sender]++;
    }

    /**
     * @dev Distributes a single amount of tokens to multiple addresses with a percentage fee added on top.
     * Users must approve this contract to spend their tokens beforehand.
     * @param token The address of the ERC-20 token to distribute.
     * @param recipients An array of recipient addresses.
     * @param amount The token amount to distribute to each recipient.
     */
    function distributeSingleAmount(address token, address[] calldata recipients, uint256 amount) external {
        require(recipients.length > 0, "Recipients array is empty");

        IERC20 tokenContract = IERC20(token);
        uint256 totalFee = 0;
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Recipient address cannot be zero address");

            // Calculate the fee in tokens
            uint256 fee = (amount * percentageFee) / 10000; // 10000 basis points = 100%
            totalFee += fee;
            totalAmount += amount + fee;

            // Transfer the full amount to the recipient
            require(tokenContract.transferFrom(msg.sender, recipients[i], amount), "Token transfer failed");

            emit AirdropExecuted(msg.sender, token, recipients[i], amount);
        }

        // Transfer the total fee to the contract owner
        require(tokenContract.transferFrom(msg.sender, owner(), totalFee), "Fee transfer failed");
        emit FeeCollected(msg.sender, totalFee);

        // Increment the airdrop count for the sender
        airdropCounts[msg.sender]++;
    }

    /**
     * @dev Returns the total fee and total amount of tokens required for the `distributeTokens` function.
     * @param amounts An array of token amounts to distribute to each recipient.
     */
    function calculateDistributeTokensFees(uint256[] calldata amounts) external view returns (uint256 totalFee, uint256 totalAmount) {
        totalFee = 0;
        totalAmount = 0;

        for (uint256 i = 0; i < amounts.length; i++) {
            uint256 fee = (amounts[i] * percentageFee) / 10000;
            totalFee += fee;
            totalAmount += amounts[i] + fee;
        }
    }

    /**
     * @dev Returns the total fee and total amount of tokens required for the `distributeSingleAmount` function.
     * @param recipients An array of recipient addresses.
     * @param amount The token amount to distribute to each recipient.
     */
    function calculateDistributeSingleAmountFees(address[] calldata recipients, uint256 amount) external view returns (uint256 totalFee, uint256 totalAmount) {
        totalFee = 0;
        totalAmount = 0;

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 fee = (amount * percentageFee) / 10000;
            totalFee += fee;
            totalAmount += amount + fee;
        }
    }
}
