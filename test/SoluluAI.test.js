const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("SoluluAI", function () {
    let owner;
    let user;
    let soluluAI;

    before(async function () {
        [owner, user] = await ethers.getSigners();

        user = owner

        const SoluluAI = await ethers.getContractFactory("SoluluAI");
        soluluAI = await upgrades.deployProxy(SoluluAI, ["https://api.solulu.ai/eth/"], {
            initializer: 'initialize'
        });
        await soluluAI.deployed();
    });

    it("Before: check mint price and if public minting is open and treasory address", async function () {
        const isOpen = await soluluAI.isPublicOpen()
        const price = await soluluAI.mintPrice()
        const treasury = await soluluAI.treasury()
        console.log("price", price.toString())
        console.log("isPublicOpen", isOpen)
        console.log("treasury", treasury)
    });

    it("should set prices", async function () {
        const newPrice = 100; // 100 wei
        await expect(soluluAI.connect(owner).setPrices(newPrice))
        await new Promise(resolve => setTimeout(resolve, 100));
    });


    it("should set is public open", async function () {

        await soluluAI.connect(owner).setIsPublicOpen();
        await new Promise(resolve => setTimeout(resolve, 100));
    });

    it("should mint tokens", async function () {
        const royaltyPercentage = 500; // 5% royalty
        const characterId = "charId";
        const isOpen = await soluluAI.isPublicOpen()
        const mintPrice = await soluluAI.mintPrice()
        console.log(isOpen)
        if (!isOpen) {
            return; // Skip test if public minting is not open
        }
        await soluluAI.connect(user).mint(royaltyPercentage, characterId, { value: mintPrice })
        await new Promise(resolve => setTimeout(resolve, 100));
        // await expect(soluluAI.connect(user).mint(royaltyPercentage, characterId, {nonce:nonce+1}))
    });

    it("should set base URI", async function () {
        const newBaseURI = "https://new-base-uri.com/";
        await soluluAI.connect(owner).setBaseURI(newBaseURI)
        await new Promise(resolve => setTimeout(resolve, 100));
        // await expect(soluluAI.connect(owner).setBaseURI(newBaseURI))
    });

    it("should set treasury", async function () {
        const newTreasury = await ethers.Wallet.createRandom().address;
        await soluluAI.connect(owner).setTreasury(newTreasury)
        await new Promise(resolve => setTimeout(resolve, 100));
        // await expect(soluluAI.connect(owner).setTreasury(newTreasury))
    });

    it("should withdraw ETH", async function () {
        const balanceBefore = await ethers.provider.getBalance(soluluAI.address);
        if (balanceBefore == 0) {
            console.log("Nothing to withdraw")
            return; // Skip test if no ETH to withdraw
        }
        console.log("withdrawing eth", balanceBefore)
        await expect(soluluAI.connect(owner).withdraw())
        await new Promise(resolve => setTimeout(resolve, 100));
        const balanceAfter = await ethers.provider.getBalance(soluluAI.address);
        expect(balanceAfter).to.equal(0);
    });

    it("Get Token URI", async function () {
        const tokenId = 1;
        const _tokenUri = await soluluAI.tokenURI(tokenId);
        console.log(_tokenUri)
    })

    it("After: check mint price and if public minting is open and treasory address", async function () {

        const [isOpen, price, treasury, totalSupply] = await Promise.all([
            soluluAI.isPublicOpen(), soluluAI.mintPrice(), soluluAI.treasury(), soluluAI.totalSupply()
        ])

        console.log("price", price.toString())
        console.log("isPublicOpen", isOpen)
        console.log("treasury", treasury)
        console.log("totalSupply", totalSupply.toString())

        
    });

});
