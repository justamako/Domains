// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";
import "./@openzeppelin/contracts/utils/Counters.sol";

contract OkamaWebDomains is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    string hostURI;
    mapping(uint => string) internal domainName;
    mapping(string => uint) internal domainID;
    mapping(string => bool) internal domainRegistered;

    Counters.Counter private _tokenIdCounter;

        constructor() ERC721("OkamaWeb Domains", "OWD") {
            hostURI = "okamaweb.io/";
        }
    
    event DomainRegister(address owner, uint domainID, string domainName);
    event DomainURI_Update(string domainName, string newURI);
    event HostURI_Update(string oldURI, string newURI);
    
    modifier isDomainRegistered(string memory _domain) {
        require(domainRegistered[_domain]!=true, "OKAMA: Domain Taken");
        _;
    }
    modifier onlyDomainOwner(string memory _domain) {
        require(msg.sender==ownerOf(domainID[_domain]), "OKAMA: Not Domain Owner");
        _;
    }

    function _baseURI() internal view override returns (string memory) {
        return hostURI;
    }

    function getDomainName(uint ID) external view returns(string memory){
        return domainName[ID];
    }
    function getDomainID(string memory domain) external view returns(uint){
        return domainID[domain];
    }
    function checkDomainRegistered(string memory domain) external view returns(bool){
        return domainRegistered[domain];
    }

    function registerDomain(string memory domain) external isDomainRegistered(domain) returns(bool) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        domainName[tokenId] = domain;
        domainID[domain] = tokenId;
        domainRegistered[domain] = true;
        _totalSupply = tokenId+1;
        emit DomainRegister(ownerOf(domainID[domain]), domainID[domain], domain);
        return domainRegistered[domain];
    }

    function linkContent(string memory domain, string memory newURI) external isDomainRegistered(domain) onlyDomainOwner(domain) returns(bool){
            _setTokenURI(domainID[domain], newURI);
            emit DomainURI_Update(domain, newURI);
            return true;
    }

    function setHostURI(string memory newURI) external onlyOwner returns (bool) {
        string memory oldURI = hostURI;
        hostURI = newURI;
        emit HostURI_Update(oldURI, newURI);
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
