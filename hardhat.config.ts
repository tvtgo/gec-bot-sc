import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-etherscan'
import '@nomiclabs/hardhat-waffle'
import 'hardhat-typechain'
import 'hardhat-watcher'

import * as dotenv from 'dotenv'
dotenv.config()

const config = {

  defaultNetwork: "test",

  networks: {
    hardhat: {
    },
    test: {
      url: "https://api.avax-test.network/ext/C/rpc",
      // @ts-ignore
      accounts: [process.env.PRIVATE_KEY],
    },
    bnb: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      // @ts-ignore
      accounts: [process.env.PRIVATE_KEY],
    },
    live: {
      url: "https://api.avax.network/ext/bc/C/rpc",
      // @ts-ignore
      accounts: [process.env.PRIVATE_KEY],
    }
  },
  solidity: {
    compilers: [
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.8.1",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        },
      },
      {
        version: "0.8.2",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        },
      },
    ],
  },
};

export default config;
