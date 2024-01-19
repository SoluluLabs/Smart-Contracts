// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, run } = require("hardhat");

async function main() {

  const Token = await ethers.getContractFactory("VirtualUSDT");
  console.log("Deploying VirtualUSDT...");
  const token = await ethers.deployContract(Token, ["Virtual USDT", "vUSDT", 45]);
  console.log("VirtualUSDT deployed to:", token.address);
  await token.deployed();

  console.log('Waiting for 30 sec to get the transaction mined...');
  await new Promise(resolve => setTimeout(resolve, 30000));
  await run('verify', {
    address: token.address,
  });

  console.log("VirtualUSDT deployed to:", token.address
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
