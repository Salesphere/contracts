// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function decimals() external view returns (uint8);
}

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target; // Target amount in USD
        uint256 deadline;
        uint256 amountCollected; // In USD
        string image;
        address[] donators;
        uint256[] donations; // In USD
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public numberOfCampaigns = 0;

    IERC20 internal usdcToken;
    IERC20 internal usdtToken;

    constructor(address _usdcToken, address _usdtToken) {
        usdcToken = IERC20(_usdcToken);
        usdtToken = IERC20(_usdtToken);
    }

    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image
    ) public returns (uint256) {
        require(
            _deadline > block.timestamp,
            "The deadline should be a date in the future."
        );

        Campaign storage campaign = campaigns[numberOfCampaigns];

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    function donateWithETH(
        uint256 _id,
        uint256 _convertedUSDValue
    ) public payable {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp < campaign.deadline, "The campaign has ended.");

        campaign.donators.push(msg.sender);
        campaign.donations.push(_convertedUSDValue);
        campaign.amountCollected += _convertedUSDValue;

        (bool sent, ) = payable(campaign.owner).call{value: msg.value}("");
        require(sent, "Failed to send ETH to campaign owner.");
    }

    function donateWithStablecoin(
        uint256 _id,
        uint256 _amount,
        address _token
    ) public {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp < campaign.deadline, "The campaign has ended.");

        require(
            _token == address(usdcToken) || _token == address(usdtToken),
            "Unsupported stablecoin."
        );

        IERC20 token = IERC20(_token);

        uint8 decimals = token.decimals();
        uint256 adjustedAmount = _amount * (10 ** (18 - decimals)); // Adjust to 18 decimals for consistency

        require(
            token.transferFrom(msg.sender, campaign.owner, _amount),
            "Transfer failed."
        );

        campaign.donators.push(msg.sender);
        campaign.donations.push(adjustedAmount);
        campaign.amountCollected += adjustedAmount;
    }

    function getDonators(
        uint256 _id
    ) public view returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;
        }

        return allCampaigns;
    }
}
