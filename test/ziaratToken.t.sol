//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployZiaratToken} from "../script/DeployZiarat.s.sol";
import {ZiaratToken} from "../src/ziaratToken.sol";

contract TestZiaratToken is Test {
    DeployZiaratToken dzt;
    ZiaratToken zt;
    address Alice = makeAddr("Alice");
    address Bob = makeAddr("Bob");

    function setUp() external {
        dzt = new DeployZiaratToken();
        // vm.prank(address(owner));
        zt = dzt.run();
        // vm.stopPrank();
        vm.prank(msg.sender);
        zt.transfer(Alice, 1000 * 10 ** 18);
        vm.prank(msg.sender);
        zt.setVotingPower(Bob, 10);
        vm.prank(msg.sender);
        zt.setVotingPower(Alice, 15);
    }

    function testTotalSupply() public view {
        assertEq(zt.totalSupply(), 1000000000 * 10 ** zt.decimals());
    }

    function testOwnerBalance() public view {
        address ownerAddress = zt.owner();
        console.log(ownerAddress);
        console.log("ziaratToken", address(zt));
        console.log("DeziaratToken", address(dzt));
        console.log("This Contract", address(this));
        console.log("Virtual Address deploying Smart Contracts", address(msg.sender));
        // vm.expectRevert();
        assertEq(zt.balanceOf(address(msg.sender)), 1000000000 * 10 ** zt.decimals() - (1000 * 10 ** 18));
    }

    function testBobBalance() public view {
        assertEq(zt.balanceOf(address(Alice)), 1000 * 10 ** 18);
    }

    function testOwner() public view {
        assert(zt.owner() == msg.sender);
    }

    function testCreateProposal() public {
        uint256 beforeCreatingProposal_proposalLength = zt.getTotalNumberOfProposals();

        vm.startPrank(Alice);
        uint256 proposalId = zt.createProposal("abc");
        uint256 proposalId2 = zt.createProposal("xyz");
        vm.stopPrank();
        uint256 afterCreatingProposal_proposalLength = zt.getTotalNumberOfProposals();

        assertEq(beforeCreatingProposal_proposalLength, 0);
        assertEq(afterCreatingProposal_proposalLength, 2);
        assertEq(proposalId2, 1);
        assertEq(proposalId, 0);
    }

    function testVoteOnProposal() public {
        testCreateProposal();
        vm.startPrank(Bob);
        zt.voteOnProposal(0, true);
        vm.stopPrank();
        vm.prank(Alice);
        zt.voteOnProposal(0, false);

        bool hasVotedFor = zt.getVoterStatusAgaintProposal(0, Bob);
        assertEq(hasVotedFor, true);

        ZiaratToken.Proposal memory proposal = zt.getProposalDetials(0);
        assertEq(proposal.votesFor, 10);
        assertEq(proposal.votesAgainst, 15);
    }

    function testExpectedRevertOnFailedProposals() public {
        testVoteOnProposal();
        vm.prank(msg.sender);
        vm.expectRevert();
        zt.executeProposal(0); // 15% vote against it
    }

    function testProposalsExecuteOnPass() public {
        testVoteOnProposal();

        vm.prank(Alice);
        zt.voteOnProposal(1, true);
        vm.prank(Bob);
        zt.voteOnProposal(1, true);

        vm.prank(msg.sender);
        zt.executeProposal(1);

        ZiaratToken.Proposal memory proposal = zt.getProposalDetials(1);
        assertEq(proposal.executed, true);
    }

    function testMintMoreSupply() public {
        // vm.prank(Alice);
        // vm.expectRevert();
        // zt.mint(Alice, 1000 * 10 ** zt.decimals());
        console.log(zt.totalSupply());
        vm.prank(zt.owner());
        zt.mint(zt.owner(), 1000 * 10 ** zt.decimals());
        assertEq(zt.totalSupply(), 1000000100 * 10 ** zt.decimals());
    }
}
