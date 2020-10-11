pragma solidity ^0.6.0;
// SPDX-License-Identifier: GPL;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol";

contract SimpleWill {
    using EnumerableSet for EnumerableSet.AddressSet;

    address private owner;
    
    uint private willBalance;
    
    // needed to know how many beneficiaries are on the will
    EnumerableSet.AddressSet private beneficiaries;
    
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

    modifier willInactive() {
        require(!willActivated, "This action cannot be taken after will has been activated.");
        _;
    }
    
    /**
     * Currently this is only used on `withdraw`, but keeping in case another use case arises.
     */
    modifier willActive() {
        require(willActivated, "This will has not been activated.");
        _;
    }
    
    function getOwner()
        public
        view
    returns(address _owner)
    {
        _owner = owner;
    }
    
    function addBeneficiary(address _benef) 
        public 
        onlyOwner 
        willInactive
    {
        // record beneficiary.
        beneficiaries.add(_benef);
        uint numBeneficiaries = beneficiaries.length();
        
        // calculate this beneficiary's share of current funds.
        uint benefShare = SafeMath.div(willBalance, numBeneficiaries);
        
        // reset all beneficiaries' balances.
        // do this in case funds have already been deposited, in which case we need to
        // move some portion of funds already designated to existing beneficiaries.
        for (uint i; i<numBeneficiaries; i++) {
            balances[beneficiaries.at(i)] = benefShare;
        }
    }
    
    function getWillBalance() 
        public 
        view 
    returns(uint) 
    {
        return willBalance;
    }
    
    function getBenefBalance() 
        public 
        view 
    returns(uint) 
    {
        require(beneficiaries.contains(msg.sender), "You are not a beneficiary of this will.");

        // get benef's share of funds based on current balance
        return balances[msg.sender];
        
    }
    
    function withdraw() 
        public 
        willActive
    returns(uint)
    {
        require(beneficiaries.contains(msg.sender), "You are not a beneficiary of this will.");
        
        uint bal = balances[msg.sender];
        willBalance -= bal;
        
        balances[msg.sender] = 0;
        
        msg.sender.transfer(bal);
        
        return bal;
    }
    
    function activateWill() 
        public 
        onlyOwner 
        willInactive
    {
        require(willBalance > 0, "Please deposit funds before activating will.");
        willActivated = true;
    }
    
    function isActive()
        public
        view
    returns(bool _willActivated)
    {
        _willActivated = willActivated;
    }
    
    function depositFunds() 
        public 
        payable 
        onlyOwner 
        willInactive
    {
        willBalance += msg.value;
        
        uint numBeneficiaries = beneficiaries.length();
        if (numBeneficiaries > 0) {
            uint share = SafeMath.div(msg.value, numBeneficiaries);
            
            for (uint i=0; i<numBeneficiaries; i++) {
                address benef = beneficiaries.at(i);
                balances[benef] += share;
            }
        }
    }
    
    function getBeneficiaries() 
        public 
        view 
    returns(address[] memory) 
    {
        // This doesn't work.
        // address[] storage _beneficiaries;
        // for (uint i; i<beneficiaries.length(); i++) {
        //     _beneficiaries.push(beneficiaries.at(i));
        // }
        // return _beneficiaries;
    }

    function changeOwner(address _newOwner)
        public
        onlyOwner
        willInactive
    {
        owner = _newOwner;
    }
    
    receive() 
        external 
        payable 
    {
        willBalance += msg.value;
    }
    
}
