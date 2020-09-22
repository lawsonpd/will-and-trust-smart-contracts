pragma solidity ^0.6.0;
// SPDX-License-Identifier: GPL;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol";

/*
    @future include link to actual will on IPFS?
    
    @future ability to remove a beneficiary
*/

contract SDWill {
    using EnumerableSet for EnumerableSet.AddressSet;
    
    // record benefactors for onlyOwners modifier
    EnumerableSet.AddressSet owners;
    
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
    
    modifier onlyOwner() {
        require(_isOwner());
        _;
    }

    function _willIsActive()
        public
        view
    returns(bool) {
        Will memory will = wills[msg.sender];
        return !will.executed;
    }

    modifier willInactive() {
        require(!_willIsActive(), "This action cannot be taken after will has been activated.");
        _;
    }
    
    constructor () 
        public {}
    
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
        onlyOwner 
    returns(uint) {
        Will memory will = wills[msg.sender];
        return will.balance;
    }
    
    function listBeneficiaries() 
        public 
        view 
        onlyOwner 
    returns(address[] memory) {
        Will memory will = wills[msg.sender];
        return will.beneficiaries;
    }
    
    function changeOwner(address _newOwner) 
        public 
        onlyOwner 
    {
        Will storage will = wills[msg.sender];
        owners.remove(msg.sender);
        owners.add(_newOwner);
        wills[_newOwner] = will;
    }
    
    function addBeneficiary(address _beneficiary) 
        public 
        onlyOwner 
        willInactive
    {
        Will storage will = wills[msg.sender];
        will.beneficiaries.push(_beneficiary);
    }
    
    function depositFunds() 
        public 
        payable 
        willInactive
    {
        Will storage will = wills[msg.sender];
        will.balance = msg.value;
    }
    
    function executeWill() 
        public 
        onlyOwner 
        willInactive
    {
        Will storage will = wills[msg.sender];
        
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
