pragma solidity ^0.6.0;
// SPDX-License-Identifier: GPL;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol";


/*
    @future include link to actual will on IPFS?
    
    @future ability to remove a beneficiary
*/

contract Will {
    using Counters for Counters.Counter;
    // using EnumerableSet for EnumerableSet.AddressSet;
    
    // record the number of beneficiaries on the will.
    Counters.Counter public num_beneficiaries;

    address private owner;
    
    // list of beneficiaries.
    address[] private beneficiariesList;
    
    struct Beneficiary {
        uint balance;
        bool hasWithdrawn;
        // to check for existence
        bool exists; // this is always true
    }
    
    mapping(address => Beneficiary) private beneficiaries;
    
    // whether will is active for funds to be withdrawn.
    bool private willActivated = false;
    
    function _isOwner() 
        public 
        view 
    returns(bool) {
        return msg.sender == owner;
    }
    
    modifier onlyOwner() {
        require(_isOwner(), "Only the owner of the will can perform this operation.");
        _;
    }
    
    function _isBeneficiary() 
        internal 
        view 
    returns(bool) {
        Beneficiary memory benef = beneficiaries[msg.sender];
        return benef.exists;
    }

    modifier onlyBeneficiary() {
        require(_isBeneficiary(), "This address is not a beneficiary of this will.");
        _;
    }

    function _willIsActive()
        internal
        view
    returns(bool) {
        return willActivated;
    }

    modifier willInactive() {
        require(!_willIsActive(), "This action cannot be taken after will has been activated.");
        _;
    }
    
    constructor () public {
        // owner would be person with power of attorney, so that when benefactor passes away,
        // the will can be activated and funds will be available for withdrawal.
        owner = msg.sender;
    }
    
    function addBeneficiary(address _benef) 
        public 
        onlyOwner 
        willInactive
    {
        // increment number of beneficiaries currently on will.
        num_beneficiaries.increment();
        uint _num_benefs = num_beneficiaries.current();
        
        // calculate this beneficiary's share of current funds.
        uint benefShare = SafeMath.div(address(this).balance, _num_benefs);
        
        // record beneficiary.
        beneficiaries[_benef] = Beneficiary(benefShare, false, true);
        beneficiariesList.push(_benef);
    }
    
    function getWillBalance() 
        public 
        view 
        onlyOwner 
    returns(uint) {
        return address(this).balance;
    }
    
    function getBenefBalance(address _benef) 
        public 
        view 
        onlyBeneficiary
    returns(uint) {
        // get benef's share of funds based on current balance
        Beneficiary memory benef = beneficiaries[_benef];
        return benef.balance;
        
    }
    
    function withdraw() 
        public 
        willInactive
        onlyBeneficiary
    {
        Beneficiary memory benef = beneficiaries[msg.sender];
        
        uint bal = benef.balance;
        
        benef.balance = 0;
        benef.hasWithdrawn = true;
        
        msg.sender.transfer(bal);
    }
    
    function activateWill() 
        public 
        onlyOwner 
        willInactive
    {
        // may be good to require that will balance is not 0
        willActivated = true;
    }
    
    function depositFunds() 
        public 
        payable 
        onlyOwner 
        willInactive
    {
        uint val = msg.value;
        uint _num_benefs = beneficiariesList.length;
        uint share = SafeMath.div(val, _num_benefs);
        for (uint i=0; i<_num_benefs; i++) {
            address _address = beneficiariesList[i];
            uint current_bal = beneficiaries[_address].balance;
            Beneficiary memory benef = Beneficiary(current_bal + share, false, true);
            beneficiaries[_address] = benef;
            
        }
    }
    
    function getBeneficiaries() 
        public 
        view 
        onlyOwner 
    returns(address[] memory) {
        return beneficiariesList;
    }
    
}
