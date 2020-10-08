pragma solidity ^0.6.0;
// SPDX-License-Identifier: GPL;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract SimpleTrust {
    address private owner; // benefactor or power of attorney
    
    address payable private beneficiary;
    uint private balance;
    uint private unlockTime;
    
    constructor(address payable _beneficiary, uint _unlockTime) 
        public 
    {
        // Since _unlockTime is some number of days, convert to seconds
        uint _unlockTimestamp = SafeMath.mul(_unlockTime, 60 * 60 * 24);
        
        beneficiary = _beneficiary;
        
        // Set unlockTime to a timestamp of now + seconds til unlock
        unlockTime = SafeMath.add(now, _unlockTimestamp);
        owner = tx.origin;
    }

    modifier reqUnlocked() {
        require(isUnlocked(), "Trust is still locked.");
        _;
    }
    
    /**
     * @dev This is primarily to restrict deposits to before trust has been unlocked.
     * It doesn't really make sense to add funds to a trust after the unlock time has
     * been passed and withdraws may have already been made.
    */
    modifier reqLocked() {
        require(!isUnlocked(), "This operation can only be performed while trust is locked.");
        _;
    }
    
    modifier onlyBenefs() {
        address _beneficiary = getBeneficiary();
        require(msg.sender == _beneficiary, "Only the beneficiary of this trust can perform this operation.");
        _;
    }
    
    modifier onlyBenefOrOwner() {
        address _owner = getOwner();
        address _beneficiary = getBeneficiary();
        require(msg.sender == _beneficiary || msg.sender == _owner, "Only the trust owner and benficiary can perform this operation.");
        _;
    }

    function isUnlocked()
        public
        view
    returns(bool) 
    {
        return now >= unlockTime;
    }
    
    function getOwner()
        public
        view
    returns(address _owner)
    {
        _owner = owner;
    }
    
    function getBeneficiary()
        public
        view
    returns(address _beneficiary)
    {
        _beneficiary = beneficiary;
    }
    
    function depositFunds() 
        public
        payable
        reqLocked // Funds shouldn't be deposited after trust has unlocked
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
    
    function getDaysTilUnlock()
        public
        view
        // onlyBenefOrOwner // * commented out for testing
    returns(uint _daysTilUnlock)
    {
        _daysTilUnlock = 0;
        if (now < unlockTime) {
            uint secsTilUnlock = SafeMath.sub(now, unlockTime);
            _daysTilUnlock = SafeMath.div(secsTilUnlock, 60 * 60 * 24);
        }
    }
    
    function getBalance()
        public
        view
        // onlyBenefOrOwner // * commented out for testing
    returns(uint _balance)
    {
        _balance = balance;
    }
    
    /**
     * @dev Primarily for testing unlock time
    */
    function getCurrentBlockTimestamp()
        public
        view
    returns(uint)
    {
        return now;
    }
    
    receive() 
        external
        payable 
    {
        balance += msg.value;
    }

}
