const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("SoluluReward", function () {
    let owner;
    let user;
    let soluluReward;
    let erc20

    let contractAddress;

    let tokenAddress

    before(async function () {
        [owner, user] = await ethers.getSigners();

        user = owner

        const SoluluReward = await ethers.getContractFactory("SoluluReward");
        const Erc20 = await ethers.getContractFactory("VirtualUSDT");


        erc20 = await Erc20.deploy("Virtual USDT", "USDT", 18);

        tokenAddress = erc20.address

        await erc20.deployed();
        soluluReward = await upgrades.deployProxy(SoluluReward, ["0x70997970C51812dc3A010C7d01b50e0d17dc79C8", "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"], {
            initializer: 'initialize'
        });

        contractAddress = soluluReward.address

        await soluluReward.deployed();
    });

    it("Approve token", async function () {
        await erc20.connect(user).approve(contractAddress, 10000)

    });

    it("set Approved Token Addresses ", async function () {
        await soluluReward.connect(user).setApprovedTokenAddresses([tokenAddress], [true])
    });

    it("Check Approved Token Addresses ", async function () {
        const result = await soluluReward.connect(user).isApprovedTokenAddress(tokenAddress)
        expect(result).to.equal(true)
    });

    it("should deposit tokens", async function () {
        const amount = 10
        await expect(soluluReward.connect(user).deposit(tokenAddress, amount))
    });

    it("should update rewards", async function () {
        const addresses = [user.address];
        const values = [20]; // in ether
        await expect(soluluReward.connect(owner).updateReward(addresses, values))
    });

    it("should claim rewards", async function () {
        const amount = 10 // in wei

        await expect(soluluReward.connect(user).claimReward(amount))
        // Additional assertions if needed
    });

    it("should withdraw tokens", async function () {
        const amount = 10 // in wei
        await expect(soluluReward.connect(owner).withdraw(tokenAddress, amount))
    });

    it("should withdraw ETH", async function () {
        const balanceBefore = await ethers.provider.getBalance(soluluReward.address);

        if(balanceBefore == 0) {
            return; // Nothing to withdraw
        }

        await expect(soluluReward.connect(owner).withdrawETH())

        const balanceAfter = await ethers.provider.getBalance(soluluReward.address);
        expect(balanceAfter).to.equal(0); // All ETH should be withdrawn

    });


});
