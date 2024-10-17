// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract TokenFactory {
    address[] public deployedTokens;

    mapping(address => address[]) public userTokens;

    event TokenCreated(address tokenAddress, address creator);

    function createToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) public {
        ERC20PresetMinterPauser newToken = new ERC20PresetMinterPauser(
            name,
            symbol
        );
        newToken.mint(msg.sender, initialSupply * 10 ** newToken.decimals());
        deployedTokens.push(address(newToken));
        userTokens[msg.sender].push(address(newToken));
        emit TokenCreated(address(newToken), msg.sender);
    }

    function getDeployedTokens() public view returns (address[] memory) {
        return deployedTokens;
    }

    function getUserTokens(
        address user
    ) public view returns (address[] memory) {
        return userTokens[user];
    }
}
