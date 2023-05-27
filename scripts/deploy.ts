import { ethers } from "hardhat";

async function main() {
  const DNFT = await ethers.getContractFactory("TaipeiWeatherNFT");
  const dnft = await DNFT.deploy();
  await dnft.deployed();
  console.log(dnft.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
