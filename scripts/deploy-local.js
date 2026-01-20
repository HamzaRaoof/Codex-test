const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  const MockUSDC = await ethers.getContractFactory("MockUSDC");
  const usdc = await MockUSDC.deploy(deployer.address, 5_000_000_000);
  await usdc.waitForDeployment();

  const LandOwnerRegistry = await ethers.getContractFactory("LandOwnerRegistry");
  const registry = await LandOwnerRegistry.deploy(deployer.address);
  await registry.waitForDeployment();

  const LandOfferingFactory = await ethers.getContractFactory("LandOfferingFactory");
  const factory = await LandOfferingFactory.deploy(
    await registry.getAddress(),
    await usdc.getAddress(),
    deployer.address
  );
  await factory.waitForDeployment();

  console.log("Deployer:", deployer.address);
  console.log("MockUSDC:", await usdc.getAddress());
  console.log("LandOwnerRegistry:", await registry.getAddress());
  console.log("LandOfferingFactory:", await factory.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
