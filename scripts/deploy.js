const hre = require('hardhat')

async function main() {
  // const [deployer] = await hre.ethers.getSigners();
  // console.log("Deploying contracts with the account:", deployer.address);

  const StakingContract = await hre.ethers.getContractFactory('PegaxyNftStaking');
  const stakingContract = await StakingContract.deploy(
    //pegaxy contract
    '0xD50D167DD35D256e19E2FB76d6b9Bf9F4c571A3E',
    //Reward token: VIS
    '0xcC1B9517460D8aE86fe576f614d091fCa65a28Fc'
  );

  console.log('Staking contract address:', stakingContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
