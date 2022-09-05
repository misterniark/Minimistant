// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import {console} from "lib/forge-std/src/console.sol";
import {console2} from "lib/forge-std/src/console2.sol";

import {stdStorage, StdStorage, Test} from "lib/forge-std/src/Test.sol";

import {Utils} from "./utils/Utils.sol";

import {City} from "../src/City.sol";
import {Passport} from "../src/Passport.sol";
import {EtatCivil} from "../src/EtatCivil.sol";

contract BaseSetup is Test {
   Utils internal utils;

   City  city;

    address payable[] internal users;
    address internal owner;
    address internal marie;
    address internal anne;

// Test params
    string public name = "Minimistant";
    string public symbol = "MINIM";

    uint256 internal pop;
    bool _bool;
   
   function setUp() public virtual {
       
        utils = new Utils();
        users = utils.createUsers(3);
        owner = users[0];
        vm.label(owner, "Owner");
        marie = users[1];
        vm.label(marie, "Marie");

        anne = users[2];
        vm.label(anne, "Anne");
        
        city = new City();
        //city.transferOwnership(owner);
        
        
       
       
   }
}

contract CityTest is BaseSetup {

    

    function setUp() public override {
        super.setUp();
    }
    function testinitialState() public {
        // assert if the corrent name was used
        assertEq(city.cityname(), name);
        // assert if the correct symbol was used
        assertEq(city.symbol(), symbol);

        
       
        city.getPassportName();
        city.getPassportSymbol();
        city.getCityAddress();

        


    }
    function test_ownerhip() public{
       
        console.log(city.owner());
        city.cascadeOnershipTransfert(owner);
     
        EtatCivil civilowner = EtatCivil(city.getEtatCivilAddress());
        assertEq(city.owner(), civilowner.owner());

        Passport passowner = Passport(city.getPassportAddress());
        assertEq(city.owner(), passowner.owner());
        assertEq(passowner.owner(), civilowner.owner());

        console.log("owner is the owner of City");
        assertEq(owner, city.owner());
        console.log("owner is the owner of EtatCivil");
        assertEq(owner, civilowner.owner());
        console.log("owner is the owner of passport");
        assertEq(owner, passowner.owner());

        
       /* vm.prank(city.owner());
        city.cascadeOnershipTransfert(marie);
        assertEq(city.owner(), civilowner.owner());
        assertEq(city.owner(), passowner.owner());
        assertEq(marie, civilowner.owner());
        assertEq(marie, passowner.owner());
        */
        


    }
    
    function test_trasfertMustFail() public{
        uint256 idtoken = city.addToCity(owner,"Genty","Mathieu");
        pop = city.totalPopulation();
        assertEq(pop, 1);

        city.addToCity(marie, "Pensenti","Marie");
        pop = city.totalPopulation();
        assertEq(pop, 2);

        city.revokeCitizenship(marie);
        pop = city.totalPopulation();
        assertEq(pop, 1);

        address testpassportadd = city.getPassportAddress();
        Passport testpassport = Passport(testpassportadd);
        
        vm.expectRevert(abi.encodePacked("ERC721: caller is not token owner or approved"));
        testpassport.transferFrom(owner,marie,idtoken);

        uint256 nb = testpassport.balanceOf(owner);
        assertEq(nb, 1);

         nb = testpassport.balanceOf(marie);
        assertEq(nb, 0);

    }
    function  test_EncryptjoinCity() public {

        city.setEncryptIdentity(true);
        city.addToCity(owner,"Genty","Mathieu");
        pop = city.totalPopulation();
        assertEq(pop, 1);
        string memory name;
        string memory firstname;
        uint256  keccakIdentity;
        string memory citizenship;
        uint256 startTime;
        uint256 endTime;
        uint256 passportId;
        address citizenAddress;

         

         (  name,
          firstname,
          keccakIdentity,
          citizenship,
         startTime,
         endTime,
         passportId,
         citizenAddress) = 
        city.getRegistryInfos(owner);

        assertEq(firstname, '');
        assertEq(name, '');
        uint256 hashing = uint256(keccak256(abi.encode("Mathieu", "Genty", owner)));

        assertEq(keccakIdentity, hashing);

    }
    // (string memory name,
    //     string memory firstname,
    //     uint256  keccakIdentity,
    //     string memory citizenship,
    //     uint256 startTime,
    //     uint256 endTime,
    //     uint256 passportId,
    //     address citizenAddress)

    function  test_bjoinCity() public {

        

        pop = city.totalPopulation();
        assertEq(pop, 0);

         /**Test addToCity */
        city.addToCity(owner,"Genty","Mathieu");
        pop = city.totalPopulation();
        assertEq(pop, 1);

        city.addToCity(marie,"Pesenti","Marie");
        pop = city.totalPopulation();
        assertEq(pop, 2);

        /**Test JoinCity */
        vm.prank(anne);
        city.joinCity("Brenas","Anne");
        pop = city.totalPopulation();
        assertEq(pop, 2);
        
        /**Test Statut */
        string memory  statut = city.getCitizenStatut(anne);
        assertEq(statut, "Pending");

        /**Test agreeCitizenship */
        city.agreeCitizenship(anne);
        pop = city.totalPopulation();
        assertEq(pop, 3);

         /**Test revokeCitizenship */
        city.revokeCitizenship(marie);
        pop = city.totalPopulation();
        assertEq(pop, 2);

       
         _bool = city.isCitizen(anne);
        assertEq(_bool, true);
         _bool = city.isCitizen(marie);
        assertEq(_bool, false);

        string memory  statut2 = city.getCitizenStatut(anne);
        assertEq(statut2, "Active");
        string memory  statut3 = city.getCitizenStatut(marie);
        assertEq(statut3, "Canceled");

        city.getRegistryInfos(anne);
        city.getRegistryInfos(marie);
        city.getRegistryInfos(owner);

        vm.expectRevert(abi.encodePacked("ALREADYIN"));
        city.addToCity(owner,"Genty","Mathieu");

        vm.expectRevert(abi.encodePacked("NOTACITIZEN"));
        city.revokeCitizenship(marie);
        
        pop = city.totalPopulation();
        assertEq(pop, 2);

        city.agreeCitizenship(marie);
        pop = city.totalPopulation();
        assertEq(pop, 3);
         _bool = city.isCitizen(marie);
        assertEq(_bool, true);



        
    }
    
  
}