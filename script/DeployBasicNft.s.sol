// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {BasicNft} from "../src/BasicNft.sol";

contract DeployBasicNft is Script {

    // Test variables
    string public constant NAME = "My NFT Collection";
    string public constant SYMBOL = "MNC";
    uint256 public constant PRICE = 0.1 ether;

    function run() external returns (BasicNft) {
        vm.startBroadcast();
        BasicNft nft = new BasicNft(NAME, SYMBOL, PRICE);
        // Transfer ownership to the caller
        nft.transferOwnership(msg.sender);
        vm.stopBroadcast();
        return nft;
    }
}