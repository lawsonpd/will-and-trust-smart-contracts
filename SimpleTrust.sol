pragma solidity ^0.6.0;
// SPDX-License-Identifier: GPL;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";



contract SimpleTrust {
    
    address payable private beneficiary;
    uint private balance;
    uint private unlockTime;
    
    constructor (address payable _beneficiary, uint _unlockTime) public {
        beneficiary = _beneficiary;
        unlockTime = _unlockTime;
    }
    
    function isBenef() internal view returns(bool) {
        return msg.sender == beneficiary;
    }
    
    modifier onlyBenefs() {
        require(isBenef(), "You are not the beneficiary of this trust.");
        _;
    }
    
    function withdraw() public onlyBenefs {
        require(now >= unlockTime, "Trust is still locked.");
        beneficiary.transfer(balance);
    }
    
    function getTrustDetails() public view onlyBenefs returns(uint[2] memory) {
        uint daysTilUnlock;
        if (now < unlockTime) {
            uint secsTilUnlock = SafeMath.sub(now, unlockTime);
            daysTilUnlock = SafeMath.div(secsTilUnlock, 60 * 60 * 24);
        } else {
            daysTilUnlock = 0;
        }
        uint[2] memory info = [balance, daysTilUnlock];
        return info;
    }
    
    receive() external payable {
        balance += msg.value;
    }

}