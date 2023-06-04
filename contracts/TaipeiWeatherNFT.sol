// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract TaipeiWeatherNFT is ERC721URIStorage, ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    string public volume;
    address private immutable oracle;
    bytes32 private immutable jobId;
    uint256 private immutable fee;

    event DataFulfilled(string volume);

    enum EigenValue {
        CLEAR,
        DRIZZLE,
        RAIN,
        THUNDERSTORM
    }

    // string[] IpfsURI = [
    //     "https://ipfs.io/ipfs/QmYPmv89quwqfEHkdtcQUkYpzAe7HNufCGt19dhA8ijsVa?filename=clear.json",
    //     "https://ipfs.io/ipfs/QmPamCAopJERLiDUFWWGi52KUNHigpBrYchbqet1YN9Fr9?filename=drizzle.json",
    //     "https://ipfs.io/ipfs/QmUaVVdfxe55zL5SJtrTnkrg4u58XTBnmuACtUiKRTiuSm?filename=rain.json",
    //     "https://ipfs.io/ipfs/QmTS9iPxiaY7YRE8A6rKf5ty5zHdZ2n6DMyCJTS8nTM6t2?filename=thunderstorm.json"
    // ];
    string[] TaipeiURIs = [
        "https://raw.githubusercontent.com/leonasdev/taipei-weather-dnft/master/metadata/taipei_clear.json",
        "https://raw.githubusercontent.com/leonasdev/taipei-weather-dnft/master/metadata/taipei_drizzle.json",
        "https://raw.githubusercontent.com/leonasdev/taipei-weather-dnft/master/metadata/taipei_rain.json",
        "https://raw.githubusercontent.com/leonasdev/taipei-weather-dnft/master/metadata/taipei_thunderstorm.json"
    ];

    string[] TokyoURIs = [
        "https://raw.githubusercontent.com/leonasdev/taipei-weather-dnft/master/metadata/tokyo_clear.json",
        "https://raw.githubusercontent.com/leonasdev/taipei-weather-dnft/master/metadata/tokyo_drizzle.json",
        "https://raw.githubusercontent.com/leonasdev/taipei-weather-dnft/master/metadata/tokyo_rain.json",
        "https://raw.githubusercontent.com/leonasdev/taipei-weather-dnft/master/metadata/tokyo_thunderstorm.json"
    ];

    mapping(uint256 => EigenValue) public tokenIdToEigenValue;
    mapping(bytes32 => uint256) public requestIdToTokenId;

    constructor()
        ERC721("TaipeiWeatherNFT", "TWNFT")
        ConfirmedOwner(msg.sender)
    {
        setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
        oracle = 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD;

        // GET>string jobid: 7d80a6386ef543a3abb52817f6707e3b
        // https://docs.chain.link/any-api/testnet-oracles/#jobs
        jobId = "7d80a6386ef543a3abb52817f6707e3b";

        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    function createCollectible() public {
        _tokenIds.increment();
        string memory initURI = IpfsURI[1];
        EigenValue initEigenValue = EigenValue(1);

        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, initURI);
        tokenIdToEigenValue[newItemId] = initEigenValue;
    }

    function requestVolumeDate() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        request.add(
            "get",
            "https://api.openweathermap.org/data/2.5/weather?q=Taipei&appid=c83dc7bf353d67780d200a1902a2f587"
        );

        // Set the path to find the desired data in the API response, where the response format is:
        // { "weather":[{
        //         "id":
        //         "main": "Clouds",
        //         "description": "broken clouds"
        //     }]
        // }
        request.add("path", "weather,0,main");

        bytes32 _requestId = sendChainlinkRequestTo(oracle, request, fee);

        requestIdToTokenId[_requestId] = _tokenIds.current();

        return _requestId;
    }

    /**
     * Recive the response in the form of string
     */
    function fulfill(
        bytes32 _requestId,
        string memory _volume
    ) public recordChainlinkFulfillment(_requestId) {
        volume = _volume;
        emit DataFulfilled(volume);

        if (equals(_volume, "Clouds")) {
            uint256 _tokenId = requestIdToTokenId[_requestId];
            EigenValue newEigenValue = EigenValue(2);
            string memory newURI = IpfsURI[2];
            tokenIdToEigenValue[_tokenId] = newEigenValue;
            _setTokenURI(_tokenId, newURI);
        }
    }

    /**
     * Allow withdraw of LINK tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function getLatestTokenId() public view returns (uint256) {
        return _tokenIds.current();
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721) {
        bytes32 requestId = requestVolumeDate();
        requestIdToTokenId[requestId] = tokenId;
        _transfer(from, to, tokenId);
    }

    function awardItem(
        address player,
        string memory tokenURI
    ) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }

    function equals(
        string memory a,
        string memory b
    ) private pure returns (bool) {
        if (bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return
                keccak256(abi.encodePacked(a)) ==
                keccak256(abi.encodePacked(b));
        }
    }
}
