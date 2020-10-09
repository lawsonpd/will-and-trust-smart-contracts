pragma solidity >=0.4.22 <0.7.0;
import "remix_tests.sol";
import "remix_accounts.sol";
import "../github/lawsonpd/will-and-trust-smart-contracts/SimpleWill.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    address payable acc0; // this will be beneficiary in testing
    address acc1;
    
    SimpleWill will;

    /// 'beforeAll' runs before all other tests
    function beforeEach() public {
        acc0 = payable(TestsAccounts.getAccount(0));
        acc1 = TestsAccounts.getAccount(1); // This will be new owner in testChangeOwner
        
        will = new SimpleWill();
        
        // Add one beneficiary for each test
        will.addBeneficiary(acc0);
    }
    
    function beneficiaryExists() public {
        address[] memory _beneficiaries = will.getBeneficiaries();
        Assert.ok(_beneficiaries.length > 0, "There should be 1 beneficiary.");
    }
    
    function testIsInactive() public {
        Assert.ok(!will.willActivated, "Will should not be active at this point.");
    }
    
    function testBalanceAfterDeposit() public {
        will.transfer(10000);
        uint balance = will.getWillBalance();
        Assert.equal(balance, 10000, "Balance should at present be 10000.");
    }
    
    function testBeneficiaryBalance() public {
        will.transfer(10000);
        uint benefBalance = will.getBenefBalance();
        Assert.equal(benefBalance, 10000, "Beneficiary balance should be 10000.");
    }
    
    function testDepositAndActivateAndWithdraw() public {
        will.transfer(10000);
        will.activateWill();
        uint withdrawal = will.withdraw(); // Withdraw amount will be 0 but withdrawal should still be allowed
        Assert.equal(withdrawal, 0, "Withdrawal should be allowed and amount should be 0.");
    }
    
    function testChangeOwner() public {
        will.changeOwner(acc1);
        Assert.notEqual(address(this), will.owner, "Will owner should not be testing contract address.");
    }
}
