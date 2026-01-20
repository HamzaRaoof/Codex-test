const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  const usdcAddress = process.env.USDC_ADDRESS;

  if (!usdcAddress) {
    throw new Error("USDC_ADDRESS env var required");
  }

  const LandOwnerRegistry = await ethers.getContractFactory("LandOwnerRegistry");
  const registry = await LandOwnerRegistry.deploy(deployer.address);
  await registry.waitForDeployment();

  const LandOfferingFactory = await ethers.getContractFactory("LandOfferingFactory");
  const factory = await LandOfferingFactory.deploy(
    await registry.getAddress(),
    usdcAddress,
    deployer.address
  );
  await factory.waitForDeployment();

  console.log("Deployer:", deployer.address);
  console.log("LandOwnerRegistry:", await registry.getAddress());
  console.log("LandOfferingFactory:", await factory.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
