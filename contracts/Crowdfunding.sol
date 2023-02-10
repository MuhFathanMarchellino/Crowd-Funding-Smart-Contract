// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract Crowdfund {
    address public fundraiser;
    uint public fundneeded;
    uint public fundraised;
    uint public deadline;
    bool ended;        
    string name;
    string condition;
    string description; 

    struct CampaignInfo {
        string name;
        string condition;
        string description;
    }

    mapping(address => uint) public contributions;

    // Array of contributors
    address[] public contributors;

    // Events
    event Contributed(address contributor, uint amount);
    event GoalReached();
    event FundTransfer(address recipient, uint amount);

    // Constructor function
    constructor(address _fundraiser, uint _fundneeded, uint _deadline, string memory _name,
     string memory _condition, string memory _description) public {
        fundraiser = _fundraiser;
        fundneeded = _fundneeded * (1 ether);
        deadline = _deadline * 86400;
        name = _name;
        condition = _condition;
        description = _description;
    }

    // Contribute function
    function contribute() public payable {
        require(!ended, "Target Amount has Reached.");
        require(now < deadline * 86400, "Deadline exceeded.");
        require(msg.value >= 1, "Contribution must be positive.");

        // Add contribution to total amount and contributor's contribution
        fundraised += msg.value;
        contributions[msg.sender] += msg.value;

        // Add contributor to contributors array
        contributors.push(msg.sender);

        // Emit Contributed event
        emit Contributed(msg.sender, msg.value);

        // Check if goal has been reached
        if (fundraised >= fundneeded) {
            ended = true;
            emit GoalReached();
        }
    }
    
    function withdrawFunds() public {
        require(msg.sender == fundraiser, "Only the fundraiser can withdraw funds.");
        require(ended, "Campaign must be ended before funds can be withdrawn.");

        msg.sender.transfer(fundraised);
    }

    // End campaign function (only callable by fundraiser)
    function endCampaign() public {
        require(msg.sender == fundraiser, "Only the fundraiser can end the campaign.");
        require(!ended, "Campaign has already ended.");

        ended = true;
        withdrawFunds();
    }

    // Refund function
    function refund(address _contributor) public {
        // Emit FundTransfer event
        emit FundTransfer(_contributor, contributions[_contributor]);

        // Reset contributor's contribution and remove from contributors array
        fundraised -= contributions[_contributor];
        delete contributions[_contributor];
        for (uint i = 0; i < contributors.length; i++) {
            if (contributors[i] == _contributor) {
                delete contributors[i];
                break;
            }
        }
    }


    function FundInfo() public view returns (CampaignInfo memory) {
        return CampaignInfo(name, condition, description);
    }
}



