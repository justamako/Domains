// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IOkamaWebDomains {
        function linkContent(string memory domain, string memory newURI) external returns(bool);
}
contract Template_A {

    mapping(string => A_Structure) webStructure;
    mapping(string => A_Structure[]) oldSites;
    uint totalsites;
    IOkamaWebDomains domainRegistry;

    struct A_Structure {
        uint siteID;
        string contentURI;
        bool nav;
        bool head;
        bool feat;
        bool about;
        bool serve;
        bool gallery;
        bool test;
        bool team;
        bool contact;
        bool foot;
    }
    constructor(address domainRegistryAddress){
        domainRegistry = IOkamaWebDomains(domainRegistryAddress);
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

    function createSite(string memory domain, string memory contentURI, bool[10] memory sMap) external returns(bool) {
        string memory _domain = _toLower(domain);
        bool domainLinked = domainRegistry.linkContent(_domain,contentURI);
        require(domainLinked, "OKAMA: Unable To Link Domain");
        //Save Old Sites In Array.
        if (webStructure[_domain].siteID!=0) {
            oldSites[_domain].push(webStructure[_domain]); 
        }
        totalsites++;
        webStructure[_domain] = 
            A_Structure(totalsites, contentURI, sMap[0], sMap[1], sMap[2], sMap[3], sMap[4], sMap[5], sMap[6], sMap[7], sMap[8], sMap[9]);
        return true;
        }

    function getSites(string memory domain) external view returns(A_Structure memory) {
        return webStructure[_toLower(domain)];
    }
    function getOldSites(string memory domain) external view returns(A_Structure[] memory) {
        return oldSites[_toLower(domain)];
    }
    function test(uint Number) external pure returns(uint) {
        return Number+10;
    }


}
