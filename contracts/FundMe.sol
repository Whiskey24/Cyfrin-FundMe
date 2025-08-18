// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//import {PriceConverter} from "../libraries/PriceConverter.sol";
import {PriceConverter} from "./PriceConverter.sol";

// 444023 gas
// 730859 gas
// 635529 gas with constant
// 655895 gas without constant  

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
