// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IRegistry {
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

    /// @notice This function returns the value of a term for a template.
    /// @dev This function returns the value of a term for a template given its template id and key. The key is the term name.
    /// Hash of the key and template id is used to get the value of the term.
    /// @param templateId is the id of the template for which the term is being returned.
    /// @param key is the key for which the value is being looked up.
    /// @return Returns a string value of the term.
    function term(
        uint256 templateId,
        string memory key
    ) external view returns (string memory);

    /// @notice This is an external function that calls an internal function to check if the terms for a template have been accepted by a user.
    /// @dev This is an external function that calls an internal function to check if the terms for a template have been accepted by a user (_signer).
    /// @param _signer is the address of the user for which the acceptance of the terms are being checked.
    /// @param _templateId is the id of the template for which the acceptance of the terms are being checked.
    /// @return Returns a boolean value indicating whether the terms have been accepted or not.
    function acceptedTerms(
        address _signer,
        uint256 _templateId
    ) external view returns (bool);

    /// @notice This is an external function that calls an internal function to accept terms for a template without metadata.
    /// @dev This is an external function that calls an internal function to accept terms for a template.
    /// The terms are accepted on behalf of the the msg.sender without any metadata.
    /// @param _templateId is the id of the template for which the terms are being accepted.
    /// @param _newTemplateUrl is the new template url for the template for which the terms are being accepted.
    function acceptTerms(
        uint256 _templateId,
        string memory _newTemplateUrl
    ) external;

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
    ) external;

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
    ) external;

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
    ) external;

    /// @notice This is an external function that calls an internal function to view the template url for a given template id with an ipfs prefix.
    /// @dev This is an external function that calls an internal function to view the template url for a given template id with an ipfs prefix.
    /// @param templateId is the id of the template for which the template url is being viewed.
    function templateUrl(
        uint256 templateId
    ) external view returns (string memory);

    /// @notice This is an external function that calls an internal function to view the template url for a given template id with a given prefix.
    /// @dev This is an external function that calls an internal function to view the template url for a given template id with a given prefix.
    /// @param templateId is the id of the template for which the template url is being viewed.
    /// @param prefix is the prefix for the template url.
    function templateUrlWithPrefix(
        uint256 templateId,
        string memory prefix
    ) external view returns (string memory);

    /// @notice This is an external function to set the global renderer.
    /// @dev This is an external function to set the global renderer. It can only be called by the owner of this contract.
    /// @param _newGlobalRenderer is the new global renderer.
    function setGlobalRenderer(string memory _newGlobalRenderer) external;

    /// @notice This is an external function to set the template URI for a given template id.
    /// @dev This is an external function to set the template URI for a given template id.
    /// @dev It can only be called by the owner of the template.
    /// @param _templateId is the id of the template for which the template URI is being set.
    /// @param _newTemplate is the new template URI.
    function setTemplate(
        uint256 _templateId,
        string memory _newTemplate
    ) external;

    /// @notice This is an external function to set the metadata for a given template id.
    /// @dev This is an external function to set the metadata for a given template id. It can only be called by the owner of the template.
    /// @param _templateId is the id of the template for which the metadata is being set.
    /// @param _newMetadataUri is the new metadata URI.
    function setMetadataUri(
        uint256 _templateId,
        string memory _newMetadataUri
    ) external;

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
    ) external;
}
