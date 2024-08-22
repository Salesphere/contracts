// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MultiUserAirdropWithPercentageFee is Ownable {
    uint256 public percentageFee = 100; // Initial percentage fee in basis points (1% = 100)

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
     * @dev Distributes tokens to multiple addresses with a percentage fee.
     * Users must approve this contract to spend their tokens beforehand.
     * @param token The address of the ERC-20 token to distribute.
     * @param recipients An array of recipient addresses.
     * @param amounts An array of token amounts to distribute to each recipient.
     */
    function distributeTokens(address token, address[] calldata recipients, uint256[] calldata amounts) external {
        require(recipients.length == amounts.length, "Recipients and amounts length mismatch");
        require(recipients.length > 0, "Recipients array is empty");
        IERC20 tokenContract = IERC20(token);

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Recipient address cannot be zero address");

            // Calculate the fee in tokens
            uint256 fee = (amounts[i] * percentageFee) / 10000; // 10000 basis points = 100%
            uint256 netAmount = amounts[i] - fee;

            // Transfer fee to the contract owner
            require(tokenContract.transferFrom(msg.sender, owner(), fee), "Fee transfer failed");

            // Transfer the net amount to the recipient
            require(tokenContract.transferFrom(msg.sender, recipients[i], netAmount), "Token transfer failed");

            emit AirdropExecuted(msg.sender, token, recipients[i], netAmount);
        }
    }
}
