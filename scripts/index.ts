import { ethers } from "hardhat";

async function main() {
  const contractAddress = "0x76823eAb950502aa2f526BB938218B085cB9B571";
  const DNFT = await ethers.getContractFactory("CityWeatherNFT");
  const dnft = DNFT.attach(contractAddress);
  // await dnft.requestVolumeDate();
  // console.log("volume:", await dnft.volume());
  // console.log("Minting...");
  await dnft.mint();
  // console.log("Done.");
  // console.log(await dnft.lastRequestId());
  // console.log(await dnft.s_requests(await dnft.requestIds(1)));
  // await function() {
  //   return new Promise(resolve => setTimeout(resolve, 10000));
  // }();
  // console.log("latest token id:", await dnft.getLatestTokenId());
  // console.log("token uri:", await dnft.tokenURI(1));
  // const lastRequestId = await dnft.lastRequestId();
  // console.log(lastRequestId);
  // console.log((await dnft.s_requests(lastRequestId)).fufilled);
  await dnft.withdrawLink();

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
