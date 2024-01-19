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
  defaultNetwork: 'mumbai',
  networks: {
    hardhat: {},
    mumbai: {
      url: process.env.MUMBAI_RPC_URL, // Use the RPC URL from environment variable
      accounts: [process.env.PRIVATE_KEY], // Use the private key from environment variable
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    bsc_testnet: {
      url: process.env.BSC_TESTNET_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    localhost: {
      url: process.env.LOCALHOST_RPC_URL,
      accounts: [process.env.TEST_KEY] // test
    }
  },
  etherscan: {
    // apiKey: process.env.SEPOLIA_API_KEY, 
    // apiKey: process.env.MUMBAI_API_KEY,
    apiKey: process.env.BSC_TESTNET_API_KEY
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
