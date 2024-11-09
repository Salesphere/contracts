// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenPresale is ReentrancyGuard, Ownable(msg.sender) {
    IERC20 public token;
    
    uint256 public presalePrice;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public presaleStartTime;
    uint256 public presaleEndTime;
    uint256 public hardCap;
    uint256 public totalTokensSold;
    
    mapping(address => uint256) public purchases;
    bool public presaleFinalized;
    
    event TokensPurchased(address buyer, uint256 amount, uint256 cost);
    event PresaleFinalized(uint256 totalSold);
    
    constructor(
        address _token,
        uint256 _presalePrice,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _hardCap
    ) {
        token = IERC20(_token);
        presalePrice = _presalePrice;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        presaleStartTime = _startTime;
        presaleEndTime = _endTime;
        hardCap = _hardCap;
    }
    
    function buyTokens() external payable nonReentrant {
        require(block.timestamp >= presaleStartTime, "Presale has not started");
        require(block.timestamp <= presaleEndTime, "Presale has ended");
        require(!presaleFinalized, "Presale is finalized");
        require(msg.value >= minPurchase, "Below minimum purchase");
        
        uint256 tokenAmount = (msg.value * presalePrice) / 1 ether;
        require(totalTokensSold + tokenAmount <= hardCap, "Exceeds hard cap");
        
        uint256 newPurchaseTotal = purchases[msg.sender] + tokenAmount;
        require(newPurchaseTotal <= maxPurchase, "Exceeds max purchase");
        
        purchases[msg.sender] = newPurchaseTotal;
        totalTokensSold += tokenAmount;
        
        emit TokensPurchased(msg.sender, tokenAmount, msg.value);
    }
    
    function claimTokens() external nonReentrant {
        require(presaleFinalized, "Presale not finalized");
        uint256 amount = purchases[msg.sender];
        require(amount > 0, "No tokens to claim");
        
        purchases[msg.sender] = 0;
        bool success = token.transfer(msg.sender, amount);
        require(success, "Transfer failed");
    }
    
    function finalizePresale() external onlyOwner {
        require(block.timestamp > presaleEndTime || totalTokensSold >= hardCap, 
                "Cannot finalize yet");
        require(!presaleFinalized, "Already finalized");
        
        presaleFinalized = true;
        emit PresaleFinalized(totalTokensSold);
        
        // Transfer collected ETH to owner
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "ETH transfer failed");
    }
    
    function withdrawUnsoldTokens() external onlyOwner {
        require(presaleFinalized, "Presale not finalized");
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner(), balance), "Transfer failed");
    }
}