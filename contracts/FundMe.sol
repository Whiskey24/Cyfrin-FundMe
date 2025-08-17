// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// setup datafeed from chainlink
// https://docs.chain.link/data-feeds

// https://docs.chain.link/data-feeds/getting-started
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    AggregatorV3Interface internal dataFeed;

    /**
     * https://docs.chain.link/data-feeds/price-feeds/addresses?page=1&testnetPage=1
     * Network: Sepolia Testnet
     * Aggregator: ETH/USD
     * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     */
    constructor() {
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }

    function getDataFeedVersion() public view returns (uint256) {
        return dataFeed.version();
    }

    function getNormalizedPrice() public view returns (uint256) {
        (, int256 price, , , ) = dataFeed.latestRoundData();
        require(price > 0, "Invalid price");
        uint8 decimals = dataFeed.decimals();

        // Scale the price to 18 decimals
        return (uint256(price) * 1e18) / (10**uint256(decimals));
    }

    function getConversionRate(uint256 ethAmountWei)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getNormalizedPrice(); // ETH/USD in 18 decimals
        // ethAmountWei is also 18 decimals (wei)
        uint256 ethAmountInUsd = (ethAmountWei * ethPrice) / 1e18;
        return ethAmountInUsd; // returns USD value in 18 decimals
    }
}
