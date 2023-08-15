// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface Add1 {
    function add1(uint256 num) external pure returns (uint256);
}

contract Add1Test is Test, NonMatchingSelectorHelper {
    Add1 public add1;

    function setUp() public {
        add1 = Add1(HuffDeployer.config().deploy("Add1"));
    }

    function testOverflowRevert() public {
        vm.expectRevert(bytes(""));
        uint256 max_256 = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
        add1.add1(max_256);
    }

    function testAdd1() public {
        assertEq(add1.add1(41), 42, "Add1(41) expected to return 42");
        assertEq(add1.add1(23), 24, "Add1(23) expected to return 24");
        assertEq(add1.add1(0), 1, "Add1(0) expected to return 1");
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](1);
        func_selectors[0] = Add1.add1.selector;

        bool success = nonMatchingSelectorHelper(
            func_selectors,
            callData,
            address(add1)
        );
        assert(!success);
    }
}
