pragma solidity ^0.6.0;
// SPDX-License-Identifier: GPL;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

/*
    Include link to actual will on IPFS?
*/

contract Will {
    // owner would be person with power of attorney, so that when benefactor passes away,
    // the will can be activated and funds will be available for withdrawal.
    address owner = msg.sender;
    
    // whether will is active for funds to be withdrawn.
    bool willActivated = false;
    
    // how the funds will be split between beneficiaries. the values must represent whole-number
    // percentages. e.g., [50, 25, 25] means the first benef in `benefs` is entitled to 50%
    // and the other two are entitled to 25% each.
    // @future consider adding percentage for person with power of attorney.
    mapping(address => uint) public benefSplits;
    
    function isOwner() public view returns(bool) {
        require(msg.sender == owner, "Must be owner.");
    }
    
    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    
    constructor () public {
        
    }
    
    function addBeneficiary(address _benef, uint _share) public onlyOwner {
        // should have a way to enforce that all beneficiary splits add to 100.
        benefSplits[_benef] = _share;
    }
    
    function getWillBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    function getBenefBalance() public view returns(uint) {
        // get benef's share of funds based on current balance 
        // and benef's split of funds.
        // assumes benef is caller.
        uint willBalance = address(this).balance;
        uint benefSplit = benefSplits[msg.sender];
        uint benefBalance = SafeMath.mul(willBalance, SafeMath.div(benefSplit, 100));
        return benefBalance;
    }
    
    function addFunds() public payable {
        
    }
    
    // function withdraw
    
    // function activateWill() onlyOwner
    
    fallback() external payable {}
}