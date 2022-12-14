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

    /// @notice This is a mapping of template token ID to the template.
    /// @dev This is a mapping of template token ID to the template.
    mapping(uint256 => string) public templates;

    /// @notice This is a mapping of hash of address and template token ID to the boolean value.
    /// @dev This is a mapping of hash of address and template token ID to the boolean value.
    mapping(bytes32 => bool) hasAcceptedTerms;

    /// @notice This is a mapping of template token ID to the template renderer.
    /// @dev This is a mapping of template token ID to the template renderer.
    mapping(uint256 => string) public renderers;

    /// @notice This is a mapping of template token ID to the last time the template or its terms were changed.
    /// @dev This is a mapping of template token ID to the last time the template or its terms were changed.
    mapping(uint256 => uint256) public lastTermChange;

    /// @notice This is a mapping of hash of key and template token ID to the value.
    /// @dev This is a mapping of hash of key and template token ID to the value.
    mapping(bytes32 => string) public terms;

    /// @notice This is a mapping of template token ID to the template owner.
    /// @dev This is a mapping of template token ID to the template owner.
    mapping(uint256 => address) public _templateOwners;

    /// @notice This is a mapping of template token ID to the template metadata URI.
    /// @dev This is a mapping of template token ID to the template metadata URI.
    mapping(uint256 => string) public metadataUri;

    /// @notice This mapping of addresses returns whether the address is allowed to accept terms on behalf of the signer.
    /// @dev This mapping of addresses returns whether the address is allowed to accept terms on behalf of the signer.
    mapping(address => bool) private _metaSigners;

    /// @notice The default value of the global renderer.
    /// @dev The default value of the global renderer.
    string _globalRenderer =
        "bafybeig44fabnqp66umyilergxl6bzwno3ntill3yo2gtzzmyhochbchhy";

    /// @notice This event is emitted when the terms for a template are accepted.
    /// @dev This event is emitted when the terms for a template are accepted.
    /// @param _templateId is the id of the tempalte for which the terms are being accepted.
    /// @param _user is the user who is accepting the terms.
    /// @param _templateUri is the URI of the template.
    /// @param _metadataUri is the URI of the metadata.
    event AcceptedTerms(
        uint256 indexed _templateId,
        address indexed _user,
        string _templateUri,
        string _metadataUri
    );

    /// @notice This event is emitted when the global renderer is updated.
    /// @dev This event is emitted when the global renderer is updated.
    /// @param _renderer is the new renderer.
    event GlobalRendererChanged(string indexed _renderer);

    /// @notice Event emitted when a new token term is added.
    /// @dev Event emitted when a new token term is added.
    /// @param _term is the term being added to the contract.
    /// @param _templateId is the token id of the token for which the term is being added.
    /// @param _value is the value of the term being added to the contract.
    event TermChanged(uint256 indexed _templateId, string _term, string _value);

    /// @notice This event is emitted when the global template is updated.
    /// @dev This event is emitted when the global template is updated.
    /// @param _template The new template.
    /// @param _templateId The token id of the token for which the template is being updated.
    event TemplateChanged(uint256 indexed _templateId, string _template);

    /// @notice This event is emitted when the metadata of the template is updated.
    /// @dev This event is emitted when the metadata of the template is updated.
    /// @param _templateId The token id of the token for which the metadata is being updated.
    /// @param _metadataUri The new metadata URI.
    event MetadataUriChanged(uint256 indexed _templateId, string _metadataUri);

    /// @notice This event is emitted when a new template is created.
    /// @dev This event is emitted when a new template is created.
    /// @param _templateId The id of the template created.
    /// @param _template is the URI of the template created.
    /// @param _owner is the owner of the template.
    event TemplateCreated(
        uint256 indexed _templateId,
        string _template,
        address _owner
    );

    /// @notice This function returns the hash of a template id and a key.
    /// @dev This function returns the hash of a template id and a key.
    /// @param key is the key for which the hash is being calculated.
    /// @param templateId is the id of the template for which the hash is being calculated.
    /// @return hash is the hash of the template id and the key that is returned.
    function _hashKeyId(
        string memory key,
        uint256 templateId
    ) internal pure returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(templateId, key));
        return hash;
    }

    /// @notice This function returns the hash of an address and a template id.
    /// @dev This function returns the hash of an address and a template id.
    /// @param user is the address for which the hash is being calculated.
    /// @param templateId is the id of the template for which the hash is being calculated.
    /// @return hash is the hash of the address and the template id that is returned.
    function _hashAddressId(
        address user,
        uint256 templateId
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, templateId));
    }

    /// @notice This function returns the value of a term for a template.
    /// @dev This function returns the value of a term for a template given its template id and key. The key is the term name.
    /// Hash of the key and template id is used to get the value of the term.
    /// @param templateId is the id of the template for which the term is being returned.
    /// @param key is the key for which the value is being looked up.
    /// @return Returns a string value of the term.
    function term(
        uint256 templateId,
        string memory key
    ) public view returns (string memory) {
        bytes32 hash = _hashKeyId(key, templateId);
        return terms[hash];
    }

    /// @notice This is an external function that calls an internal function to check if the terms for a template have been accepted by a user.
    /// @dev This is an external function that calls an internal function to check if the terms for a template have been accepted by a user (_signer).
    /// @param _signer is the address of the user for which the acceptance of the terms are being checked.
    /// @param _templateId is the id of the template for which the acceptance of the terms are being checked.
    /// @return Returns a boolean value indicating whether the terms have been accepted or not.
    function acceptedTerms(
        address _signer,
        uint256 _templateId
    ) external view returns (bool) {
        return _acceptedTerms(_signer, _templateId);
    }

    /// @notice This is an internal function to check if the terms for a template have been accepted by a user.
    /// @dev This is an internal function to check if the terms for a template have been accepted by a user (_signer).
    /// @param _signer is the address of the user for which the acceptance of the terms are being checked.
    /// @param _templateId is the id of the template for which the acceptance of the terms are being checked.
    /// @return Returns a boolean value indicating whether the terms have been accepted or not.
    function _acceptedTerms(
        address _signer,
        uint256 _templateId
    ) internal view returns (bool) {
        bytes32 hash = _hashAddressId(_signer, _templateId);
        return hasAcceptedTerms[hash];
    }

    /// @notice This is an external function that calls an internal function to accept terms for a template without metadata.
    /// @dev This is an external function that calls an internal function to accept terms for a template.
    /// The terms are accepted on behalf of the the msg.sender without any metadata.
    /// @param _templateId is the id of the template for which the terms are being accepted.
    /// @param _newTemplateUrl is the new template url for the template for which the terms are being accepted.
    function acceptTerms(
        uint256 _templateId,
        string memory _newTemplateUrl
    ) external {
        _acceptTerms(msg.sender, _templateId, _newTemplateUrl, "");
    }

    /// @notice This is an external function that calls an internal function to accept terms for a template with metadata.
    /// @dev This is an external function that calls an internal function to accept terms for a template.
    /// The terms are accepted on behalf of the the msg.sender with metadata.
    /// @param _templateId is the id of the template for which the terms are being accepted.
    /// @param _newTemplateUrl is the new template url for the template for which the terms are being accepted.
    /// @param _metdataUri is the metadata URI for the template for which the terms are being accepted.
    function acceptTerms(
        uint256 _templateId,
        string memory _newTemplateUrl,
        string memory _metdataUri
    ) external {
        _acceptTerms(msg.sender, _templateId, _newTemplateUrl, _metdataUri);
    }

    /// @notice This is an internal function to accept terms for a given template with metadata.
    /// @dev This is an internal function to accept terms for a template by signer for given template id, template URI and metadata.
    /// It emits an event AcceptedTerms once the terms are accepted.
    /// @param _signer is the address of the user who is accepting the terms.
    /// @param _templateId is the id of the template for which the terms are being accepted.
    /// @param _newtemplateUrl is the new template url for the template for which the terms are being accepted.
    /// @param _metadataUri is the metadata URI for the template for which the terms are being accepted.
    function _acceptTerms(
        address _signer,
        uint256 _templateId,
        string memory _newtemplateUrl,
        string memory _metadataUri
    ) internal virtual {
        require(
            keccak256(bytes(_newtemplateUrl)) ==
                keccak256(bytes(_templateUrl(_templateId))),
            "Terms Url does not match"
        );
        bytes32 hash = _hashAddressId(_signer, _templateId);
        hasAcceptedTerms[hash] = true;
        emit AcceptedTerms(
            _templateId,
            _signer,
            _templateUrl(_templateId),
            _metadataUri
        );
    }

    // function checkUrls(
    //     string memory _newtemplateUrl,
    //     uint256 _templateId
    // ) external view returns (bool) {
    //     return
    //         keccak256(bytes(_newtemplateUrl)) ==
    //         keccak256(bytes(_templateUrl(_templateId)));
    // }

    /// @notice This is an external function that calls an internal function to accept terms for a template on behalf of a signer without metadata.
    /// @dev This is an external function that calls an internal function to accept terms for a template on behalf of a signer without metadata.
    /// The terms are accepted on behalf of the the _signer without any metadata. The signer is checked against the signature.
    /// @param _signer is the address of the user who is accepting the terms.
    /// @param _templateId is the id of the template for which the terms are being accepted.
    /// @param _newtemplateUrl is the new template url for the template for which the terms are being accepted.
    /// @param _signature is the signature of the signer for the terms acceptance.
    function acceptTermsFor(
        address _signer,
        string memory _newtemplateUrl,
        uint256 _templateId,
        bytes memory _signature
    ) external onlyMetaSigner {
        bytes32 hash = ECDSA.toEthSignedMessageHash(bytes(_newtemplateUrl));
        address _checkedSigner = ECDSA.recover(hash, _signature);
        require(_checkedSigner == _signer);
        _acceptTerms(_signer, _templateId, _newtemplateUrl, "");
    }

    /// @notice This is an external function that calls an internal function to accept terms for a template on behalf of a signer without metadata.
    /// @dev This is an external function that calls an internal function to accept terms for a template on behalf of a signer without metadata.
    /// The terms are accepted on behalf of the the _signer without any metadata. The signer is checked against the signature.
    /// @param _signer is the address of the user who is accepting the terms.
    /// @param _templateId is the id of the template for which the terms are being accepted.
    /// @param _newtemplateUrl is the new template url for the template for which the terms are being accepted.
    /// @param _signature is the signature of the signer for the terms acceptance.
    function acceptTermsFor(
        address _signer,
        string memory _newtemplateUrl,
        string memory _metadataUri,
        uint256 _templateId,
        bytes memory _signature
    ) external onlyMetaSigner {
        bytes32 hash = ECDSA.toEthSignedMessageHash(
            abi.encodePacked(bytes(_newtemplateUrl), bytes(_metadataUri))
        );
        address _checkedSigner = ECDSA.recover(hash, _signature);
        require(_checkedSigner == _signer);
        _acceptTerms(_signer, _templateId, _newtemplateUrl, _metadataUri);
    }

    function templateUrl(
        uint256 templateId
    ) external view returns (string memory) {
        return _templateUrlWithPrefix(templateId, "ipfs://");
    }

    function _templateUrl(
        uint256 templateId
    ) internal view returns (string memory) {
        return _templateUrlWithPrefix(templateId, "ipfs://");
    }

    function _templateUrlWithPrefix(
        uint256 templateId,
        string memory prefix
    ) internal view returns (string memory _templateUri) {
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
                Strings.toString(templateId),
                "::",
                Strings.toString(lastTermChange[templateId])
            )
        );
    }

    function templateUrlWithPrefix(
        uint256 templateId,
        string memory prefix
    ) public view returns (string memory) {
        return _templateUrlWithPrefix(templateId, prefix);
    }

    function _renderer(uint256 _tokenId) internal view returns (string memory) {
        if (bytes(renderers[_tokenId]).length == 0) return _globalRenderer;
        else return renderers[_tokenId];
    }

    function _template(uint256 _tokenId) internal view returns (string memory) {
        return templates[_tokenId];
    }

    function _setGlobalRenderer(string memory _newGlobalRenderer) internal {
        _globalRenderer = _newGlobalRenderer;
    }

    function setGlobalRenderer(
        string memory _newGlobalRenderer
    ) external onlyOwner {
        _setGlobalRenderer(_newGlobalRenderer);
    }

    function _setTemplate(
        uint256 _templateId,
        string memory _newTemplate
    ) internal {
        templates[_templateId] = _newTemplate;
        lastTermChange[_templateId] = block.number;
        emit TemplateChanged(_templateId, _newTemplate);
    }

    function setTemplate(
        uint256 _templateId,
        string memory _newTemplate
    ) external onlyTemplateOwner(_templateId) {
        _setTemplate(_templateId, _newTemplate);
    }

    function setMetadataUri(
        uint256 _templateId,
        string memory _newMetadataUri
    ) external onlyTemplateOwner(_templateId) {
        _setMetadataUri(_templateId, _newMetadataUri);
    }

    function _setMetadataUri(
        uint256 _templateId,
        string memory _newMetadataUri
    ) internal {
        metadataUri[_templateId] = _newMetadataUri;
        lastTermChange[_templateId] = block.number;
        emit MetadataUriChanged(_templateId, _newMetadataUri);
    }

    function _setTerm(
        uint256 _templateId,
        string memory _key,
        string memory _value
    ) internal {
        // console.log("Inside setTerm");
        // console.log("key:", _key);
        bytes32 hash = _hashKeyId(_key, _templateId);
        terms[hash] = _value;
        // console.log("key at line 211:", _key);
        // bytes32 keyHash = keccak256(abi.encodePacked(_key));
        // console.logBytes32(keyHash);
        lastTermChange[_templateId] = block.number;
        emit TermChanged(_templateId, _key, _value);
    }

    function setTerm(
        uint256 _templateId,
        string memory _key,
        string memory _value
    ) external onlyTemplateOwner(_templateId) {
        _setTerm(_templateId, _key, _value);
    }

    function _mintTemplate(
        address _signer,
        string memory _templateUri
    ) internal returns (uint256) {
        uint256 templateId = ids.current();
        templates[templateId] = _templateUri;
        _templateOwners[templateId] = _signer;
        lastTermChange[templateId] = block.number;
        ids.increment();
        emit TemplateCreated(templateId, _templateUri, _signer);
        return templateId;
    }

    // external function to call mintTemplate by thrid party
    function mintTemplate(
        string memory _templateUri
    ) external returns (uint256) {
        return _mintTemplate(msg.sender, _templateUri);
    }

    // external function to call mintTemplate by metaSigner
    function mintTemplate(
        string memory _templateUri,
        address _owner
    ) external onlyMetaSigner returns (uint256) {
        return _mintTemplate(_owner, _templateUri);
    }

    // external function to call mintTemplate on behalf of a signer
    // function mintTemplateFor(
    //     address _signer,
    //     string memory _templateUri,
    //     bytes memory _signature
    // ) external onlyMetaSigner returns (uint256) {
    //     bytes32 hash = ECDSA.toEthSignedMessageHash(bytes(_templateUri));
    //     address _checkedSigner = ECDSA.recover(hash, _signature);
    //     require(_checkedSigner == _signer);
    //     return _mintTemplate(_signer, _templateUri);
    // }

    /// @notice Adds a meta signer to the list of signers that can accept terms on behalf of the signer.
    /// @dev This function adds a meta signer to the list of signers that can accept terms on behalf of the signer.
    /// @dev This function is only available to the owner of the contract.
    /// @param _signer The address of the signer that can accept terms on behalf of the signer.
    function approveMetaSigner(
        address _signer,
        bool _approval
    ) external onlyMetaSigner {
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
