---
eip: <to be assigned>
title: Polydocs
description: Immutable Document Signing on the Blockchain
author: Ray Deck ([@rhdeck](https://github.com/rhdeck)), Akshay Rakheja ([@akshay-rakheja](https://github.com/akshay-rakheja))
discussions-to: https://github.com/statechangelabs/Polydocs/issues
status: Draft
type: Standards Track
category (*only required for Standards Track): Interface
created: 2023-2-08
requires (optional): <EIP number(s)>
---

## Abstract

The following standard allows for the implementation of a standard API for document signing using smart contracts. This standard provides basic functionality to track and sign documents.

Right now, financial assets and intellectual property are accompanied with a legal framework of usage rights. Licenses about these rights are expressed and subjected to the terms and conditions that govern how users own or interact with a product or platform.

Everyone’s familiar with the standardized “agree to the following terms and conditions” that accompany the use of various websites and products.

But how do such licenses exist on a blockchain today?

It’s a thorny problem, especially for complex financial products.

Enter Polydocs: We have created a smart document and added meta-signing that makes it easy and safe to own or allocate complicated intellectual, financial, and rights-oriented digital assets on the blockchain. These assets are more complex than the cash or deeds we sometimes use for analogies. Some of the most common examples of these assets are:

- NFT's with intellectual property that involve rights and responsibilities (eg: Music NFT's, real world assets like real estate).
- Financial instruments such as SMB loans require acceptance on both sides.
- Communities need agreement on government by norms and rules.
- KYC/AML documents that need to be signed by both parties.

## Motivation (Optional)

Smart contracts are increasingly used for managing the allocation of digital assets. These assets are more complex than the cash or deeds we sometimes use for analogies. Intellectual property involves rights and responsibilities. Financial instruments require acceptance on both sides. Communities need agreement on government by norms and rules.

The articulation and acceptance of these terms should be a first-class consideration for those creating digital assets and services. That's why we made Polydocs.

## Specification

**Note**: The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119.

```solidity
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

    /// @notice This is an external function to create a new template.
    /// @dev This is an external function to create a new template. It creates it on behalf of the caller and returns the template id.
    /// @param _templateUri is the URI of the template.
    /// @return templateId is the id of the template created.
    function mintTemplate(
        string memory _templateUri
    ) external returns (uint256);

    /// @notice This is an external function to create a new template that can only be called by a meta signer.
    /// @dev This is an external function to create a new template that can only be called by a meta signer.
    /// @dev It creates it on behalf of the caller and returns the template id.
    /// @param _templateUri is the URI of the template.
    /// @param _owner is the address of the owner of the template.
    /// @return templateId is the id of the template created.
    function mintTemplate(
        string memory _templateUri,
        address _owner
    ) external returns (uint256);
}

```

## Rationale

Say a financial institution wants to provide more crypto-native offerings or finance Web3 businesses, but they’re legally required to perform Know-Your-Customer (KYC) checks.

After a user enters the required information for KYC (which, in the future, can be backed by privacy-oriented solutions like zk-powered PolygonID), the user can attest to having performed the KYC, with a link to the documentation provided by Polydocs.

Suddenly, financial organizations, with access to a ton of capital, have the compliance attestations and legal framework to avert risk. They can begin to open up capital to users have been de-risked using this KYC/AML process.

By creating a framework to sign smart documents and demystify smart contracts, Polydocs can help bridge the gap between traditional industries and crypto ecosystem.

## Backwards Compatibility (Optional)

## Test Cases (Optional)

## Reference Implementation (Optional)

[gmSign](https://admin.gmsign.xyz/) was built during HelloSign Hackathon in 2022. It lets you mint NFT's with "Can't Be Evil" licenses from a16z. gmSign connects HelloSign with decentralized applications by enabling signatures over the HelloSign API which, on callback, makes a gasless record of that signature on-chain so that there is clarity as to who signed which agreement when. This record of sign is maintained by Polydocs in a public registry of signed documents.

[Polydocs](https://polydocs.xyz/) was built during HackFS and Polygon's Buidl It Hackathons in 2022. It comprises of 3 core parts:

- [Signing App](https://sign.polydocs.xyz) is a gasless mini-app to enable a customer to accept the terms of an agreement and get recorded on the blockchain using a metatransaction.
- [Admin App](https://admin.polydocs.xyz) is a gasless admin system for creating, deploying and managing contracts with polydocs agreements. 
- A known templates registry of documents hosted on IPFS.

## Security and Implementation Considerations (Required)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
