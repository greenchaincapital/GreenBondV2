// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {GreenBondV2} from "src/GreenBondV2.sol";

contract GreenBondV2Test is Test {
    using stdStorage for StdStorage;

    GreenBondV2 public bond;
    address public gov;

    function setUp() public {
        bond = new GreenBondV2();
        gov = tx.origin;
    }

    function writeTokenBalance(address who, ERC20 token, uint256 amt) internal {
        stdstore.target(address(token)).sig(token.balanceOf.selector).with_key(who).checked_write(amt);
    }

    function testDepositUSDT(uint256 amount) public {
        vm.assume(amount > 2000);
        ERC20 token = bond.asset();
        vm.assume(amount < 20000000000000);
        writeTokenBalance(address(this), token, amount);
        token.approve(address(bond), amount);
        uint256 shares = bond.deposit(amount, address(this));
        assertGt(shares, 0);
        assertEq(bond.balanceOf(address(this)), shares);
    }

    function testDepositFail(uint256 amount) public {
        vm.assume(amount > 2000);
        ERC20 token = bond.asset();
        vm.assume(amount < 20000000000000);
        writeTokenBalance(address(this), token, amount);
        vm.expectRevert();
        bond.deposit(amount, address(this));
    }

    function testWithdraw(uint256 amount) public {
        vm.assume(amount > 2000);
        ERC20 token = bond.asset();
        vm.assume(amount < 20000000000000);
        writeTokenBalance(address(this), token, amount);
        token.approve(address(bond), amount);
        bond.deposit(amount, address(this));
        vm.warp(block.timestamp + 365 days);
        uint256 assets = bond.redeem(bond.balanceOf(address(this)), address(this), address(this));
        assertGt(assets, 0);
        assertEq(token.balanceOf(address(this)), assets);
    }

    function testWithdrawFail(uint256 amount) public {
        vm.assume(amount > 2000);
        ERC20 token = bond.asset();
        vm.assume(amount < 20000000000000);
        writeTokenBalance(address(this), token, amount);
        token.approve(address(bond), amount);
        uint256 shares = bond.deposit(amount, address(this));
        vm.warp(block.timestamp + 365 days);
        vm.prank(address(1));
        vm.expectRevert();
        bond.withdraw(shares, address(this), address(this));
    }

    function testRecoverToken(uint256 amount) public {
        vm.assume(amount > 2000);
        ERC20 token = bond.asset();
        vm.assume(amount < 20000000000000);
        writeTokenBalance(address(this), token, amount);
        token.transfer(address(bond), amount);
        vm.prank(gov);
        bond.recoverToken(address(token), address(this), amount);
        assertEq(token.balanceOf(address(this)), amount);
    }

    function testRecoverTokenFail(uint256 amount) public {
        vm.assume(amount > 2000);
        ERC20 token = bond.asset();
        vm.assume(amount < 20000000000000);
        writeTokenBalance(address(this), token, amount);
        token.transfer(address(bond), amount);
        vm.expectRevert();
        bond.recoverToken(address(token), address(this), amount);
    }

    function testTransferToken(uint256 amount) public {
        vm.assume(amount > 2000);
        ERC20 token = bond.asset();
        vm.assume(amount < 20000000000000);
        writeTokenBalance(address(this), token, amount);
        token.approve(address(bond), amount);
        uint256 shares = bond.deposit(amount, address(this));
        bond.transfer(address(1), shares);
        assertEq(bond.depositTimestamps(address(1)), block.timestamp);
    }

    function testRegisterProject() public {
        vm.prank(gov);
        uint256 id = bond.registerProject(address(this), "Test project");
        (,,address admin,,,string memory projectName,) = bond.projects(id);
        assertEq(admin, address(this));
        assertEq(projectName, "Test project");
    }

    function testLinkAgreement() public {
        vm.prank(gov);
        uint256 id = bond.registerProject(address(this), "Test project");
        vm.prank(gov);
        bond.linkProjectAgreement(id, "https://signed-agreement.com");
        (,,,,,,string memory agreement) = bond.projects(id);
        assertEq(agreement, "https://signed-agreement.com");
    }

    function testPayProject(uint256 amount) public {
        vm.assume(amount>4000);
        ERC20 token = bond.asset();
        vm.assume(amount < 20000000000000);
        vm.prank(gov);
        uint256 id = bond.registerProject(address(this), "Test project");
        writeTokenBalance(address(this), token, amount);
        token.approve(address(bond), amount);
        bond.deposit(amount, address(this));
        vm.prank(gov);
        bond.payProject(amount-1, id);
        (bool isActive,,,uint128 totalSupplied,,,) = bond.projects(id);
        assertEq(isActive, true);
        assertGt(totalSupplied, 0);
        assertGe(token.balanceOf(address(this)), amount * 99/100);
    }

    function testReceiveIncome(uint256 amount) public {
        vm.assume(amount>4000);
        ERC20 token = bond.asset();
        vm.assume(amount < 20000000000000);
        vm.prank(gov);
        uint256 id = bond.registerProject(address(this), "Test project");
        writeTokenBalance(address(this), token, amount);
        token.approve(address(bond), amount);
        bond.deposit(amount, address(this));
        vm.prank(gov);
        bond.payProject(amount-1, id);
        uint256 amount2 = token.balanceOf(address(this));
        token.approve(address(bond), amount2);
        bond.receiveIncome(amount2, id);
        (,,,,uint128 totalRePaid,,) = bond.projects(id);
        assertGt(totalRePaid, 0);
    }

    function testCompleteProject(uint256 amount) public {
        vm.assume(amount>4000);
        ERC20 token = bond.asset();
        vm.assume(amount < 20000000000000);
        vm.prank(gov);
        uint256 id = bond.registerProject(address(this), "Test project");
        writeTokenBalance(address(this), token, amount);
        token.approve(address(bond), amount/2);
        bond.deposit(amount/2, address(this));
        vm.prank(gov);
        bond.payProject(amount/2-1, id);
        uint256 amount2 = token.balanceOf(address(this));
        token.approve(address(bond), amount2);
        bond.receiveIncome(amount2, id);
        vm.prank(gov);
        bond.completeProject(id);
        (,bool isCompleted,,,,,) = bond.projects(id);
        assertEq(isCompleted, true);
    }

}
