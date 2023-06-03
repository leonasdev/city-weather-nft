import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  const DNFT = await ethers.getContractFactory("TaipeiWeatherNFT");
  const dnft = await DNFT.deploy();
  await dnft.deployed();
  console.log("Contract has successfully depolyed");
  console.log("Contract Address:", dnft.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
