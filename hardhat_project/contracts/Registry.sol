// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Registry {
    mapping(uint256 => string) public templates;
    mapping(string => mapping(uint256 => string)) public terms;
    mapping(address => mapping(uint256 => bool)) hasAcceptedTerms;
    mapping(uint256 => string) public renderers;
    mapping(uint256 => uint256) public lastTermChange;

    /// @notice The default value of the global renderer.
    /// @dev The default value of the global renderer.
    string _globalRenderer = "";

    /// @notice The default value of the global template.
    /// @dev The default value of the global template.
    string _globalDocTemplate = "";

    event AcceptedTerms(
        address indexed user,
        uint256 indexed tokenId,
        string terms
    );

    // mapping()

    function acceptedTerms(address to, uint256 tokenId)
        external
        view
        returns (bool)
    {
        return _acceptedTerms(to, tokenId);
    }

    function _acceptedTerms(address to, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        return hasAcceptedTerms[to][tokenId];
    }

    function acceptTerms(uint256 tokenId, string memory newtermsUrl) external {
        _acceptTerms(tokenId, newtermsUrl);
    }

    function _acceptTerms(uint256 _tokenId, string memory _newtermsUrl)
        internal
        virtual
    {
        require(
            keccak256(bytes(_newtermsUrl)) ==
                keccak256(bytes(_termsUrl(_tokenId))),
            "Terms Url does not match"
        );
        hasAcceptedTerms[msg.sender][_tokenId] = true;
        emit AcceptedTerms(msg.sender, _tokenId, _termsUrl(_tokenId));
    }

    function termsUrl(uint256 tokenId) external view returns (string memory) {
        return _termsUrlWithPrefix(tokenId, "ipfs://");
    }

    function _termsUrl(uint256 tokenId) internal view returns (string memory) {
        return _termsUrlWithPrefix(tokenId, "ipfs://");
    }

    function _termsUrlWithPrefix(uint256 tokenId, string memory prefix)
        internal
        view
        returns (string memory _termsURL)
    {
        _termsURL = string(
            abi.encodePacked(
                prefix,
                _tokenRenderer(tokenId),
                "/#/",
                _tokenTemplate(tokenId),
                "::",
                Strings.toString(block.chainid),
                "::",
                Strings.toHexString(uint160(address(this)), 20),
                "::",
                Strings.toString(lastTermChange[tokenId]),
                "::",
                Strings.toString(tokenId)
            )
        );
    }

    function termsUrlWithPrefix(uint256 tokenId, string memory prefix)
        public
        view
        returns (string memory)
    {
        return _termsUrlWithPrefix(tokenId, prefix);
    }

    function _tokenRenderer(uint256 _tokenId)
        internal
        view
        returns (string memory)
    {
        if (bytes(renderers[_tokenId]).length == 0) return _globalRenderer;
        else return renderers[_tokenId];
    }

    function _tokenTemplate(uint256 _tokenId)
        internal
        view
        returns (string memory)
    {
        if (bytes(templates[_tokenId]).length == 0) return _globalDocTemplate;
        else return templates[_tokenId];
    }
}
