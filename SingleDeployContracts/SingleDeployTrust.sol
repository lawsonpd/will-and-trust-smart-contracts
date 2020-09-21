pragma solidity ^0.6.0;
// SPDX-License-Identifier: MIT;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol";

/*

 * @future a beneficiary may have more than one trust.
 
 * @future do we need an `onlyOwners` modifier in this contract or can it be enforced via SDWillWithTrust?
 
 */

contract SimpleTrust {
    using EnumerableSet for EnumerableSet.AddressSet;
    
    struct Trust {
        address beneficiary;
        uint unlockTime;
        uint balance; // starts at 0 and is set when will is activated
    }
    
    // address is owner
    // purpose is to make sure a beneficiary is in the set of a will owner's beneficiaries
    mapping(address => EnumerableSet.AddressSet) benefs;
    
    // address is will owner
    mapping(address => Trust[]) private trusts;
    
    // address is beneficiary
    mapping(address => Trust[]) private benefTrusts;
    
    function addTrust(address _owner, address _beneficiary, uint _unlockTime) external {
        /**
         * this should only be callable by the *will* owner
         */
        require(_owner == tx.origin, "Only a will owner can call this function."); // enforce ownership; assert or require?
        
        Trust memory trust = Trust(_beneficiary, _unlockTime, 0); // initialize with 0 balance; funds added with `distribute`
        trusts[_owner].push(trust);
        benefTrusts[_beneficiary].push(trust);
        benefs[_owner].add(_beneficiary); // new
    }
    
    function distribute(address _owner, uint _share) external payable {
        require(_owner == tx.origin, "Only a will owner can call this function."); // enforce ownership; assert or require?
        
        Trust[] storage _trusts = trusts[_owner];
        for (uint i=0; i<_trusts.length; i++) {
            _trusts[i].balance += _share;
        }
    }
    
    function withdraw(address _willOwner) public {
        /*
          * this could be structured so that if beneficiary has multiple trusts,
          * this fn loops through list of trusts and withdraws any available funds.
        */
        
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
    
    receive() external payable {}

}
