pragma solidity >=0.4.22 <0.7.0;
import "remix_tests.sol";
import "remix_accounts.sol";
import "../github/lawsonpd/will-and-trust-smart-contracts/SimpleWill.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    address payable acc0;
    address payable acc1; // this will be beneficiary in tests
    address payable acc2;
    
    SimpleWill will;
    
    /// 'beforeAll' runs before all other tests
    function beforeAll() public {
        acc0 = payable(TestsAccounts.getAccount(0));
        acc1 = payable(TestsAccounts.getAccount(1));
        acc2 = payable(TestsAccounts.getAccount(2)); // This will be new owner in testChangeOwner
        
        will = new SimpleWill();
    }
    
    function testOwner() public {
        Assert.equal(will.getOwner(), acc0, "Owner should be account acc0.");
    }
    
    function testWillBalance() public {
        uint initBalance = will.getWillBalance();
        address(will).call.value(10000 wei).gas(300000);
        uint balance = will.getWillBalance();
        
        Assert.equal(uint(initBalance), uint(0), "Initial balance should be 0.");
        Assert.equal(uint(balance), uint(10000), "Balance after deposit should be 10000.");
    }
    
    function testBeneficiaryExists() public {
        will.addBeneficiary(acc1);
        // address[] memory _beneficiaries = will.getBeneficiaries();
        address benef = will.getBeneficiary(0);
        Assert.equal(benef, acc1, "There should be 1 beneficiary, namely acc1.");
    }
    
    function testBeneficiaryBalance() public {
        address(will).call.value(10000 wei).gas(300000);
        uint benefBalance = will.getBenefBalance();
        Assert.equal(benefBalance, uint(10000), "Beneficiary balance should be 10000.");
    }
    
    function testIsInactive() public {
        Assert.ok(!will.isActive(), "Will should not be active at this point.");
    }
    
    function testChangeOwner() public {
        will.changeOwner(acc2);
        Assert.ok(!will._isOwner(), "Will owner should not be testing contract address.");
    }
    
    function testActivateWill() public {
        will.activateWill();
        Assert.ok(will.isActive(), "Will should now be active.");
    }
}
