const { ethers, upgrades, run } = require("hardhat");

async function main() {
  const MyNFTImplementation = await ethers.getContractFactory("SoluluAI");
  console.log("Deploying MyNFTProxy...");

  // to upgrade already deployed contract
  // const myNFTProxy = await upgrades.upgradeProxy("0xCE6abFA91f4a482AB1168Fc56168c2bB14Bc627b", MyNFTImplementation); // sepolia
  // const myNFTProxy = await upgrades.upgradeProxy("0xA9bE613402D1C293ffb22F02495fC342999EAAC6", MyNFTImplementation); // mumbai
  const myNFTProxy = await upgrades.upgradeProxy("0xf26c5a999CF2Ba1dFE87Ff0887E6A1d46721F17b", MyNFTImplementation); // bsc testnet

  // to deploy new contract
  // const myNFTProxy = await upgrades.deployProxy(MyNFTImplementation, ['https://api.solulu.ai/assets/bsc_testnet/'], { initializer: 'initialize' });
  await myNFTProxy.deployed();
  console.log("MyNFTProxy deployed to:", myNFTProxy.address);

  // await for 1 minutes to get the transaction mined
  console.log('Waiting for 30 sec to get the transaction mined...');
  await new Promise(resolve => setTimeout(resolve, 30000));
  // to verify contract on etherscan
  await run('verify', {
    address: myNFTProxy.address,
  });

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
