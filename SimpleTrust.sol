pragma solidity ^0.6.0;
// SPDX-License-Identifier: MIT;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

/*

 * @future a beneficiary may have more than one trust.
 
 * @future do we need an `onlyOwners` modifier in this contract or can it be enforced via SDWillWithTrust?
 
 */

contract SimpleTrust {
    
    struct Trust {
        address beneficiary;
        uint unlockTime;
        uint balance; // starts at 0 and is set when will is activated
    }
    
    // address is will owner
    mapping(address => Trust[]) private trusts;
    
    // address is beneficiary
    mapping(address => Trust) private benefTrusts;
    
    function addBenef(address _trustBenef, uint _unlockTime) external {
        Trust memory _trust = Trust(_trustBenef, _unlockTime, 0);
        trusts[tx.origin].push(_trust);
        benefTrusts[_trustBenef] = _trust;
    }
    
    function distribute(uint _numTrusts, uint _share) external {
        Trust[] storage _trusts = trusts[tx.origin];
        for (uint i=0; i<_numTrusts; i++) {
            _trusts[i].balance += _share;
        }
    }
    
    function withdraw() public {
        Trust storage _trust = benefTrusts[msg.sender];
        require(now >= _trust.unlockTime, "This trust has not yet been unlocked.");
        
        uint val = _trust.balance;
        _trust.balance = 0;
        msg.sender.transfer(val);
    }
    
    function getTimeTilUnlockInSeconds() public view returns(uint) {
        Trust memory _trust = benefTrusts[msg.sender];
        if (now >= _trust.unlockTime) {
            return 0;
        } else {
            uint _timeTilUnlock = SafeMath.sub(now, _trust.unlockTime);
            return _timeTilUnlock;
        }
    }

}