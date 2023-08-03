// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {DeploySnaveToken} from "../script/DeploySnave.s.sol";
import {SnaveTechToken} from "../src/SnaveToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract SnaveTokenTest is StdCheats, Test {
    uint256 BOB_STARTING_AMOUNT = 100 ether;

    SnaveTechToken public snavetoken;
    DeploySnaveToken public deployer;
    address public deployerAddress;
    address bob;
    address alice;

    function setUp() public {
        deployer = new DeploySnaveToken();
        snavetoken = deployer.run();

        bob = makeAddr("bob");
        alice = makeAddr("alice");

        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);
        snavetoken.transfer(bob, BOB_STARTING_AMOUNT);
    }

    function testInitialSupply() public {
        assertEq(snavetoken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(snavetoken)).mint(address(this), 1);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        // Alice approves Bob to spend tokens on her behalf
        vm.prank(bob);
        snavetoken.approve(alice, initialAllowance);
        uint256 transferAmount = 500;

        vm.prank(alice);
        snavetoken.transferFrom(bob, alice, transferAmount);
        assertEq(snavetoken.balanceOf(alice), transferAmount);
        assertEq(
            snavetoken.balanceOf(bob),
            BOB_STARTING_AMOUNT - transferAmount
        );
    }

    // can you get the coverage up?
}
