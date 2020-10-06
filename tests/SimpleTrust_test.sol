pragma solidity >=0.4.22 <0.7.0;
import "remix_tests.sol";
import "remix_accounts.sol";
import "../github/lawsonpd/will-smart-contract/SimpleTrust.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract SimpleTrustTest {
    address payable acc0;
    address payable acc1;
    address payable acc2;
    
    SimpleTrust trust1;
    SimpleTrust trust2;
    
    /// 'beforeAll' runs before all other tests
    function beforeAll() public {
        acc0 = payable(TestsAccounts.getAccount(0));
        acc1 = payable(TestsAccounts.getAccount(1));
        acc2 = payable(TestsAccounts.getAccount(2));
        
        trust1 = new SimpleTrust(acc1, 0); // initialize with unlockTime = 0 days
        trust2 = new SimpleTrust(acc2, 1); // initialize with unlockTime = 1 day
    }
    
    function testTrustOwnership() public {
        Assert.equal(trust1.getOwner(), acc0, "Trust owner should be acc0.");
        Assert.equal(trust2.getOwner(), acc0, "Trust owner should be acc0.");
    }
}
