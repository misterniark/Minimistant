// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import {console} from "lib/forge-std/src/console.sol";
import {console2} from "lib/forge-std/src/console2.sol";

import {stdStorage, StdStorage, Test} from "lib/forge-std/src/Test.sol";

import {Utils} from "./utils/Utils.sol";

import {City} from "../src/City.sol";

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

   
   function setUp() public virtual {
       
        utils = new Utils();
        users = utils.createUsers(3);
        owner = users[0];
        vm.label(owner, "Owner");
        marie = users[1];
        vm.label(marie, "Marie");

        anne = users[2];
        vm.label(anne, "Anne");
        
        city = new City(name, symbol);
        
       
       
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
        city.getPassportAddress();
        city.getEtatCivilAddress();

    }
    function test_apopulation() public {
        uint256 pop = city.totalPopulation();
        assertEq(pop, 0);
    }
    function test_bjoinCity() public {

        bool _bool;

        uint256 pop = city.totalPopulation();
        assertEq(pop, 0);

        city.addToCity(owner,"Genty","Mathieu");
        pop = city.totalPopulation();
        assertEq(pop, 1);

        city.addToCity(marie,"Pesenti","Marie");
        pop = city.totalPopulation();
        assertEq(pop, 2);

        city.joinCity(anne, "Brenas","Anne");
        pop = city.totalPopulation();
        assertEq(pop, 2);
        
        string memory  statut = city.getCitizenStatut(anne);
        assertEq(statut, "Pending");

        city.agreeCitizenship(anne);
        pop = city.totalPopulation();
        assertEq(pop, 3);

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