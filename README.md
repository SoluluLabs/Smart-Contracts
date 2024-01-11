# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```

to run the hardhat console
```shell
npx hardhat console --network testnet
```

run the command to run deployProxy.js file -
```shell
npx hardhat run scripts/deployProxy.js --network testnet 
```

if contract is not getting verified automatically then - 
```shell
npx hardhat verify 0x37CCf694ec49e707377e44fEbd06A53215cD161a --network testnet
```