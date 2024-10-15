// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract TokenFactory {
    address[] public deployedTokens;

    event TokenCreated(address tokenAddress);

    function createToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) public {
        ERC20PresetMinterPauser newToken = new ERC20PresetMinterPauser(name, symbol);
        newToken.mint(msg.sender, initialSupply * 10 ** newToken.decimals());

        deployedTokens.push(address(newToken));
        emit TokenCreated(address(newToken));
    }

    function getDeployedTokens() public view returns (address[] memory) {
        return deployedTokens;
    }
}
