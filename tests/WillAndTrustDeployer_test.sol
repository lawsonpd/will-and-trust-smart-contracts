pragma solidity >=0.4.22 <0.7.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../github/lawsonpd/will-smart-contract/WillAndTrustDeployer.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract WillAndTrustDeployerTest {
    WillAndTrustDeployer deployer;
    
    address acc0;

    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // Here should instantiate tested contract
        deployer = new WillAndTrustDeployer();
        acc0 = TestAccounts.getAccount(0);
        Assert.ok(deployer.owner == acc0);
    }
}
