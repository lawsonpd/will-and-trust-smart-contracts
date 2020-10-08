pragma solidity ^0.6.0;
// SPDX-License-Identifier: GPL;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract SimpleWill {
    address private owner;
    
    uint private willBalance;
    
    // needed to know how many beneficiaries are on the will
    address[] private beneficiaries;
    
    // beneficiary => balance
    mapping(address => uint) private balances;
    
    bool private willActivated = false;
    
    constructor() 
        public 
    {
        // owner would be person with power of attorney, so that the will 
        // can be activated and funds will be available for withdrawal.
        owner = tx.origin;
    }
    
    function _isOwner() 
        public 
        view 
    returns(bool) 
    {
        return msg.sender == owner;
    }
    
    modifier onlyOwner() {
        require(_isOwner(), "Only the owner of the will can perform this operation.");
        _;
    }

    function _willActive()
        public
        view
    returns(bool) 
    {
        return willActivated;
    }

    modifier willInactive() {
        require(!_willActive(), "This action cannot be taken after will has been activated.");
        _;
    }
    
    modifier willActive() {
        require(_willActive(), "This will has not been activated.");
        _;
    }
    
    function addBeneficiary(address _benef) 
        public 
        onlyOwner 
        willInactive
    {
        // record beneficiary.
        beneficiaries.push(_benef);
        uint numBeneficiaries = beneficiaries.length;
        
        // calculate this beneficiary's share of current funds.
        uint benefShare = SafeMath.div(willBalance, numBeneficiaries);
        
        // reset all beneficiaries' balances.
        // do this in case funds have already been deposited, in which case we need to
        // move some portion of funds already designated to existing beneficiaries.
        for (uint i; i<numBeneficiaries; i++) {
            balances[beneficiaries[i]] = benefShare;
        }
    }
    
    function getWillBalance() 
        public 
        view 
        onlyOwner 
    returns(uint) 
    {
        return willBalance;
    }
    
    function getBenefBalance() 
        public 
        view 
    returns(uint) 
    {
        // get benef's share of funds based on current balance
        return balances[msg.sender];
        
    }
    
    function withdraw() 
        public 
        willActive
    {
        uint bal = balances[msg.sender];
        willBalance -= bal;
        
        balances[msg.sender] = 0;
        
        msg.sender.transfer(bal);
    }
    
    function activateWill() 
        public 
        onlyOwner 
        willInactive
    {
        require(willBalance > 0, "Please deposit funds before activating will.");
        willActivated = true;
    }
    
    function depositFunds() 
        public 
        payable 
        onlyOwner 
        willInactive
    {
        willBalance += msg.value;
        
        uint numBeneficiaries = beneficiaries.length;
        if (numBeneficiaries == 0) {
            return;
        } else {
            uint share = SafeMath.div(msg.value, numBeneficiaries);
            
            for (uint i=0; i<numBeneficiaries; i++) {
                address benef = beneficiaries[i];
                balances[benef] += share;
            }
        }
    }
    
    function getBeneficiaries() 
        public 
        view 
        onlyOwner 
    returns(address[] memory) 
    {
        return beneficiaries;
    }

    function changeOwner(address _newOwner)
        public
        onlyOwner
        willInactive
    {
        owner = _newOwner;
    }
    
}
