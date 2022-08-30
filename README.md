# Minimistant

DAO for network City inspire by The Network State fom Balaji S. Srinivasan
https://thenetworkstate.com/

## Directory structure

```ml
lib
├─ forge-std — https://github.com/brockelmore/forge-std
├─ openzeppelin-contracts — https://github.com/OpenZeppelin/openzeppelin-contracts
src
├─ City.sol — "Network City interface implementation"
├─ EtatCivil.sol — "Registry for network City"
└─ Passport.sol — "non-transferable, burnable ERC721 use as passport for the City"
tests
└─ City.t.sol — "Test suite for the City"
```
## Todo
See Todo [here](TODO.md)

## Requirement
To get started we need to install the foundry package which requires rust.
```sh
curl -L https://foundry.paradigm.xyz | bash;
foundryup
```

### Unit test
```sh
forge install foundry-rs/forge-std
```

### Install the dependencies/libraries:
```sh
forge install openzeppelin/openzeppelin-contracts
git submodule update --init --recursive
forge install
```
### UI
```sh
npm install web3 --save
```
