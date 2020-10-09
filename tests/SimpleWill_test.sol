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
    function beforeEach() public {
        acc0 = payable(TestsAccounts.getAccount(0));
        acc1 = payable(TestsAccounts.getAccount(1));
        acc2 = payable(TestsAccounts.getAccount(2)); // This will be new owner in testChangeOwner
        
        will = new SimpleWill();
    }
    
    function testOwner() public {
        Assert.equal(will.getOwner(), acc0, "Owner should be account acc0.");
    }
    
    function testWillBalance() public {
        address(will).call.value(10000 wei).gas(300000);
        uint balance = will.getWillBalance();
        Assert.equal(balance, 10000 wei, "Balance should at present be 10000.");
    }
    
    function beneficiaryExists() public {
        will.addBeneficiary(acc1);
        address[] memory _beneficiaries = will.getBeneficiaries();
        Assert.greaterThan(uint(_beneficiaries.length), uint(0), "There should be 1 beneficiary.");
    }
    
    function testIsInactive() public {
        Assert.ok(!will.isActive(), "Will should not be active at this point.");
    }
    
    function testBalanceAfterDeposit() public {
        address(will).call.value(10000 wei).gas(300000);
        uint balance = will.getWillBalance();
        Assert.equal(balance, 10000, "Balance should at present be 10000.");
    }
    
    function testBeneficiaryBalance() public {
        address(will).call.value(10000 wei).gas(300000);
        uint benefBalance = will.getBenefBalance();
        Assert.equal(benefBalance, 10000, "Since there is 1 beneficiary, the balance thereof should be 10000.");
    }
    
    function testDepositAndActivateAndWithdraw() public {
        address(will).call.value(10000 wei).gas(300000);
        will.activateWill();
        uint withdrawal = will.withdraw(); // Withdraw amount will be 0 but withdrawal should still be allowed
        Assert.equal(withdrawal, 0, "Withdrawal should be allowed and amount should be 0.");
    }
    
    function testChangeOwner() public {
        will.changeOwner(acc2);
        Assert.ok(!will._isOwner(), "Will owner should not be testing contract address.");
    }
}
