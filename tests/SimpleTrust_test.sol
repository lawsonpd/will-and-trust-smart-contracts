pragma solidity >=0.4.22 <0.7.0;
import "remix_tests.sol";
import "remix_accounts.sol";
// import "../github/lawsonpd/will-smart-contract/SimpleTrust.sol";
import "../github/lawsonpd/will-smart-contract/SimpleTrust.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract SimpleTrustTest1 {
    address payable acc0;
    address payable acc1;
    
    SimpleTrust trust1;
    
    /// 'beforeAll' runs before all other tests
    function beforeAll() public {
        acc0 = payable(TestsAccounts.getAccount(0));
        acc1 = payable(TestsAccounts.getAccount(1));
        
        trust1 = new SimpleTrust(acc1, 0); // initialize with unlockTime = 0 days
    }
    
    function testTrustOwnership() public {
        Assert.equal(trust1.getOwner(), acc0, "Trust owner should be acc0.");
    }
    
    function testBeneficiaryAddress() public {
        Assert.equal(trust1.getBeneficiary(), acc1, "Beneficiary should be acc1.");
    }
    
    function testTrustIsActive() public {
        Assert.ok(trust1.isUnlocked(), "Trust should be unlocked/active.");
    }
}

contract SimpleTrustTest2 {
    address payable acc0;
    address payable acc2;
    
    SimpleTrust trust2;
    
    /// 'beforeAll' runs before all other tests
    function beforeAll() public {
        acc0 = payable(TestsAccounts.getAccount(0));
        acc2 = payable(TestsAccounts.getAccount(2));
        
        trust2 = new SimpleTrust(acc2, 1); // initialize with unlockTime = 1 day
    }
    
    function testTrustOwnership() public {
        Assert.equal(trust2.getOwner(), acc0, "Trust owner should be acc0.");
    }
    
    function testBeneficiaryAddress() public {
        Assert.equal(trust2.getBeneficiary(), acc2, "Beneficiary should be acc2.");
    }
    
    function testTrustIsInactive() public {
        Assert.ok(!trust2.isUnlocked(), "Trust should be locked/inactive.");
    }
}

// contract SimpleTrustTest3 is SimpleTrust {
//     address payable acc0;
//     address payable acc1;
    
//     /// 'beforeAll' runs before all other tests
//     function beforeAll() public {
//         acc0 = payable(TestsAccounts.getAccount(0));
//         acc1 = payable(TestsAccounts.getAccount(1));
//     }
    
//     function testTrustOwnership() public {
//         Assert.equal(getOwner(), acc0, "Trust owner should be acc0.");
//     }
    
//     function testBeneficiaryAddress() public {
//         Assert.equal(getBeneficiary(), acc1, "Beneficiary should be acc2.");
//     }
    
//     function testTrustActiveOrInactive() public {
//         uint[2] memory balanceAndUnlocktime = getBalanceAndDaysTilUnlock();
//         uint daysTilUnlock = balanceAndUnlocktime[1];
//         Assert.lesserThan(daysTilUnlock, uint(1), "Trust should have 1 day til unlocked.");
//     }
// }
