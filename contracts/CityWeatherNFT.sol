// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract CityWeatherNFT is
    ERC721URIStorage,
    ChainlinkClient,
    VRFV2WrapperConsumerBase,
    ConfirmedOwner
{
    using Chainlink for Chainlink.Request;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    address private immutable oracle;
    bytes32 private immutable jobId;
    uint256 private immutable fee;

    event RequestWeatherFulfilled(string data);
    event RequestRandomnessSent(uint256 requestIds, uint32 numWords);
    event RequestRandomnessFulfilled(
        uint256 requestId,
        uint256[] randomWords,
        uint payment
    );

    // string[] IpfsURI = [
    //     "https://ipfs.io/ipfs/QmYPmv89quwqfEHkdtcQUkYpzAe7HNufCGt19dhA8ijsVa?filename=clear.json",
    //     "https://ipfs.io/ipfs/QmPamCAopJERLiDUFWWGi52KUNHigpBrYchbqet1YN9Fr9?filename=drizzle.json",
    //     "https://ipfs.io/ipfs/QmUaVVdfxe55zL5SJtrTnkrg4u58XTBnmuACtUiKRTiuSm?filename=rain.json",
    //     "https://ipfs.io/ipfs/QmTS9iPxiaY7YRE8A6rKf5ty5zHdZ2n6DMyCJTS8nTM6t2?filename=thunderstorm.json"
    // ];
    string EarthURI =
        "https://raw.githubusercontent.com/leonasdev/city-weather-nft/master/metadata/earth.json";

    string[] private cities = ["Taipei", "Tokyo"];
    string[] private weathers = ["Clear", "Drizzle", "Rain", "Thunderstorm"];

    mapping(string => string) private _weatherToWeather;
    mapping(string => mapping(string => string)) private _weatherToURI;

    mapping(uint256 => uint256) public requestIdToTokenId;
    mapping(bytes32 => uint256) public requestAPIIdToRequestRandomId;
    mapping(uint256 => string) public tokenIdToCity;

    struct RequestStatus {
        uint256 paid;
        bool fulfilled;
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.uint256
    uint32 callbackGasLimit = 1000000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFV2Wrapper.getConfig().maxNumWords.
    uint32 numWords = 1;

    // Address LINK - hardcoded for Sepolia
    address linkAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    // address WRAPPER - hardcoded for Sepolia
    address wrapperAddress = 0xab18414CD93297B0d12ac29E63Ca20f515b3DB46;

    constructor()
        ERC721("CityWeatherNFT", "CWNFT")
        ConfirmedOwner(msg.sender)
        VRFV2WrapperConsumerBase(linkAddress, wrapperAddress)
    {
        setChainlinkToken(linkAddress);
        oracle = 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD;

        // GET>string jobid: 7d80a6386ef543a3abb52817f6707e3b
        // https://docs.chain.link/any-api/testnet-oracles/#jobs
        jobId = "7d80a6386ef543a3abb52817f6707e3b";

        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)

        initMappings();
    }

    //     "https://ipfs.io/ipfs/QmYPmv89quwqfEHkdtcQUkYpzAe7HNufCGt19dhA8ijsVa?filename=clear.json",
    //     "https://ipfs.io/ipfs/QmPamCAopJERLiDUFWWGi52KUNHigpBrYchbqet1YN9Fr9?filename=drizzle.json",
    //     "https://ipfs.io/ipfs/QmUaVVdfxe55zL5SJtrTnkrg4u58XTBnmuACtUiKRTiuSm?filename=rain.json",
    //     "https://ipfs.io/ipfs/QmTS9iPxiaY7YRE8A6rKf5ty5zHdZ2n6DMyCJTS8nTM6t2?filename=thunderstorm.json"
    function initMappings() private {
        // using mock metadata, should using metadata which on ipfs
        _weatherToURI["Taipei"][
            "Clear"
        ] = "https://raw.githubusercontent.com/leonasdev/city-weather-nft/master/metadata/taipei_clear.json";
        _weatherToURI["Taipei"][
            "Drizzle"
        ] = "https://raw.githubusercontent.com/leonasdev/city-weather-nft/master/metadata/taipei_drizzle.json";
        _weatherToURI["Taipei"][
            "Rain"
        ] = "https://raw.githubusercontent.com/leonasdev/city-weather-nft/master/metadata/taipei_rain.json";
        _weatherToURI["Taipei"][
            "Thunderstorm"
        ] = "https://raw.githubusercontent.com/leonasdev/city-weather-nft/master/metadata/taipei_thunderstorm.json";

        _weatherToURI["Tokyo"][
            "Clear"
        ] = "https://raw.githubusercontent.com/leonasdev/city-weather-nft/master/metadata/tokyo_clear.json";
        _weatherToURI["Tokyo"][
            "Drizzle"
        ] = "https://raw.githubusercontent.com/leonasdev/city-weather-nft/master/metadata/tokyo_drizzle.json";
        _weatherToURI["Tokyo"][
            "Rain"
        ] = "https://raw.githubusercontent.com/leonasdev/city-weather-nft/master/metadata/tokyo_rain.json";
        _weatherToURI["Tokyo"][
            "Thunderstorm"
        ] = "https://raw.githubusercontent.com/leonasdev/city-weather-nft/master/metadata/tokyo_thunderstorm.json";

        _weatherToWeather["Clear"] = "Clear";
        _weatherToWeather["Clouds"] = "Clear";
        _weatherToWeather["Drizzle"] = "Drizzle";
        _weatherToWeather["Atmosphere"] = "Drizzle";
        _weatherToWeather["Rain"] = "Rain";
        _weatherToWeather["Thunderstorm"] = "Thunderstorm";
        _weatherToWeather["Snow"] = "Thunderstorm";
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, EarthURI);
        tokenIdToCity[newItemId] = "Earth";
    }

    function requestWeatherAPI(string memory city) public returns (bytes32) {
        Chainlink.Request memory request = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        // using mock api
        // should change to realworld api (e.g. openweather api)
        string memory api = string.concat(
            "https://647d73dbaf9847108549b49c.mockapi.io/api/",
            city,
            "/1"
        );

        request.add("get", api);

        // Set the path to find the desired data in the API response, where the response format is:
        // { "weather":[{
        //         "id":
        //         "main": "Clouds",
        //         "description": "broken clouds"
        //     }]
        // }
        request.add("path", "weather,0,main");

        bytes32 requestId = sendChainlinkRequestTo(oracle, request, fee);
        return requestId;
    }

    function requestCityAndWeather() public returns (uint256) {
        uint256 requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestRandomnessSent(requestId, numWords);
        return requestId;
    }

    /**
     * Recive the response in the form of string
     */
    function fulfill(
        bytes32 _requestId,
        string memory _volume
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestWeatherFulfilled(_volume);

        uint256 requestRandomId = requestAPIIdToRequestRandomId[_requestId];

        string memory weather = _weatherToWeather[_volume];

        uint256 tokenId = requestIdToTokenId[requestRandomId];
        string memory newURI = _weatherToURI[tokenIdToCity[tokenId]][weather];
        _setTokenURI(tokenId, newURI);
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestRandomnessFulfilled(
            _requestId,
            _randomWords,
            s_requests[_requestId].paid
        );

        string memory city = cities[_randomWords[0] % cities.length];
        uint256 tokenId = requestIdToTokenId[_requestId];
        tokenIdToCity[tokenId] = city;

        bytes32 requestAPIId = requestWeatherAPI(city);
        requestAPIIdToRequestRandomId[requestAPIId] = _requestId;
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
        uint256 requestId = requestCityAndWeather();
        requestIdToTokenId[requestId] = tokenId;
        _transfer(from, to, tokenId);
    }
}
