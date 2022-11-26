// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Registry is Ownable {
    // string[] public templates;
    using Counters for Counters.Counter;
    Counters.Counter private ids;

    mapping(uint256 => string) public templates;
    // mapping(string => mapping(uint256 => string)) public terms;
    // maps hashAddressId to boolean
    mapping(bytes32 => bool) hasAcceptedTerms;
    mapping(uint256 => string) public renderers;
    mapping(uint256 => uint256) public lastTermChange;
    // mapping of hash of key and template token ID to the value
    mapping(bytes32 => string) public terms;
    mapping(uint256 => address) public _templateOwners;

    /// @notice Returns whether the address is allowed to accept terms on behalf of the signer.
    /// @dev This function returns whether the address is allowed to accept terms on behalf of the signer.
    mapping(address => bool) private _metaSigners;
    // address[] owners;

    /// @notice The default value of the global renderer.
    /// @dev The default value of the global renderer.
    string _globalRenderer =
        "bafybeig44fabnqp66umyilergxl6bzwno3ntill3yo2gtzzmyhochbchhy";

    event AcceptedTerms(
        uint256 indexed templateId,
        address indexed user,
        string uri
    );
    /// @notice This event is emitted when the global renderer is updated.
    /// @dev This event is emitted when the global renderer is updated.
    /// @param _renderer The new renderer.
    event GlobalRendererChanged(string indexed _renderer);

    /// @notice Event emitted when a new token term is added.
    /// @dev Event emitted when a new token term is added.
    /// @param _term The term being added to the contract.
    /// @param _templateId The token id of the token for which the term is being added.
    /// @param _value The value of the term being added to the contract.
    event TermChanged(uint256 indexed _templateId, string _term, string _value);

    /// @notice This event is emitted when the global template is updated.
    /// @dev This event is emitted when the global template is updated.
    /// @param _template The new template.
    /// @param _templateId The token id of the token for which the template is being updated.
    event TemplateChanged(uint256 indexed _templateId, string _template);

    event TemplateCreated(
        uint256 indexed _templateId,
        string _template,
        address _owner
    );

    // change to internal later
    function hashKeyId(string memory key, uint256 templateId)
        public
        pure
        returns (bytes32)
    {
        bytes32 hash = keccak256(abi.encodePacked(templateId, key));
        // console.log("Inside HashKeyId");
        // console.logBytes32(hash);
        // console.log("key:", key);
        return hash;
    }

    // change to internal later
    function hashAddressId(address user, uint256 templateId)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(user, templateId));
    }

    function acceptedTerms(address _signer, uint256 _templateId)
        external
        view
        returns (bool)
    {
        return _acceptedTerms(_signer, _templateId);
    }

    function _acceptedTerms(address _signer, uint256 _templateId)
        internal
        view
        returns (bool)
    {
        bytes32 hash = hashAddressId(_signer, _templateId);
        return hasAcceptedTerms[hash];
    }

    function acceptTerms(uint256 templateId, string memory newTemplateUrl)
        external
    {
        _acceptTerms(templateId, newTemplateUrl);
    }

    function _acceptTerms(uint256 _templateId, string memory _newtemplateUrl)
        internal
        virtual
    {
        require(
            keccak256(bytes(_newtemplateUrl)) ==
                keccak256(bytes(_templateUrl(_templateId))),
            "Terms Url does not match"
        );
        bytes32 hash = hashAddressId(msg.sender, _templateId);
        hasAcceptedTerms[hash] = true;
        emit AcceptedTerms(_templateId, msg.sender, _templateUrl(_templateId));
    }

    function acceptTermsFor(
        address _signer,
        string memory _newtemplateUrl,
        uint256 _templateId,
        bytes memory _signature
    ) external onlyMetaSigner {
        bytes32 hash = ECDSA.toEthSignedMessageHash(bytes(_newtemplateUrl));
        address _checkedSigner = ECDSA.recover(hash, _signature);
        require(_checkedSigner == _signer);
        _acceptTerms(_templateId, _newtemplateUrl);
    }

    function templateUrl(uint256 templateId)
        external
        view
        returns (string memory)
    {
        return _templateUrlWithPrefix(templateId, "ipfs://");
    }

    function _templateUrl(uint256 templateId)
        internal
        view
        returns (string memory)
    {
        return _templateUrlWithPrefix(templateId, "ipfs://");
    }

    function _templateUrlWithPrefix(uint256 templateId, string memory prefix)
        internal
        view
        returns (string memory _templateUri)
    {
        _templateUri = string(
            abi.encodePacked(
                prefix,
                _renderer(templateId),
                "/#/",
                _template(templateId),
                "::",
                Strings.toString(block.chainid),
                "::",
                Strings.toHexString(uint160(address(this)), 20),
                "::",
                Strings.toString(lastTermChange[templateId]),
                "::",
                Strings.toString(templateId)
            )
        );
    }

    function templateUrlWithPrefix(uint256 templateId, string memory prefix)
        public
        view
        returns (string memory)
    {
        return _templateUrlWithPrefix(templateId, prefix);
    }

    function _renderer(uint256 _tokenId) internal view returns (string memory) {
        if (bytes(renderers[_tokenId]).length == 0) return _globalRenderer;
        else return renderers[_tokenId];
    }

    function _template(uint256 _tokenId) internal view returns (string memory) {
        // if (bytes(templates[_tokenId]).length == 0) return _globalDocTemplate;
        // else return templates[_tokenId];
        return templates[_tokenId];
    }

    function _setGlobalRenderer(string memory _newGlobalRenderer) internal {
        _globalRenderer = _newGlobalRenderer;
    }

    function setGlobalRenderer(string memory _newGlobalRenderer)
        external
        onlyOwner
    {
        _setGlobalRenderer(_newGlobalRenderer);
    }

    function setTemplate(uint256 _templateId, string memory _newTemplate)
        external
        onlyTemplateOwner(_templateId)
    {
        templates[_templateId] = _newTemplate;
        lastTermChange[_templateId] = block.number;
        emit TemplateChanged(_templateId, _newTemplate);
    }

    function setTerm(
        uint256 _templateId,
        string memory _key,
        string memory _value
    ) external onlyTemplateOwner(_templateId) {
        // console.log("Inside setTerm");
        // console.log("key:", _key);
        bytes32 hash = hashKeyId(_key, _templateId);
        terms[hash] = _value;
        // console.log("key at line 211:", _key);
        // bytes32 keyHash = keccak256(abi.encodePacked(_key));
        // console.logBytes32(keyHash);
        lastTermChange[_templateId] = block.number;
        emit TermChanged(_templateId, _key, _value);
    }

    function mintTemplate(string memory _templateUri)
        external
        returns (uint256)
    {
        uint256 templateId = ids.current();
        templates[templateId] = _templateUri;
        _templateOwners[templateId] = msg.sender;
        ids.increment();
        emit TemplateCreated(templateId, _templateUri, msg.sender);
        return templateId;
    }

    /// @notice Adds a meta signer to the list of signers that can accept terms on behalf of the signer.
    /// @dev This function adds a meta signer to the list of signers that can accept terms on behalf of the signer.
    /// @dev This function is only available to the owner of the contract.
    /// @param _signer The address of the signer that can accept terms on behalf of the signer.
    function approveMetaSigner(address _signer, bool _approval)
        external
        onlyMetaSigner
    {
        _approveMetaSigner(_signer, _approval);
    }

    /// @notice Adds a meta signer to the list of signers that can accept terms on behalf of the signer.
    /// @dev This internal function adds a meta signer to the list of signers that can accept terms on behalf of the signer.
    /// @param _signer The address of the signer that can accept terms on behalf of the signer.
    function _approveMetaSigner(address _signer, bool _approval) internal {
        _metaSigners[_signer] = _approval;
    }

    /// @notice Returns whether the address is allowed to accept terms on behalf of the signer.
    /// @dev This function returns whether the address is allowed to accept terms on behalf of the signer.
    /// @param _signer The address of the signer that can accept terms on behalf of the signer.
    /// @return Whether the address is allowed to accept terms on behalf of the signer.
    function isMetaSigner(address _signer) public view returns (bool) {
        return _metaSigners[_signer];
    }

    modifier onlyTemplateOwner(uint256 _templateId) {
        require(
            (_templateOwners[_templateId] == _msgSender()) ||
                (_metaSigners[_msgSender()]),
            "Not template owner"
        );
        _;
    }

    /// @notice This modifier requires that the msg.sender is either the owner of the contract or an approved metasigner
    modifier onlyMetaSigner() {
        require(
            _metaSigners[_msgSender()] || owner() == _msgSender(),
            "Not a metasigner or Owner"
        );
        _;
    }
}
