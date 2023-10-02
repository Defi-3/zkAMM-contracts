import { ethers } from "hardhat";

async function main() {
  const owner = "0x1956b2c4C511FDDd9443f50b36C4597D10cD9985";
  const wethAddress = "0x1b3631A99A69275bC7E3b539FeD4DaAFaDDfe1B0";
  const wbtcAddress = "0x7aBF19CE8696A1D8945F9125758EbCe2F6F0Fd91";
  const zkAmmPairAddress = "0x8aA6B0E10BD6DBaf5159967F92f2E740afE2b4C3";

  const wbtc = await ethers.getContractAt("MockToken", wbtcAddress);
  const weth = await ethers.getContractAt("MockToken", wethAddress);
  const zkAmmPair = await ethers.getContractAt("ZkAmmPair", zkAmmPairAddress);

  await wbtc.approve(zkAmmPairAddress, BigInt("100000000000000000000000000"));
  await weth.approve(zkAmmPairAddress, BigInt("100000000000000000000000000"));

  // let tx = await zkAmmPair.addInitLiquidity(
  //   owner,
  //   BigInt("160000000000000000000"),
  //   BigInt("10000000000000000000")
  // );
  // await tx.wait();
  // console.log("addInitLiquidity finish");

  await zkAmmPair.addLiquidity(owner, BigInt("20000000000000000000"));
  console.log("addLiquidity finish");

  // await zkAmmPair.swap(owner, true, BigInt("100000000000000000"));
  // console.log("swap finish");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
