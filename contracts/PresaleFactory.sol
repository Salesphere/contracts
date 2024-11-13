// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Presale.sol";

contract PresaleFactory {
    struct PresaleInfo {
        address presaleAddress;
        address creator;
        uint256 hardCap;
    }

    PresaleInfo[] public presales;

    mapping(address => uint256) public presaleCountByCreator;

    event PresaleCreated(
        address indexed creator,
        address presaleAddress,
        uint256 hardCap
    );

    function createPresale(
        address _token,
        uint256 _presalePrice,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _hardCap,
        uint256[] memory _vestingPercentages,
        uint256[] memory _vestingReleaseTimes
    ) external returns (address) {
        TokenPresaleWithVesting newPresale = new TokenPresaleWithVesting(
            _token,
            _presalePrice,
            _minPurchase,
            _maxPurchase,
            _startTime,
            _endTime,
            _hardCap,
            _vestingPercentages,
            _vestingReleaseTimes
        );
        newPresale.transferOwnership(msg.sender);
        presales.push(
            PresaleInfo({
                presaleAddress: address(newPresale),
                creator: msg.sender,
                hardCap: _hardCap
            })
        );
        presaleCountByCreator[msg.sender] += 1;
        emit PresaleCreated(msg.sender, address(newPresale), _hardCap);
        return address(newPresale);
    }

    function getTotalPresales() external view returns (uint256) {
        return presales.length;
    }

    function getPresaleInfo(
        uint256 _index
    ) external view returns (address, address, uint256) {
        require(_index < presales.length, "Invalid index");
        PresaleInfo storage presale = presales[_index];
        return (presale.presaleAddress, presale.creator, presale.hardCap);
    }

    function getPresalesByCreator(
        address _creator
    ) external view returns (PresaleInfo[] memory) {
        uint256 count = presaleCountByCreator[_creator];
        PresaleInfo[] memory creatorPresales = new PresaleInfo[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < presales.length; i++) {
            if (presales[i].creator == _creator) {
                creatorPresales[index] = presales[i];
                index++;
            }
        }
        return creatorPresales;
    }
}