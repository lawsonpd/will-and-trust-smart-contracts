pragma solidity ^0.6.0;
// SPDX-License-Identifier: GPL;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol";

/*
    @future include link to actual will on IPFS?
    
    @future ability to remove a beneficiary

    @future do we really need `numBeneficiaries` if we can check the length of Will.beneficiaries?
*/

contract SDWill {
    using EnumerableSet for EnumerableSet.AddressSet;
    
    // record benefactors for onlyOwners modifier
    EnumerableSet.AddressSet private benefactors;
    
    struct Will {
        address owner;
        uint balance;
        bool isActive;
        EnumerableSet.AddressSet beneficiaries;
        mapping(address => Beneficiary) beneficiaryDetails;
    }
    
    struct Beneficiary {
        bool hasWithdrawn;
        uint balance;
    }
    
    // track number of beneficiaries on a will.
    // this will be incremented as benef's are added and decremented as they withdraw.
    mapping(address => uint) private numBeneficiaries;
    
    // track who owns which will
    mapping(address => Will) private wills;
    
    function _isOwner() 
        internal 
        view 
    returns(bool) {
        /**
         * an Owner is assumed to be either a benefactor or entity with power of attorney.
        */
        return benefactors.contains(msg.sender);
    }
    
    modifier onlyOwner() {
        require(_isOwner());
        _;
    }
    
    function _isBeneficiary(address _owner) 
        internal 
        view 
    returns(bool) {
        
    }
    
    function _isBenefactor(address _benefactor) 
        internal 
        view 
    returns(bool) {
        return benefactors.contains(_benefactor);
    }
    
    // constructor () public {}
    
    function addBeneficiary(address _beneficiary) 
        public 
        onlyOwner 
    {
        require(!willActivated[msg.sender], "Beneficiaries cannot be added after will has been activated.");
        
        numBeneficiaries[msg.sender] += 1;
        
        // add beneficiary to will
        // benef id's will start at 1
        uint id = numBeneficiaries[msg.sender];
        Beneficiary memory benef = Beneficiary(id, false, true); // false: has not withdrawn; true: exists.
        beneficiaries[msg.sender][_beneficiary] = benef;
        wills[_beneficiary].push(msg.sender);
    }
    
    function withdraw(address _owner) 
        public 
    {
        //  challenge here is that if we don't have a way to update beneficiaries' balances
        //  when depositing funds (because no lookup), then, if calculation is based on num of benef's,
        //  then after one benef withdraws the calculation for the remaining will be wrong because one
        //  has withdrawn but the calculation will assume there are still n (and not n-1) benef's.
         
        //  a crude solution would be to decrement numBeneficiaries when a benef withdraws.
        
        // calculate beneficiary's share
        uint willBalance = willBalances[_owner];
        uint numBenefs = numBeneficiaries[_owner];
        uint benefShare = SafeMath.div(willBalance, numBenefs);
        
        // decrement numBeneficiaries
        numBeneficiaries[_owner] -= 1;
        
        Beneficiary memory benef = beneficiaries[_owner];
        
        // transfer funds to beneficiary
        msg.sender.transfer(benefShare);
        
    }
    
    function activateWill() 
        public 
        onlyOwner 
    {
        willActivated[msg.sender] = true;
    }
    
    function getWillBalance() 
        public 
        view 
        onlyOwner 
    returns(uint) {
        return willBalances[msg.sender];
    }
    
    function createWill() 
        public 
        payable 
    {
        benefactors.add(msg.sender);
    }
    
    function depositFunds() 
        public 
        payable 
    {
        require(!willActivated[msg.sender], "Funds cannot be deposited after will has been activated.");
        willBalances[msg.sender] += msg.value;
    }
    
}
