<h1 align="center">🏞️City Weather NFT</h1>
This project is a smart contract for a dynamic NFT. The token starts as an Earth when initially minted. However, whenever the token is transferred to another address, it will randomly select a city and transform its appearance based on the weather conditions of that city.

    
## 💫Showcase
<p align="center">
    <img src="/metadata/earth_250.gif">
    <div align="center">Earth (Initial Minted)</div>
<p>
    
| Variants      | Clear         | Drizzle       | Rain | Thunderstorm |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| Taipei  | ![](/metadata/taipei-101_clear.gif) | ![](/metadata/taipei-101_drizzle.gif)  | ![](/metadata/taipei-101_rain.gif)  | ![](/metadata/taipei-101_thunderstorm.gif)  |
| Tokyo  | ![](/metadata/tokyo-skytree_clear_250.gif) | ![](/metadata/tokyo-skytree_drizzle_250.gif)  | ![](/metadata/tokyo-skytree_rain_250.gif)  | ![](/metadata/tokyo-skytree_thunderstorm_250.gif)  |


## 🚀Getting Started
1. Clone the project
    - `git clone https://github.com/leonasdev/city-weather-nft`
2. Install dependencies
    - `pnpm install`
3. Compile contracts
    - `pnpm compile`
4. Setting the `.env` file
    - Adjust values in `.env.example` and rename it to `.env`
5. Deploy contract to sepolia test network
    - `npx hardhat run scripts/deploy.ts --network sepolia`
6. Minting token
    - ```typescript
      const contractAddress = "0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"; // replace it with contract address
      const DNFT = await ethers.getContractFactory("CityWeatherNFT");
      const dnft = DNFT.attach(contractAddress);
      console.log("Minting...");
      await dnft.mint();
      console.log("Done.");
      ```
    - `npx hardhat run scripts/index.ts --network sepolia`
7. Checking your NFT
    - Import nft contract in Matamask to observe your NFT token
    - **Token ID must start with** `1`
8. Fund contract LINK token
    - See: https://docs.chain.link/resources/fund-your-contract#send-funds-to-your-contract
    - Funding `3` LINK should enough (can withdraw latter)
9. Transfer your NFT token to another accoount
10. Waitting for fulfillment
    - You can check status of request by:
      ```typescript
      const contractAddress = "0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"; // replace it with contract address
      const DNFT = await ethers.getContractFactory("CityWeatherNFT");
      const dnft = DNFT.attach(contractAddress);
      console.log("Last request status:");
      console.log(await dnft.s_requests(await dnft.requestIds(await dnft.lastRequestId())));
      ```
    - `npx hardhat run scripts/index.ts --network sepolia`
    - Wait `fulfilled` to `true`

11. Checking your NFT in another account
    - You need import NFT contract again in another account
12. Observe that NFT transform its appearance!
13. Withdraw your LINK token
    - ```typescript
      const contractAddress = "0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"; // replace it with contract address
      const DNFT = await ethers.getContractFactory("CityWeatherNFT");
      const dnft = DNFT.attach(contractAddress);
      await dnft.withdrawLink();
      ```
    - `npx hardhat run scripts/index.ts --network sepolia`

## 🛠️Tools used in this project
- [Sodility](https://docs.soliditylang.org/en/v0.8.20/)
    Solidity is an object-oriented, high-level language for implementing smart contracts. Smart contracts are programs that govern the behavior of accounts within the Ethereum state.
- [Sepolia Testnet](https://sepoliafaucet.com/)
    Sepolia was a proof-of-authority testnet created in October 2021 by Ethereum core developers and maintained ever since. 
- [Hardhat](https://hardhat.org)
    Hardhat is a development environment for Ethereum software. It consists of different components for editing, compiling, debugging and deploying your smart contracts and dApps, all of which work together to create a complete development environment.
- [OpenZeppelin Contracts](https://www.openzeppelin.com/contracts)
    OpenZeppelin Contracts helps you minimize risk by using battle-tested libraries of smart contracts for Ethereum and other blockchains. It includes the most used implementations of ERC standards.
- [Chainlink](https://chain.link/)
    - [Chainlink VRFv2](https://docs.chain.link/vrf/v2/introduction)
        Chainlink VRF provides cryptographically secure randomness for your blockchain-based applications.
    - [Chainlink Any API](https://docs.chain.link/any-api/introduction)
        Connecting to any API with Chainlink enables your contracts to access to any external data source through our decentralized oracle network. 
- [OpenWeatherAPI](https://openweathermap.org/)
    Access current weather data for any location including over 200,000 cities
- [IPFS](https://ipfs.tech/)
    A peer-to-peer hypermedia protocol designed to preserve and grow humanity's knowledge by making the web upgradeable, resilient, and more open.
- [Metamask](https://metamask.io/)
    Available as a browser extension and as a mobile app, MetaMask equips you with a key vault, secure login, token wallet, and token exchange—everything you need to manage your digital assets.
    
## ✅TODO
- [ ] Auto fund LINK token when deployed
