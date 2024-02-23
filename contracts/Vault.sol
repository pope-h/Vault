// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vault {
    struct Grant {
        address donor;
        uint256 amount;
        uint256 releaseTime;
        bool claimed;
    }

    mapping(address => Grant[]) public grants;

    event GrantCreated(address indexed donor, address indexed beneficiary, uint256 amount, uint256 releaseTime);
    event GrantClaimed(address indexed beneficiary, uint256 amount);

    constructor() payable {} 

    function createGrant(address _beneficiary, uint256 _releaseTime) external payable {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(msg.value > 0, "Invalid amount");

        grants[_beneficiary].push(Grant({
            donor: msg.sender,
            amount: msg.value,
            releaseTime: _releaseTime,
            claimed: false
        }));

        emit GrantCreated(msg.sender, _beneficiary, msg.value, _releaseTime);
    }

    function claimGrant(uint256 _index) external {
        address beneficiary = msg.sender;
        require(_index < grants[beneficiary].length, "Invalid index");

        Grant storage grant = grants[beneficiary][_index];
        
        require(block.timestamp >= grant.releaseTime, "Grant release time not reached");
        require(!grant.claimed, "Grant already claimed");

        grant.claimed = true;
        payable(beneficiary).transfer(grant.amount);

        emit GrantClaimed(beneficiary, grant.amount);
    }
}