// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployBasicNft is Script {

    // Test variables
    string public constant NAME = "My NFT Collection";
    string public constant SYMBOL = "MNC";
    uint256 public constant PRICE = 0.1 ether;

    function run() external returns (BasicNft, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (uint256 deployerKey, ) = helperConfig.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        BasicNft nft = new BasicNft(NAME, SYMBOL, PRICE);
        vm.stopBroadcast();
        return (nft, helperConfig);
    }
}