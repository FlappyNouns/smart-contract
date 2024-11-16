
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

//Openzeppelin libraries
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//Define the contract of token
contract Flappy_Nouns is ERC721Enumerable, Ownable {
    using Strings for uint256;
 
    IERC20 public paymentToken; // ERC20
    string public baseURI; //The IPFS pointer(hash) of metadata files
    string public baseExtension = ".json";//The metadata should be in the format of .json
    uint256 public cost = 10 ** 18;  //The price of each NFT
    uint256 public maxSupply = 20;    //Maximum supply (20)
    uint256 public presalePeriod = 20; //Duration of presale (200s)
    uint256 public deploymentTimestamp;


    constructor(address _paymentToken, string memory _initBaseURI) ERC721("Flappy_Nouns", "FPN") Ownable(msg.sender) {
	//Deployment and initialization of the token
        deploymentTimestamp = block.timestamp; //The current block.timestamp is used as the start point of pre-sale
        setBaseURI(_initBaseURI);//Set the initial IPFS address of metadata
        mint(msg.sender);// Mint 1 genesis token to creator's wallet
        paymentToken = IERC20(_paymentToken);
    }

    // Call the IPFS pointer(hash) of metadata files
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }


    // The following functions can called by the public wallets
    //mint fucntion(pre-sale and public-sale)
    function mint(address _to) public{
        uint256 supply = totalSupply();
        bool Presale = check_presale();

        require(supply + 1 <= maxSupply);//Current total supply does not exceed the maximum supply after purchasing

        if (msg.sender != owner()) {
            require(!Presale, "Please wait for public sale!");
            paymentToken.transferFrom(msg.sender, address(this), cost);

        } 
        
        _safeMint(_to, supply);
    }

    function walletOfOwner(address _owner) public view returns (uint256[] memory){
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    } //Get the IDs held by the current wallet

    function check_presale() public view returns (bool){
        bool _Presale = true;
        uint256 currentTimestamp = block.timestamp;
        if(currentTimestamp >= deploymentTimestamp + presalePeriod){
            _Presale = false;
        }
        return _Presale;
    } //Check if current state is pre-sale

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory){
        require(_ownerOf(tokenId) != address(0),"ERC721Metadata: URI query for nonexistent token");


        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    } //assemble the IPFS pointer(hash) of each token's metadata

    //set new presale duration
    function setpresalePeriod(uint256 _newpresalePeriod) public onlyOwner {
        presalePeriod = _newpresalePeriod;
    }
    //start a new presale at current block.timestamp
    function setnewpresale() public onlyOwner {
        deploymentTimestamp = block.timestamp;
    }

    //set a new maximum supply
    function setmaxSupply(uint256 _newmaxSupply) public onlyOwner {
        maxSupply = _newmaxSupply;
    }
    //set a new IPFS pointer(hash)of metadata files
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
    //Withdraw the balance from the contract to the creator's wallet
    function withdraw() public payable onlyOwner {

        uint256 balance = paymentToken.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        paymentToken.transfer(msg.sender, balance);

    }
    }