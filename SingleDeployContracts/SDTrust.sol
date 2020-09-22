pragma solidity ^0.6.0;
// SPDX-License-Identifier: MIT;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol";

contract SDTrust {
    using EnumerableSet for EnumerableSet.AddressSet;
    
    struct Trust {
        uint unlockTime;
        uint balance; // starts at 0 and is set when will is activated
    }
    
    // to check whether a beneficiary is in the set of a will owner's beneficiaries
    // key address is owner
    mapping(address => EnumerableSet.AddressSet) private benefs;
    
    // first key address is owner; second is beneficiary
    mapping(address => mapping(address => Trust)) trusts;
    
    
    
    function _isBenef(address _owner) 
        internal 
        view 
    returns(bool) {
        return benefs[_owner].contains(msg.sender);
    }
    
    modifier onlyBenef(address _owner) {
        require(_isBenef(_owner), "You are not a beneficiary of this trust.");
        _;
    }
    
    function _isOwner(address _owner) 
        internal 
        view 
    returns(bool) {
        return _owner == tx.origin;
    }
    
    modifier onlyOwner(address _owner) {
        require(_isOwner(_owner), "Only a will owner can call this function.");
        _;
    }
    
    
    
    function addTrust(address _beneficiary, uint _unlockTime) 
        external 
        onlyOwner(tx.origin) 
    {
        Trust memory trust = Trust(_unlockTime, 0); // initialize with 0 balance; funds added with `distribute`
        address owner = tx.origin;
        trusts[owner][_beneficiary] = trust;
        benefs[owner].add(_beneficiary); // new
    }
    
    function distribute(address[] calldata _benefs, uint _share) 
        external 
        payable 
        onlyOwner(tx.origin) 
    {
        address owner = tx.origin;
        for (uint i=0; i<_benefs.length; i++) {
            trusts[owner][_benefs[i]].balance += _share;
        }
    }
    
    function withdraw(address _willOwner) 
        public 
        onlyBenef(_willOwner) 
    {
        /*
          * this could be structured so that if beneficiary has multiple trusts,
          * this fn loops through list of trusts and withdraws any available funds.
        */
        address benef = msg.sender;
        Trust storage trust = trusts[_willOwner][benef];
        require(now >= trust.unlockTime, "This trust has not yet been unlocked.");
        
        uint val = trust.balance;
        trust.balance = 0;
        msg.sender.transfer(val);
        
    }
    
    function getTimeTilUnlockInSeconds(address _willOwner) 
        public 
        view 
        onlyBenef(_willOwner) 
    returns(uint) {
        address benef = msg.sender;
        Trust memory trust = trusts[_willOwner][benef];
        if (now >= trust.unlockTime) {
            return 0;
        } else {
            uint _timeTilUnlock = SafeMath.sub(now, trust.unlockTime);
            return _timeTilUnlock;
        }
    }
    
    // function getTrustInfo() public view returns(uint[] memory) {
    //     Trust[] memory _trusts = benefTrusts[msg.sender];
    //     uint[] storage _trustInfo; // info to return to user
    //     uint _numTrusts = _trusts.length;
    //     for (uint i; i<_numTrusts; i++) {
    //         Trust memory _trust = _trusts[i];
    //         if (now >= _trust.unlockTime) { // if time is past trust unlock time
    //             _trustInfo.push(0);
    //         } else {
    //             uint _timeTilUnlock = SafeMath.sub(_trust.unlockTime, now);
    //             uint _timeInDays = SafeMath.div(_timeTilUnlock, 24 * 60 * 60);
    //             _trustInfo.push(_timeInDays);
    //         }
    //     }
    //     return _trustInfo;
    // }
    
    receive() 
        external 
        payable 
    {
        /*
            distribute funds to all beneficiaries in `benefs` (AddressSet)
        */
    }

}
