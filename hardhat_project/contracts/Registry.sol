// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Registry is Ownable {
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
    ) external view returns (string memory) {
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
    /// @dev The terms are accepted on behalf of the the _signer without any metadata.
    /// @dev The signer is checked against the signature.
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

    /// @notice This is an external function that calls an internal function to view the template url for a given template id with an ipfs prefix.
    /// @dev This is an external function that calls an internal function to view the template url for a given template id with an ipfs prefix.
    /// @param templateId is the id of the template for which the template url is being viewed.
    function templateUrl(
        uint256 templateId
    ) external view returns (string memory) {
        return _templateUrlWithPrefix(templateId, "ipfs://");
    }

    /// @notice This is an internal function to view the template url for a given template id with an ipfs prefix.
    /// @dev This is an internal function to view the template url for a given template id with an ipfs prefix.
    /// @param templateId is the id of the template for which the template url is being viewed.
    function _templateUrl(
        uint256 templateId
    ) internal view returns (string memory) {
        return _templateUrlWithPrefix(templateId, "ipfs://");
    }

    /// @notice This is an internal function to view the template url for a given template id with a given prefix.
    /// @dev This is an internal function to view the template url for a given template id with a given prefix.
    /// @param templateId is the id of the template for which the template url is being viewed.
    /// @param prefix is the prefix for the template url.
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

    /// @notice This is an external function that calls an internal function to view the template url for a given template id with a given prefix.
    /// @dev This is an external function that calls an internal function to view the template url for a given template id with a given prefix.
    /// @param templateId is the id of the template for which the template url is being viewed.
    /// @param prefix is the prefix for the template url.
    function templateUrlWithPrefix(
        uint256 templateId,
        string memory prefix
    ) external view returns (string memory) {
        return _templateUrlWithPrefix(templateId, prefix);
    }

    /// @notice This is an internal view function to view the renderer for a given template id.
    /// @dev This is an internal function to view to the renderer for a given template id.
    /// @dev It returns the global renderer if the template id does not have a renderer.
    /// @param _tokenId is the id of the template for which the renderer is being viewed.
    function _renderer(uint256 _tokenId) internal view returns (string memory) {
        if (bytes(renderers[_tokenId]).length == 0) return _globalRenderer;
        else return renderers[_tokenId];
    }

    /// @notice This is an internal view function to view the template URI for a given template id.
    /// @dev This is an internal function to view to the template URI for a given template id.
    /// @param _tokenId is the id of the template for which the template URI is being viewed.
    function _template(uint256 _tokenId) internal view returns (string memory) {
        return templates[_tokenId];
    }

    /// @notice This is an internal function to set the global renderer.
    /// @dev This is an internal function to set the global renderer.
    /// @param _newGlobalRenderer is the new global renderer.
    function _setGlobalRenderer(string memory _newGlobalRenderer) internal {
        _globalRenderer = _newGlobalRenderer;
    }

    /// @notice This is an external function to set the global renderer.
    /// @dev This is an external function to set the global renderer. It can only be called by the owner of this contract.
    /// @param _newGlobalRenderer is the new global renderer.
    function setGlobalRenderer(
        string memory _newGlobalRenderer
    ) external onlyOwner {
        _setGlobalRenderer(_newGlobalRenderer);
    }

    /// @notice This is an internal function to set the template URI for a given template id.
    /// @dev This is an internal function to set the template URI for a given template id. It emits a TemplateChanged event.
    /// @param _templateId is the id of the template for which the template URI is being set.
    /// @param _newTemplate is the new template URI.
    function _setTemplate(
        uint256 _templateId,
        string memory _newTemplate
    ) internal {
        templates[_templateId] = _newTemplate;
        lastTermChange[_templateId] = block.number;
        emit TemplateChanged(_templateId, _newTemplate);
    }

    /// @notice This is an external function to set the template URI for a given template id.
    /// @dev This is an external function to set the template URI for a given template id.
    /// @dev It can only be called by the owner of the template.
    /// @param _templateId is the id of the template for which the template URI is being set.
    /// @param _newTemplate is the new template URI.
    function setTemplate(
        uint256 _templateId,
        string memory _newTemplate
    ) external onlyTemplateOwner(_templateId) {
        _setTemplate(_templateId, _newTemplate);
    }

    /// @notice This is an external function to set the metadata for a given template id.
    /// @dev This is an external function to set the metadata for a given template id. It can only be called by the owner of the template.
    /// @param _templateId is the id of the template for which the metadata is being set.
    /// @param _newMetadataUri is the new metadata URI.
    function setMetadataUri(
        uint256 _templateId,
        string memory _newMetadataUri
    ) external onlyTemplateOwner(_templateId) {
        _setMetadataUri(_templateId, _newMetadataUri);
    }

    /// @notice This is an internal function to set the metadata for a given template id.
    /// @dev This is an internal function to set the metadata for a given template id. It emits a MetadataUriChanged event.
    /// @param _templateId is the id of the template for which the metadata is being set.
    /// @param _newMetadataUri is the new metadata URI.
    function _setMetadataUri(
        uint256 _templateId,
        string memory _newMetadataUri
    ) internal {
        metadataUri[_templateId] = _newMetadataUri;
        lastTermChange[_templateId] = block.number;
        emit MetadataUriChanged(_templateId, _newMetadataUri);
    }

    /// @notice This is an internal function to set the terms for a given template id.
    /// @dev This is an internal function to set the terms for a given template id. It emits a TermChanged event.
    /// @param _templateId is the id of the template for which the terms are being set.
    /// @param _key is the key of the term.
    /// @param _value is the value of the term.
    function _setTerm(
        uint256 _templateId,
        string memory _key,
        string memory _value
    ) internal {
        bytes32 hash = _hashKeyId(_key, _templateId);
        terms[hash] = _value;
        lastTermChange[_templateId] = block.number;
        emit TermChanged(_templateId, _key, _value);
    }

    /// @notice This is an external function to set the terms for a given template id.
    /// @dev This is an external function to set the terms for a given template id.
    /// @dev It can only be called by the owner of the template.
    /// @param _templateId is the id of the template for which the terms are being set.
    /// @param _key is the key of the term.
    /// @param _value is the value of the term.
    function setTerm(
        uint256 _templateId,
        string memory _key,
        string memory _value
    ) external onlyTemplateOwner(_templateId) {
        _setTerm(_templateId, _key, _value);
    }

    /// @notice This is an internal function to create a new template.
    /// @dev This is an internal function to create a new template. It emits a TemplateCreated event and returns the template id.
    /// @param _signer is the address of the creator of the said template.
    /// @param _templateUri is the URI of the template.
    /// @return templateId is the id of the template created.
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

    /// @notice This is an external function to create a new template.
    /// @dev This is an external function to create a new template. It creates it on behalf of the caller and returns the template id.
    /// @param _templateUri is the URI of the template.
    /// @return templateId is the id of the template created.
    function mintTemplate(
        string memory _templateUri
    ) external returns (uint256) {
        return _mintTemplate(msg.sender, _templateUri);
    }

    /// @notice This is an external function to create a new template that can only be called by a meta signer.
    /// @dev This is an external function to create a new template that can only be called by a meta signer.
    /// @dev It creates it on behalf of the caller and returns the template id.
    /// @param _templateUri is the URI of the template.
    /// @param _owner is the address of the owner of the template.
    /// @return templateId is the id of the template created.
    function mintTemplate(
        string memory _templateUri,
        address _owner
    ) external onlyMetaSigner returns (uint256) {
        return _mintTemplate(_owner, _templateUri);
    }

    /// @notice Adds a meta signer to the list of signers that can accept terms on behalf of the signer.
    /// @dev This external function calls an internal function that adds a meta signer to the list of signers.
    /// @dev This function is only available to the metasigners and owner of this contract.
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
    /// @param _signer The address of the signer that is being checked to see if it can accept terms on behalf of the signer.
    /// @return A boolean value indicating whether the address is allowed to accept terms on behalf of the signer.
    function isMetaSigner(address _signer) public view returns (bool) {
        return _metaSigners[_signer];
    }

    /// @notice This modifier requires that the msg.sender is either the owner of the template or an approved metasigner.
    /// @dev This modifier requires that the msg.sender is either the owner of the template or an approved metasigner.
    /// @param _templateId is the id of the template.
    modifier onlyTemplateOwner(uint256 _templateId) {
        require(
            (_templateOwners[_templateId] == _msgSender()) ||
                (_metaSigners[_msgSender()]),
            "Not template owner"
        );
        _;
    }

    /// @notice This modifier requires that the msg.sender is either the owner of the contract or an approved metasigner.
    /// @dev This modifier requires that the msg.sender is either the owner of the contract or an approved metasigner.
    modifier onlyMetaSigner() {
        require(
            _metaSigners[_msgSender()] || owner() == _msgSender(),
            "Not a metasigner or Owner"
        );
        _;
    }
}
