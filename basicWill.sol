pragma solidity ^0.6.0;
// SPDX-License-Identifier: GPL;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol";


/*
    Include link to actual will on IPFS?
*/

contract Will {
    using Counters for Counters.Counter;
    // using EnumerableSet for EnumerableSet.AddressSet;
    
    // record the number of beneficiaries on the will.
    Counters.Counter num_beneficiaries;
    
    // owner would be person with power of attorney, so that when benefactor passes away,
    // the will can be activated and funds will be available for withdrawal.
    address owner = msg.sender;
    
    // list of beneficiaries.
    address[] beneficiariesList;
    
    struct Beneficiary {
        uint balance;
        bool hasWithdrawn;
        // to check for existence:
        bool exists;
    }
    
    mapping(address => Beneficiary) beneficiaries;
    
    // whether will is active for funds to be withdrawn.
    bool public willActivated = false;
    
    function isOwner() public view returns(bool) {
        return msg.sender == owner;
    }
    
    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    
    constructor () public {}
    
    function addBeneficiary(address _benef) public onlyOwner {
        // increment number of beneficiaries currently on will.
        num_beneficiaries.increment();
        uint _num_benefs = num_beneficiaries.current();
        
        // calculate this beneficiary's share of current funds.
        uint benefShare = SafeMath.div(address(this).balance, _num_benefs);
        
        // record beneficiary.
        beneficiaries[_benef] = Beneficiary(benefShare, false, true);
        beneficiariesList.push(_benef);
    }
    
    function getWillBalance() public view onlyOwner returns(uint) {
        return address(this).balance;
    }
    
    function _isBeneficiary(address _benef) internal view returns(bool) {
        Beneficiary memory benef = beneficiaries[_benef];
        return benef.exists;
    }
    
    function getBenefBalance(address _benef) public view returns(uint) {
        // get benef's share of funds based on current balance 
        // and benef's split of funds (currently assumed to be full balance / num_beneficiaries).
        
        require(_isBeneficiary(_benef), "This address does not belong to a beneficiary of this will.");
        Beneficiary memory benef = beneficiaries[_benef];
        return benef.balance;
        
    }
    
    function withdraw() public {
        require(willActivated == true, "Will is not yet active. Funds cannot be withdrawn at this time.");
        
        Beneficiary memory benef = beneficiaries[msg.sender];
        
        uint bal = benef.balance;
        
        benef.balance = 0;
        benef.hasWithdrawn = true;
        
        msg.sender.transfer(bal);
    }
    
    function activateWill() public onlyOwner {
        willActivated = true;
    }
    
    
    function depositFunds() public payable onlyOwner {
        uint val = msg.value;
        uint _num_benefs = num_beneficiaries.current();
        uint share = SafeMath.div(val, _num_benefs);
        for (uint i=0; i<_num_benefs; i++) {
            address _address = beneficiariesList[i];
            Beneficiary memory benef = beneficiaries[_address];
            benef.balance += share;
        }
    }
    
    function getBeneficiaries() public view onlyOwner returns(address[] memory) {
        return beneficiariesList;
    }
    
}
