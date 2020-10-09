pragma solidity ^0.6.0;
// SPDX-License-Identifier: GPL;

import "https://github.com/lawsonpd/will-and-trust-smart-contracts/blob/master/SimpleWill.sol";
import "https://github.com/lawsonpd/will-and-trust-smart-contracts/blob/master/SimpleTrust.sol";

contract WillAndTrustDeployer {
    address owner = msg.sender;
    
    // will owner => will contract address
    mapping(address => address) wills;
    
    // will owner => trust contract address
    mapping(address => address) trusts;
    
    function createWill()
        public 
    returns(SimpleWill willAddress) 
    {
        SimpleWill will = new SimpleWill();
        wills[msg.sender] = address(will);
        return will;
    }
    
    /**
        * @param _unlockTime is some number of days
    */
    function createTrust(address payable _beneficiary, uint _unlockTime)
        public
    returns(SimpleTrust trustAddress)
    {
        SimpleTrust trust = new SimpleTrust(_beneficiary, _unlockTime);
        trusts[msg.sender] = address(trust);
        return trust;
    }
}
