// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//import {PriceConverter} from "../libraries/PriceConverter.sol";
//import {PriceConverter} from "./PriceConverter.sol";

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    /**
     * https://docs.chain.link/data-feeds/price-feeds/addresses?page=1&testnetPage=1
     * Network: Sepolia Testnet
     * Aggregator: ETH/USD
     * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     */

     // Feed on ZKsync test net 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF

    function getDataFeedVersion() internal view returns (uint256) {
        return
            AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF)
                .version();
    }

    function getNormalizedPrice() internal view returns (uint256) {
        (, int256 price, , , ) = AggregatorV3Interface(
            0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF
        ).latestRoundData();
        require(price > 0, "Invalid price");
        uint8 decimals = AggregatorV3Interface(
            0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF
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

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }
    
    function version() public view returns (uint256) {
        return PriceConverter.getDataFeedVersion();
    }

    function price() public view returns (uint256) {
        return PriceConverter.getNormalizedPrice();
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "Didn't send enough ETH"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner{
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            // payable(address(funders[funderIndex])).transfer(
            //     addressToAmountFunded[funders[funderIndex]]
            // );
            addressToAmountFunded[funders[funderIndex]] = 0;
        }
        funders = new address[](0);

        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "FundMe__NotOwner");
        if (msg.sender != i_owner) {revert NotOwner();}
        _;
    }

    receive() external payable { 
        fund();
    }

    fallback() external payable {
        fund();
    }
}
