```rust
Running 18 tests for test/ERC4626.t.sol:ERC4626Test
[PASS] test_RT_deposit_redeem(uint256) (runs: 256, μ: 546472, ~: 546474)
[PASS] test_RT_deposit_withdraw(uint256) (runs: 256, μ: 546482, ~: 546484)
[PASS] test_RT_mint_redeem(uint256) (runs: 256, μ: 547836, ~: 547839)
[PASS] test_RT_mint_withdraw(uint256) (runs: 256, μ: 547756, ~: 547758)
[PASS] test_asset() (gas: 5638)
[PASS] test_convertToAssets(uint256) (runs: 256, μ: 7858, ~: 7858)
[PASS] test_convertToShares(uint256) (runs: 256, μ: 7910, ~: 7910)
[PASS] test_deposit(uint256) (runs: 256, μ: 444714, ~: 444719)
[PASS] test_maxDeposit() (gas: 5634)
[PASS] test_maxMint() (gas: 5646)
[PASS] test_maxRedeem() (gas: 7835)
[PASS] test_maxWithdraw() (gas: 10095)
[PASS] test_mint(uint256) (runs: 256, μ: 446035, ~: 446040)
[PASS] test_previewDeposit(uint256) (runs: 256, μ: 440529, ~: 440531)
[PASS] test_previewMint(uint256) (runs: 256, μ: 441721, ~: 441724)
[PASS] test_previewRedeem(uint256) (runs: 256, μ: 7835, ~: 7835)
[PASS] test_previewWithdraw(uint256) (runs: 256, μ: 7741, ~: 7741)
[PASS] test_totalAssets() (gas: 33758)
Test result: ok. 18 passed; 0 failed; 0 skipped; finished in 26.08s

Running 12 tests for test/GreenBondV2.t.sol:GreenBondV2Test
[PASS] testCompleteProject(uint256) (runs: 256, μ: 743198, ~: 742797)
[PASS] testDepositFail(uint256) (runs: 256, μ: 220196, ~: 220198)
[PASS] testDepositUSDT(uint256) (runs: 256, μ: 438118, ~: 438124)
[PASS] testLinkAgreement() (gas: 114823)
[PASS] testPayProject(uint256) (runs: 256, μ: 662306, ~: 662549)
[PASS] testReceiveIncome(uint256) (runs: 256, μ: 757322, ~: 756966)
[PASS] testRecoverToken(uint256) (runs: 256, μ: 219382, ~: 219384)
[PASS] testRecoverTokenFail(uint256) (runs: 256, μ: 195068, ~: 195069)
[PASS] testRegisterProject() (gas: 92297)
[PASS] testTransferToken(uint256) (runs: 256, μ: 477034, ~: 477040)
[PASS] testWithdraw(uint256) (runs: 256, μ: 546315, ~: 546320)
[PASS] testWithdrawFail(uint256) (runs: 256, μ: 449622, ~: 449628)
Test result: ok. 12 passed; 0 failed; 0 skipped; finished in 26.24s

Ran 2 test suites: 30 tests passed, 0 failed, 0 skipped (30 total tests)
```