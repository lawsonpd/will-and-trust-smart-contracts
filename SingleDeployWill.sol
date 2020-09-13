pragma solidity ^0.6.0;
// SPDX-License-Identifier: GPL;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol";

/*
    @future include link to actual will on IPFS?
    
    @future ability to remove a beneficiary
*/

contract Will {
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    // record benefactors.
    // mapping(address => bool) isBenefactor;
    EnumerableSet.AddressSet benefactors;
    
    // track whether will is active.
    mapping(address => bool) willActivated;
    
    // map benefactor's address to a mapping of beneficiaries to their details.
    mapping(address => mapping(address => Beneficiary)) wills;
    
    // benefactors' balances.
    // `address` is benefactor.
    mapping(address => uint) willBalances;
    
    // keep track of how many beneficiaries are associated with a particular will.
    // `address` is benefactor.
    mapping(address => uint) numBeneficiaries;
    
    // owner => beneficiaries
    mapping(address => address[]) beneficiaries;
    
    struct Beneficiary {
        // uint balance; // needed? alt'y just track who has withdrawn and let withdraw amount be balance / num_benefs.
        bool hasWithdrawn;
        bool exists; // to check for existence. this is always true.
    }
    
    function _isOwner() internal view returns(bool) {
        /**
         * an Owner is assumed to be either a benefactor or entity with power of attorney.
        */
        // return isBenefactor[msg.sender];
        return benefactors.contains(msg.sender);
    }
    
    modifier onlyOwner() {
        require(_isOwner());
        _;
    }
    
    // constructor () public {}
    
    function addBeneficiary(address _beneficiary) public onlyOwner {
        require(!willActivated[msg.sender], "Beneficiaries cannot be added after will has been activated.");
        
        // add beneficiary to will
        Beneficiary memory benef = Beneficiary(false, true); // false: has not withdrawn; true: exists for lookup.
        wills[msg.sender][_beneficiary] = benef;
        
        // increment number of beneficiaries on this will
        numBeneficiaries[msg.sender] += 1;
    }
    
    function _isBenefactor(address _benefactor) internal view returns(bool) {
        return benefactors.contains(_benefactor);
    }
    
    function _isBeneficiary(address _beneficiary) internal view returns(bool) {
    }
    
    function getBenefBalance(address _beneficiary) public view returns(uint) {
    }
    
    function withdraw() public {
        /**
         * challenge here is that if we don't have a way to update beneficiaries' balances
         * when depositing funds (because no lookup), then, if calculation is based on num of benef's,
         * then after one benef withdraws the calculation for the remaining will be wrong because one
         * has withdrawn but the calculation will assume there are still n (and not n-1) benef's.
         * 
         * a crude solution will be to decrement numBeneficiaries when a benef withdraws.
        */
        
    }
    
    function activateWill() public onlyOwner {
    }
    
    function getWillBalance() public view returns(uint) {
    }
    
    function createWill() public payable {
        // isBenefactor[msg.sender] = true;
        benefactors.add(msg.sender);
        willBalances[msg.sender] = msg.value; // keep? if not, remove payable and allow deposits via depositFunds().
        willActivated[msg.sender] = false; // necessary? alt'y just set to true when activated.
    }
    
    function depositFunds() public payable {
        require(!willActivated[msg.sender], "Funds cannot be deposited after will has been activated.");
        willBalances[msg.sender] += msg.value;
    }
    
    function getBeneficiariesOfWill() public view onlyOwner returns(address[] memory) {
        return beneficiaries[msg.sender];
    }
    
}
