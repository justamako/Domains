// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";
import "./@openzeppelin/contracts/utils/Counters.sol";

contract OkamaWebDomains is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    string hostURI;
    string parkingURI;
    mapping(uint => string) internal domainName;
    mapping(string => uint) internal domainID;
    mapping(string => bool) internal domainRegistered;
    mapping(address => bool) internal approvedWebBuilder;


    Counters.Counter private _tokenIdCounter;

        constructor() ERC721("OkamaWeb Domains", "OWD") {
            hostURI = "okamaweb.io/";
            parkingURI = "parked";
            _registerDomain(address(this), parkingURI);
        }
    
    event DomainRegister(address indexed owner, uint domainID, string domainName);
    event DomainURI_Update(string domainName, string oldURI, string newURI);
    event HostURI_Update(string oldURI, string newURI);
    event WebBuilderAccess(address indexed templateAddress, bool access);
    
    modifier isDomainRegistered(string memory _domain) {
        require(domainRegistered[_domain]!=true, "OKAMA: Domain Taken");
        _;
    }
    modifier OnlyRegistered(string memory _domain) {
        require(domainRegistered[_domain]==true, "OKAMA: Domain Not Registered");
        _;
    }
    modifier onlyDomainOwner(string memory _domain, address account) {
        require(account==ownerOf(domainID[_domain]), "OKAMA: Not Domain Owner");
        _;
    }
    modifier onlyWebBuilder(address _builder) {
        require(approvedWebBuilder[_builder], "OKAMA: Web Builder Not Approved");
        _;
    }

    function _toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // Uppercase character...
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                // So we add 32 to make it lowercase
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    function _baseURI() internal view override returns (string memory) {
        return hostURI;
    }

    function getDomainName(uint ID) external view returns(string memory){
        _requireMinted(ID);
        return domainName[ID];
    }
    function getDomainID(string memory domain) external view OnlyRegistered(domain) returns(uint){
        return domainID[_toLower(domain)];
    }
    function checkDomainRegistered(string memory domain) external view returns(bool){
        return domainRegistered[_toLower(domain)];
    }

    function _registerDomain(address _owner, string memory domain) internal isDomainRegistered(domain) returns(bool){
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_owner, tokenId);
        domainName[tokenId] = domain;
        domainID[domain] = tokenId;
        _setTokenURI(domainID[domain], parkingURI);
        domainRegistered[domain] = true;
        _totalSupply = tokenId+1;
        emit DomainRegister(ownerOf(domainID[domain]), domainID[domain], domain);
        return domainRegistered[domain];
    }
        function registerDomain(string memory domain) external  returns(bool) {
        return _registerDomain(msg.sender, _toLower(domain));
    }

    function linkContent(string memory domain, string memory newURI) external onlyWebBuilder(msg.sender) OnlyRegistered(domain) onlyDomainOwner(domain, tx.origin) returns(bool){
        string memory _domain = _toLower(domain);
        string memory oldURI = tokenURI(domainID[_domain]);
        _setTokenURI(domainID[_domain], newURI);
        emit DomainURI_Update(_domain, oldURI, newURI);
        return true;
    }

    function setHostURI(string memory newURI) external onlyOwner returns (bool) {
        string memory oldURI = hostURI;
        hostURI = newURI;
        emit HostURI_Update(oldURI, newURI);
        return true;
    }
    function manageWebBuilder(address templateAddress, bool access) external onlyOwner returns (bool) {
        approvedWebBuilder[templateAddress] = access;
        emit WebBuilderAccess(templateAddress, access);
        return true;
    }
    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
