// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BasicNft is ERC721URIStorage, Ownable {

    uint256 private s_nextTokenId; //we manage our own tokenids
    uint256 public s_nftPrice; //price of each nft
    mapping (uint256 => bool) public s_tokenForSale;

    error TokenNotForSale(uint256 tokenId);
    error InsufficientFunds(uint256 tokenId, uint256 nftPrice);
    error TransferFailed(address from, address to, uint256 tokenId);

    event NFTMinted(address indexed owner, uint256 indexed tokenId, string tokenURI);
    event NFTSold(address indexed seller, address indexed buyer, uint256 indexed tokenId, uint256 price);

    constructor(string memory _name, string memory _symbol, uint256 _nftPrice) 
        ERC721(_name, _symbol) // Passing NFT collection name and symbol
        Ownable(msg.sender) { // Making deployer the owner
            s_nftPrice = _nftPrice;
        } 
    
    //owners can mint their collection
    function mintNFT(string memory tokenURI) external onlyOwner {
        uint256 tokenID = ++s_nextTokenId;
        _safeMint(owner(), tokenID);  
        _setTokenURI(tokenID, tokenURI);
        s_tokenForSale[tokenID] = true;
        emit NFTMinted(owner(), tokenID, tokenURI);
    }

    function setPrice(uint256 _nftPrice) external onlyOwner {
        s_nftPrice = _nftPrice;
    }

    function totalSupply() external view returns (uint256) {
        return s_nextTokenId;
    }

    //users can buy nft from collection
    function buyNFT(uint256 _tokenId) external payable{
        //check if the token is available
        if(!s_tokenForSale[_tokenId]) {
            revert TokenNotForSale(_tokenId);
        }
        //check the value > price
        if(msg.value < s_nftPrice) {
            revert InsufficientFunds(_tokenId, s_nftPrice);
        }
        //mark the token as sold
        s_tokenForSale[_tokenId] = false;

        //transfer the value to owner
        (bool success, ) = payable(owner()).call{value: msg.value}("");
        if(!success) {
            revert TransferFailed(msg.sender, owner(), _tokenId);
        }
        //transfer the token to buyer
        _transfer(owner(), msg.sender, _tokenId);

        //emit 
        emit NFTSold(owner(), msg.sender, _tokenId, s_nftPrice);
    }

}