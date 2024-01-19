const { ethers, upgrades, run } = require("hardhat");

async function main() {
    const MyNFTImplementation = await ethers.getContractFactory("SoluluReward");
    console.log("Deploying MyNFTProxy...");

    // to upgrade already deployed contract
    // const myNFTProxy = await upgrades.upgradeProxy("0x5c9DA4CB89da2691774A69bA454f8cec378Ec4dd", MyNFTImplementation); // mumbai
    const myNFTProxy = await upgrades.upgradeProxy("0xCE6abFA91f4a482AB1168Fc56168c2bB14Bc627b", MyNFTImplementation); // bsc testnet
    // to deploy new contract
    // const myNFTProxy = await upgrades.deployProxy(MyNFTImplementation, ["0x03f74d68e4d861b43d740bf6145a5fb0b398e73d", "0x81CcBB87535864eD9F511f5196fc22deEd77a272"], { initializer: 'initialize' });
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
