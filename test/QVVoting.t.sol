// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import {console} from "lib/forge-std/src/console.sol";
import {console2} from "lib/forge-std/src/console2.sol";

import {stdStorage, StdStorage, Test} from "lib/forge-std/src/Test.sol";

import {Utils} from "./utils/Utils.sol";

import {QVVoting} from "../src/QVVoting.sol";


contract BaseSetup is Test {
   Utils internal utils;

   QVVoting  qvvoting;

    address payable[] internal users;
    address internal owner;
    address internal marie;
    address internal anne;

// Test params
    string public name = "Minimistant";
    string public symbol = "MINIM";
    uint[] public votes;
     
   QVVoting.ProposalStatus ProposalStatus_;
   
   
   function setUp() public virtual {
       
        utils = new Utils();
        users = utils.createUsers(3);
        owner = users[0];
        vm.label(owner, "Owner");
        marie = users[1];
        vm.label(marie, "Marie");

        anne = users[2];
        vm.label(anne, "Anne");
        
        qvvoting = new QVVoting();
        //city.transferOwnership(owner);
        
        
       
       
   }
}

contract QVVotingTest is BaseSetup {

    

    function setUp() public override {
        super.setUp();
    }

    function test_startwithzero() public{
      qvvoting.balanceOf(owner);
    }

    function test_mint() public {
      qvvoting.mint(marie, 100);
      uint256 nb = qvvoting.balanceOf(marie);
      assertEq(nb, 100);
    }

    function test_createProposal() public {
      qvvoting.createProposal("proposal description", 1);
      ProposalStatus_ = qvvoting.getProposalStatus(1);
      assertEq(uint(ProposalStatus_), 0);
    }

    function test_allProposal() public {
      uint expirationn = 2;
      qvvoting.createProposal("New proposal  description", expirationn);
      ProposalStatus_ = qvvoting.getProposalStatus(1);
      assertEq(uint(ProposalStatus_), 0);

      qvvoting.mint(marie, 100);
      uint256 nb = qvvoting.balanceOf(marie);
      assertEq(nb, 100);

    uint time_ = qvvoting.getProposalExpirationTime(1);
    assertEq(time_, expirationn*60+1);

    vm.prank(marie);
    qvvoting.castVote(1, 16, true);
    
     uint256 balanceAccount1 =  qvvoting.balanceOf(marie);
     assertEq(balanceAccount1, 84);

    (uint yes, uint no) =  qvvoting.countVotes(1);
    assertEq(yes, 4);
    assertEq(no, 0);

    //owner without coin
   vm.expectRevert(bytes("Not enought token"));
    qvvoting.castVote(1, 16, true);

    


    }

}