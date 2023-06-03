import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { LinkTokenInterface__factory } from "../typechain-types";

task("fund-links", "Funds a contract with LINK")
  .addParam("contract", "The address of the contract")
  .setAction(
    async (taskArags: TaskArguments, hre: HardhatRuntimeEnvironment): Promise<void> => {
      const contractAddr: string = taskArags.contract;
      const linkTokenAddress = "0x779877A7B0D9E8603169DdbD7836e478b4624789"; // The LINK token on Sepolia
      const fundAmount = "100000000000000000"; // 0,1 * 10 ** 18

      const accounts = await hre.ethers.getSigners();
      const signer = accounts[0];

      const linkTokenContract = new hre.ethers.Contract(
        linkTokenAddress,
        LinkTokenInterface__factory.createInterface(),
        signer,
      );

      try {
        const transferTransaction = await linkTokenContract.transfer(
          contractAddr,
          fundAmount,
        );

        await transferTransaction.wait(1);

        console.log("Successfully transfer LINK.");
        console.log("amount: ", fundAmount.toString());
        console.log("transactionHash: ", transferTransaction.hash);
      } catch (_) {
        throw new Error("Transfer LINK failed.");
      }
    },
  );
