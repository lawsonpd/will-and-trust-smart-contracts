pragma solidity ^0.6.0;
// SPDX-License-Identifier: GPL;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol";



contract SDWill {
    /*
        @future include link to actual will on IPFS?
        
        @future ability to remove a beneficiary.
        
        @future consider adding `return true;` to functions that only modify but don't have return value.
    */
    
    using EnumerableSet for EnumerableSet.AddressSet;
    
    // record benefactors for onlyOwners modifier
    EnumerableSet.AddressSet private owners;
    
    struct Will {
        uint balance;
        bool executed;
        address[] beneficiaries;
    }
    
    // track who owns/admins which will
    mapping(address => Will) private wills;
    
    function _isOwner() 
        internal 
        view 
    returns(bool) {
        /**
         * an Owner is assumed to be either a benefactor or agent with power of attorney.
        */
        return owners.contains(msg.sender);
    }
    
    modifier onlyOwners() {
        require(_isOwner());
        _;
    }
    
    constructor () public {}
    
    function createWill(address[] memory _beneficiaries) 
        public 
        payable 
    {
        owners.add(msg.sender);
        Will memory will = Will(msg.value, false, _beneficiaries);
        wills[msg.sender] = will;
    }
    
    function getWillBalance() 
        public 
        view 
        onlyOwners 
    returns(uint) {
        Will memory will = wills[msg.sender];
        return will.balance;
    }
    
    function listBeneficiaries() 
        public 
        view 
        onlyOwners 
    returns(address[] memory) {
        Will memory will = wills[msg.sender];
        return will.beneficiaries;
    }
    
    function changeOwner(address _newOwner) 
        public 
        onlyOwners 
    {
        /*
          * do we need to set wills[msg.sender] to null or equivalent?
        */
        Will storage will = wills[msg.sender];
        owners.remove(msg.sender);
        owners.add(_newOwner);
        wills[_newOwner] = will;
    }
    
    function addBeneficiary(address _beneficiary) 
        public 
        onlyOwners 
    {
        Will storage will = wills[msg.sender];
        require(!will.executed, "Beneficiaries cannot be added after will has been executed.");
        will.beneficiaries.push(_beneficiary);
    }
    
    function depositFunds() 
        public 
        payable 
    {
        Will storage will = wills[msg.sender];
        require(!will.executed, "Funds cannot be deposited after will has been executed.");
        will.balance = msg.value;
    }
    
    function executeWill() 
        public 
        onlyOwners 
    {
        Will storage will = wills[msg.sender];
        require(!will.executed, "Will has already been executed.");
        
        will.executed = true;
        
        uint numBenefs = will.beneficiaries.length;
        
        uint bal = will.balance;
        will.balance = 0;
        
        uint share = SafeMath.div(bal, numBenefs);
        
        for (uint i=0; i<numBenefs; i++) {
            address payable benef = address(uint160(will.beneficiaries[i]));
            benef.transfer(share);
        }
    }
    
}
