const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Land token MVP flow", function () {
  it("sells shares and distributes variable profit", async function () {
    const [admin, landOwner, buyer] = await ethers.getSigners();

    const MockUSDC = await ethers.getContractFactory("MockUSDC");
    const usdc = await MockUSDC.deploy(admin.address, 5_000_000_000);
    await usdc.waitForDeployment();

    const LandOwnerRegistry = await ethers.getContractFactory("LandOwnerRegistry");
    const registry = await LandOwnerRegistry.deploy(admin.address);
    await registry.waitForDeployment();

    const LandOfferingFactory = await ethers.getContractFactory("LandOfferingFactory");
    const factory = await LandOfferingFactory.deploy(
      await registry.getAddress(),
      await usdc.getAddress(),
      admin.address
    );
    await factory.waitForDeployment();

    const registerTx = await registry
      .connect(landOwner)
      .registerOwner(
        landOwner.address,
        "ipfs://plot-001",
        "cassava",
        90
      );
    const registerReceipt = await registerTx.wait();
    const ownerId = registerReceipt.logs[0].args.ownerId;

    await registry.connect(admin).approveOwner(ownerId);

    const createTx = await factory.createOffering(
      ownerId,
      "Plot One",
      "PLOT1",
      "ipfs://plot-001",
      1_000_000,
      10_000
    );
    const createReceipt = await createTx.wait();
    const offeringId = createReceipt.logs[0].args.offeringId;
    const offering = await factory.getOffering(offeringId);

    const offeringContract = await ethers.getContractAt("LandOffering", offering.offering);
    const token = await ethers.getContractAt("LandShareToken", offering.token);
    const distributor = await ethers.getContractAt(
      "ProfitDistributor",
      offering.distributor
    );

    await usdc.transfer(buyer.address, 50_000_000);
    await usdc.connect(buyer).approve(offeringContract.getAddress(), 50_000_000);
    await offeringContract.connect(buyer).buyShares(2_000);

    expect(await token.balanceOf(buyer.address)).to.equal(2_000);
    expect(await usdc.balanceOf(landOwner.address)).to.equal(20_000_000);

    await usdc.connect(landOwner).approve(distributor.getAddress(), 20_000_000);
    await distributor.connect(landOwner).fundPayout(20_000_000);
    await distributor.connect(buyer).claim();

    expect(await usdc.balanceOf(buyer.address)).to.equal(50_000_000);
  });
});
