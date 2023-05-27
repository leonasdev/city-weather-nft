import { ethers } from "hardhat";

async function main() {
  const contractAddress = "0x322813Fd9A801c5507c9de605d63CEA4f2CE6c44";
  const DNFT = await ethers.getContractFactory("TaipeiWeatherNFT");
  const dnft = DNFT.attach(contractAddress);
  console.log(
    "dnft current balance: ",
    (await dnft.balanceOf("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266")).toString(),
  );

  console.log(await dnft.tokenURI(0));
  // await dnft.awardItem(
  //   "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
  //   "https://ipfs.io/ipfs/QmYPmv89quwqfEHkdtcQUkYpzAe7HNufCGt19dhA8ijsVa",
  // );
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
