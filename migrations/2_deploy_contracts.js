const PegaxyNftStaking = artifacts.require("PegaxyNftStaking");

module.exports = async function(deployer) {
  await deployer.deploy(PegaxyNftStaking);
};
