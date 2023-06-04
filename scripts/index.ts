import { ethers } from "hardhat";

async function main() {
  const contractAddress = "0x1E7A8B89273bF76bf1F102aC668d1bd464d8c815";
  const DNFT = await ethers.getContractFactory("TaipeiWeatherNFT");
  const dnft = DNFT.attach(contractAddress);
  // await dnft.requestVolumeDate();
  // console.log("volume:", await dnft.volume());
  console.log("createCollectible...");
  console.log("token id:", await dnft.createCollectible());
  console.log("Done.");
  // await function() {
  //   return new Promise(resolve => setTimeout(resolve, 10000));
  // }();
  // console.log("latest token id:", await dnft.getLatestTokenId());
  // console.log("token uri:", await dnft.tokenURI(1));

  // console.log(
  //   "dnft current balance: ",
  //   (await dnft.balanceOf("0xB5737395782D5C299EA23Fddd8049e95304c91eC")).toString(),
  // );
  //
  // console.log(await dnft.tokenURI(0));
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
