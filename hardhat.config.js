require('dotenv').config(); // Load environment variables from .env file
require('@openzeppelin/hardhat-upgrades');
require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-etherscan');
// require('hardhat-etherscan');
// This is a sample Hardhat task. To learn how to create your own, go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  // solidity: '0.8.22',
  defaultNetwork: 'testnet',
  networks: {
    hardhat: {},
    testnet: {
      url: process.env.RPC_URL, // Use the RPC URL from environment variable
      accounts: [process.env.PRIVATE_KEY], // Use the private key from environment variable
    },
    localhost: {
      url: "http://127.0.0.1:8545/",
      accounts: ["0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"]

    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY, // Replace with your Etherscan API key
  },
  solidity: {
    version: "0.8.22",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },

};
