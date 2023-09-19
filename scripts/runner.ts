import { ethers } from "hardhat";

async function main() {
  const wbtcAddress = "";
  const wethAddress = "";
  const zkAmmPairAddress = "";

  const wbtc = await ethers.getContractAt("MockToken", wbtcAddress);
  const weth = await ethers.getContractAt("MockToken", wethAddress);
  const zkAmmPair = await ethers.getContractAt("ZkAmmPair", zkAmmPairAddress);

  await wbtc.approve(zkAmmPairAddress, BigInt("100000000000000000000000000"));
  await weth.approve(zkAmmPairAddress, BigInt("100000000000000000000000000"));

  let loop = true;
  while (loop) {}
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
