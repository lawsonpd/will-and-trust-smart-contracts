pragma solidity ^0.6.0;
// SPDX-License-Identifier: MIT;

contract SimpleTrust {
    
    struct Trust {
        uint unlockDate;
        uint balance;
    }
    
    mapping(address => Trust[]) trusts;
    
    function addBenef(address _beneficiary) internal 
}
