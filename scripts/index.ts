import { ethers } from "hardhat";

async function main() {
  const contractAddress = "0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"; // replace it with contract address
  const DNFT = await ethers.getContractFactory("CityWeatherNFT");
  const dnft = DNFT.attach(contractAddress);
  console.log("Minting...");
  await dnft.mint();
  console.log("Done.");

  // console.log("Last request status:");
  // console.log(await dnft.s_requests(await dnft.requestIds(await dnft.lastRequestId())));

  // await dnft.withdrawLink();
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
