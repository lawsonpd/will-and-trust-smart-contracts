pragma solidity ^0.6.0;
// SPDX-License-Identifier: GPL;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol";



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
        require(isBenef(), "You are not the beneficiary of this truse.");
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
        // list of beneficiary addresses that are associated with the trust contract
        // need this for distributing funds
        address[] trusts;
    }
    
    // track who owns/admins which will
    mapping(address => Will) private wills;
    
    function _isOwner() internal view returns(bool) {
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
    
    function createWill(address[] memory _beneficiaries) public payable {
        owners.add(msg.sender);
        address[] memory _trusts; // empty array of trust beneficiaries
        Will memory will = Will(msg.value, false, _beneficiaries, _trusts);
        wills[msg.sender] = will;
    }
    
    function getWillBalance() public view onlyOwners returns(uint) {
        Will memory will = wills[msg.sender];
        return will.balance;
    }
    
    function listBeneficiaries() public view onlyOwners returns(address[] memory) {
        Will memory will = wills[msg.sender];
        return will.beneficiaries;
    }
    
    function changeOwner(address _newOwner) public onlyOwners {
        /*
          * do we need to set wills[msg.sender] to null or equivalent?
        */
        Will storage will = wills[msg.sender];
        owners.remove(msg.sender);
        owners.add(_newOwner);
        wills[_newOwner] = will;
    }
    
    function addBeneficiary(address _beneficiary) public onlyOwners {
        Will storage will = wills[msg.sender];
        require(!will.executed, "Beneficiaries cannot be added after will has been executed.");
        will.beneficiaries.push(_beneficiary);
    }
    
    function addTrust(address payable _beneficiary, uint _unlockTime) public onlyOwners {
        /*
          * _unlockTime is some number of days
        */
        
        Will storage will = wills[msg.sender];
        require(!will.executed, "Beneficiaries cannot be added after will has been executed.");
        
        uint _unlockTimeInSeconds = SafeMath.mul(_unlockTime, 24 * 60 * 60);
        
        SimpleTrust trust = new SimpleTrust(_beneficiary, now + _unlockTimeInSeconds);
        will.trusts.push(address(trust));
    }
    
    function depositFunds() public payable {
        Will storage will = wills[msg.sender];
        require(!will.executed, "Funds cannot be deposited after will has been executed.");
        will.balance = msg.value;
    }
    
    function executeWill() public onlyOwners {
        Will storage will = wills[msg.sender];
        require(!will.executed, "Will has already been executed.");
        
        will.executed = true;
        
        uint numBenefs = will.beneficiaries.length;
        uint numTrusts = will.trusts.length;
        uint totalBenefs = numBenefs + numTrusts;
        
        uint bal = will.balance;
        will.balance = 0;
        
        uint share = SafeMath.div(bal, totalBenefs);
        
        
        for (uint i=0; i<numBenefs; i++) {
            address payable benef = address(uint160(will.beneficiaries[i]));
            benef.transfer(share);
        }
        
        for (uint i=0; i<numTrusts; i++) {
            address payable _trust = payable(will.trusts[i]);
            _trust.transfer(share);
        }
    }
    
}
