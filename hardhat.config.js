require("@nomiclabs/hardhat-ethers");

module.exports = {
  defaultNetwork: "matic",
  networks: {
    hardhat: {
    },
    matic: {
      url: "https://polygon-mainnet.g.alchemy.com/v2/Dv5PEk3tuO3kXz164Apcz2o0aInyqx_D",
      accounts: ['0x8c4278d0dccb59040f7efea5e79c60f632f25a0c74773187c842a3195257b761']
    }
  },
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
}