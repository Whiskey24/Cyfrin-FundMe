// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// setup datafeed from chainlink
// https://docs.chain.link/data-feeds
// https://docs.chain.link/data-feeds/getting-started
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    /**
     * https://docs.chain.link/data-feeds/price-feeds/addresses?page=1&testnetPage=1
     * Network: Sepolia Testnet
     * Aggregator: ETH/USD
     * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     */

     // Feed on ZKsync 0x6D41d1dc818112880b40e26BD6FD347E41008eDA

    function getDataFeedVersion() internal view returns (uint256) {
        return
            AggregatorV3Interface(0x6D41d1dc818112880b40e26BD6FD347E41008eDA)
                .version();
    }

    function getNormalizedPrice() internal view returns (uint256) {
        (, int256 price, , , ) = AggregatorV3Interface(
            0x6D41d1dc818112880b40e26BD6FD347E41008eDA
        ).latestRoundData();
        require(price > 0, "Invalid price");
        uint8 decimals = AggregatorV3Interface(
            0x6D41d1dc818112880b40e26BD6FD347E41008eDA
        ).decimals();

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
