// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin-contracts/contracts/security/Pausable.sol";
import  {EtatCivil} from "./EtatCivil.sol";
import  {IsStarted} from "./Utils/IsStarted.sol";



/**
 * @title Network City based on network State concept from Balaji Srinivasan
 * @dev Create a network City
 */

contract City is  Ownable, Pausable, IsStarted {
    enum Citizenship {        
        Pending,        
        Active,        
        Canceled    
    } 

    struct CitizenIdcard{ 
        string name;
        string firstname;
        uint256  keccakIdentity;
        string citizenship;
        uint256 startTime;
        uint256 endTime;
        uint256 passportId;
        address citizenAddress;
        
    }
    
    // Mapping Struct CitizenIdcard by adress
    mapping(address => CitizenIdcard) private citizenRegistry;


    //Mapping if address as citizenship
    mapping(address => bool) public population;

    //Mapping if address as waiting citizenship
    mapping(address => bool) public waitingPopulation;


    //Population total
    uint private census = 0;
    
    string public cityname;
    string public name;
    string public symbol;
    bool private encryptIdentity = false;

    string private _passportName;
    string private _passportSymbol;
    string private _suffixPassportName = "Id";
    string private _suffixPassportSymbol = "Id";
 
    EtatCivil public etatCivil;

    event NewCitizenRequest(address _adress);
    event NewCitizen(address _adress,uint256 passportId);
    event LeftCitizen(address _adress,uint256 tokenId);
    event PopulationState(uint population);
    event NewcityStarted(string cityname,string symbol);
    event Log(string message);
    event IstherealownerOfCity(address);

    constructor() {
        string memory cityname_ = "Minimistant";
        string memory symbol_ = "MINIM";
        name = cityname = cityname_;
        symbol = symbol_;
        _passportName = string(abi.encodePacked(cityname, _suffixPassportName));
        _passportSymbol = string(abi.encodePacked(symbol,_suffixPassportSymbol));
        
        etatCivil = new EtatCivil(_passportName,_passportSymbol);
        _start();
        census = 0;
        emit NewcityStarted(cityname, symbol);
        
    }

    function totalPopulation() external view returns (uint256){
        return census;
    }
    function createCitizen(address address_,  string memory name_, string memory firstname_) private view whenNotPaused onlyIfStarted returns( CitizenIdcard memory) {
            CitizenIdcard memory citizenIdcard;
            if(encryptIdentity)
            citizenIdcard.keccakIdentity = uint256(keccak256(abi.encode(firstname_, name_, address_)));
            else{
            citizenIdcard.firstname = firstname_;
            citizenIdcard.name = name_;
            }
            citizenIdcard.citizenship = "Pending";
            citizenIdcard.startTime = block.timestamp;
            citizenIdcard.citizenAddress = address_;
            
        return citizenIdcard;
    }
    function joinCity(string memory _name, string memory _firstname) public whenNotPaused onlyIfStarted {
        address _address = msg.sender ;
        require(isCitizen(_address) == false, "ALREADYIN");
        /*
        * Crypter les nom ?
        */
        CitizenIdcard memory citizen;
        citizen = createCitizen(_address, _name, _firstname);
        citizenRegistry[_address] = citizen;
        waitingPopulation[_address] = true;
        if(_address == owner()) agreeCitizenship(_address);
        emit NewCitizenRequest(_address);
    }
    /**
    fonction qui permet au owner d'ajouter un citizen avec son address
     */
    function addToCity(address address_,string memory _name, string memory _firstname) public whenNotPaused onlyIfStarted onlyOwner  returns(uint256){
        address _address = address_;
        require(isCitizen(_address) == false, "ALREADYIN");
        /*
        * Crypter les nom ?
        */
        //
    
        CitizenIdcard memory citizen;
        citizen = createCitizen(_address, _name, _firstname);
        citizenRegistry[_address] = citizen;
        waitingPopulation[_address] = true;
        uint256 passportid = agreeCitizenship(_address);
        emit NewCitizenRequest(_address);
        return passportid;
    }
    function agreeCitizenship(address _address) public onlyOwner onlyIfStarted returns(uint256) {
        CitizenIdcard storage citizen;
        citizen = citizenRegistry[_address];
        citizen.passportId = etatCivil.createPassport(_address);
        citizen.citizenship = "Active";

        //if passport was revoked before
        if(citizen.endTime !=0){
            citizen.endTime = 0;
        }

        citizenRegistry[_address] = citizen;

        population[_address] = true;
        delete waitingPopulation[_address];
        census++;

        emit NewCitizen(_address,citizen.passportId);
        emit PopulationState(census);
        return citizen.passportId;

    }
    function revokeCitizenship(address _address) public onlyOwner onlyIfStarted{
        require(isCitizen(_address),"NOTACITIZEN");
        CitizenIdcard storage citizen;
        citizen = citizenRegistry[_address];
        citizen.citizenship = "Canceled";
        citizen.endTime = block.timestamp;
        
        citizenRegistry[_address] = citizen;

        etatCivil.revokePassport(citizen.passportId);
        
        delete citizenRegistry[_address].passportId;
        
        delete population[_address];
        census--;
        emit LeftCitizen(_address, citizen.passportId);
        emit PopulationState(census);

    }

    function isCitizen(address _address) public view returns (bool){
        if(population[_address] == true) return true;
        else return false;

    }
    
    function getCityName() public view  returns(string memory){
        return cityname;
    }
    function getCitizenInfos(address _citizen_address) public view returns (CitizenIdcard memory) {
        require(isCitizen(_citizen_address),"NOTACITIZEN");
       
        CitizenIdcard memory citizenInfos;
        citizenInfos = citizenRegistry[_citizen_address];
        
        return (citizenInfos);
    }
    function getCitizenStatut(address _citizen_address) public view returns (string memory) {
        CitizenIdcard memory citizenInfos;
        citizenInfos = citizenRegistry[_citizen_address];
        return citizenInfos.citizenship;

    }


    function getRegistryInfos(address _citizen_address) public view returns (
        string memory,
        string memory,
        uint256,
        string memory,
        uint256,
        uint256,
        uint256,
        address
    ) {
        
        CitizenIdcard memory citizenInfos = citizenRegistry[_citizen_address];

       return (
        citizenInfos.name,
        citizenInfos.firstname,
        citizenInfos.keccakIdentity,
        citizenInfos.citizenship,
        citizenInfos.startTime,
        citizenInfos.endTime,
        citizenInfos.passportId,
        citizenInfos.citizenAddress
        );
    }

    function setEncryptIdentity(bool encrypt ) public onlyOwner{
        encryptIdentity = encrypt;
    }
    function getEncryptStatut(address address_) public onlyOwner returns(bool){
        return encryptIdentity;
    }
    function getPassportName() public view returns(string memory){
        return _passportName;
    }
    function getPassportSymbol() public view returns(string memory){
        return _passportSymbol;
    }
    function getPassportAddress() public view returns(address){
        return etatCivil.getPassportAddress();
    }
   function getEtatCivilAddress() public view returns(address){
        return etatCivil.getAddress();
    }
    function getCityAddress() public view returns(address){
        return address(this);
    }
    function cascadeOnershipTransfert(address newowner)public onlyOwner onlyIfStarted returns(bool){
        emit IstherealownerOfCity(owner());
        emit IstherealownerOfCity(msg.sender);
        require(etatCivil.cascadeOnershipTransfert(newowner)==true);
        transferOwnership(newowner);
        emit IstherealownerOfCity(owner());
        return true;

    }
        

}