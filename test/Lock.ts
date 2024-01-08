import { ethers } from "hardhat";

const { expect } = require("chai");

describe("MyToken", function () {
  let MyToken;
  let myToken;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    MyToken = await ethers.getContractFactory("SoluluX");
    myToken = await MyToken.deploy();
    // await myToken.deployed();
  });

  it("Should mint a new token with correct URI and transfer it", async function () {
    const uri = "https://example.com/token/1";
    await myToken.safeMint(addr1.address, uri, 5, { value: ethers.utils.parseEther("5") });
    const tokenId = await myToken.tokenByIndex(0);
    expect(await myToken.tokenURI(tokenId)).to.equal(uri);

    // Transfer the token from addr1 to addr2
    await myToken.transferFrom(addr1.address, addr2.address, tokenId);
    expect(await myToken.ownerOf(tokenId)).to.equal(addr2.address);
  });

  it("Should revert when minting with insufficient fee", async function () {
    const uri = "https://example.com/token/2";
    await expect(myToken.safeMint(addr1.address, uri, 5, { value: ethers.utils.parseEther("4") }))
      .to.be.revertedWith("Insufficient minting fee");
  });

  it("Should revert when setting royalty percentage over 10%", async function () {
    const uri = "https://example.com/token/3";
    await expect(myToken.safeMint(addr1.address, uri, 11, { value: ethers.utils.parseEther("5") }))
      .to.be.revertedWith("Max royalty percentage is 10%");
  });

  // Add more test cases as needed
});
