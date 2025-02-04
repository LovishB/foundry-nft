// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {DeployBasicNft} from "../script/DeployBasicNft.s.sol";
//We need this to receive NFts from other contracts
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";



contract basicNftTest is Test, IERC721Receiver {
    DeployBasicNft deployBasicNft;
    BasicNft basicNft;
    HelperConfig helperConfig;
    address recipient;
    address owner;

    function setUp() public {
        deployBasicNft = new DeployBasicNft();
        (basicNft, helperConfig) = deployBasicNft.run();
        recipient = makeAddr("recipient");
        owner = vm.addr(helperConfig.getOrCreateAnvilEthConfig().deployerKey); //getting address from helperConfig
    }

    function testInitialState() public view {
        assertEq(basicNft.name(), deployBasicNft.NAME());
        assertEq(basicNft.symbol(), deployBasicNft.SYMBOL());
        assertEq(basicNft.s_nftPrice(), deployBasicNft.PRICE());
        assertEq(basicNft.owner(), owner);
        assertEq(basicNft.totalSupply(), 0);
    }

    function testMintNFTFailNotTheOwner() public {
        vm.prank(recipient);
        vm.expectRevert();
        basicNft.mintNFT("testURI");
    }

    function testMintNFT() public {
        vm.prank(owner);
        basicNft.mintNFT("testURI");
        assertEq(basicNft.totalSupply(), 1);
    }

    function testMintNFTEvent() public {
        vm.prank(owner);
        vm.expectEmit(true, true, false, true);
        emit BasicNft.NFTMinted(owner, 1, "testURI");
        basicNft.mintNFT("testURI");
    }

    function testSetNFTPrice() public {
        vm.prank(owner);
        basicNft.setPrice(0.25 ether);
        assertEq(basicNft.s_nftPrice(), 0.25 ether);
    }

    function testTotalSupllyAfterMinting() public {
        vm.prank(owner);
        basicNft.mintNFT("testURI");
        assertEq(basicNft.totalSupply(), 1);
    }

    function testBuyNFTFailInsufficientFunds() public {
        vm.prank(owner);
        basicNft.mintNFT("testURI");
        vm.expectRevert(
            abi.encodeWithSelector(BasicNft.InsufficientFunds.selector, 1, 0.1 ether)
        );
        basicNft.buyNFT{value: 0.05 ether}(1);
    }

    function testBuyNFT() public {
        vm.prank(owner);
        basicNft.mintNFT("testURI");
        vm.prank(recipient);
        vm.deal(recipient, 1 ether);
        basicNft.buyNFT{value: 0.1 ether}(1);
        assertEq(basicNft.ownerOf(1), recipient);
        assertEq(basicNft.s_tokenForSale(1), false);
    }

    function testBuyNFTEmit() public {
        vm.prank(owner);
        basicNft.mintNFT("testURI");
        vm.prank(recipient);
        vm.deal(recipient, 1 ether);
        vm.expectEmit(true, true, true, true);
        emit BasicNft.NFTSold(owner, recipient, 1, 0.1 ether);
        basicNft.buyNFT{value: 0.1 ether}(1);
    }

     function testBuyNFTNotForSale() public {
        vm.prank(owner);
        basicNft.mintNFT("testURI");
        vm.prank(recipient);
        vm.deal(recipient, 1 ether);
        basicNft.buyNFT{value: 0.1 ether}(1);
        vm.expectRevert(
            abi.encodeWithSelector(BasicNft.TokenNotForSale.selector, 1)
        );       
        basicNft.buyNFT{value: 0.1 ether}(1);
    }

    // Implement the IERC721Receiver interface to recieve NFTs from other contracts
    function onERC721Received(
        address,  // operator
        address,  // from
        uint256,  // tokenId
        bytes calldata  // data
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    //test contract can recieve eth
    receive() external payable {}

}