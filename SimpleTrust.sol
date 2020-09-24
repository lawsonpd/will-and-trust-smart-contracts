pragma solidity ^0.6.0;
// SPDX-License-Identifier: GPL;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract SimpleTrust {
    address private owner; // benefactor or power of attorney
    
    address payable private beneficiary;
    uint private balance;
    uint private unlockTime;
    
    constructor(address _owner, address payable _beneficiary, uint _unlockTime) 
        public 
    {
        beneficiary = _beneficiary;
        unlockTime = _unlockTime; // timestamp
        owner = _owner;
    }
    
    function _isBenef() 
        internal 
        view 
    returns(bool) 
    {
        return msg.sender == beneficiary;
    }
    
    modifier onlyBenefs() {
        require(_isBenef(), "You are not the beneficiary or owner of this trust.");
        _;
    }

    function _isUnlocked()
        internal
        view
    returns(bool) 
    {
        return now >= unlockTime;
    }

    modifier reqUnlocked() {
        require(_isUnlocked(), "Trust is still locked.");
        _;
    }
    
    function _isOwner()
        public
        view
    returns(bool)
    {
        return msg.sender == owner;
    }
    
    modifier onlyBenefOrOwner() {
        require(_isBenef() || _isOwner(), "Only the trust owner and benficiary can perform this operation.");
        _;
    }
    
    function getBeneficiary()
        public
        view
        onlyBenefOrOwner
    returns(address)
    {
        return beneficiary;
    }
    
    function depositFunds() 
        public
        payable
    {
        balance += msg.value;
    }
    
    function withdraw() 
        public 
        onlyBenefs
        reqUnlocked
    {
        uint val = balance;
        balance = 0;
        beneficiary.transfer(val);
    }
    
    function getBalanceAndUnlockTime() 
        public 
        view 
        onlyBenefOrOwner
    returns(uint[2] memory) 
    {
        uint daysTilUnlock = 0;
        if (now < unlockTime) {
            uint secsTilUnlock = SafeMath.sub(now, unlockTime);
            daysTilUnlock += SafeMath.div(secsTilUnlock, 60 * 60 * 24);
        }
        uint[2] memory info = [balance, daysTilUnlock];
        return info;
    }
    
    receive() 
        external
        payable 
    {
        balance += msg.value;
    }

}