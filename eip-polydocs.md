---
eip: <to be assigned>
title: Polydocs
description: Expressing and transferring leases to deeds
author: Ray Deck ([@rhdeck](https://github.com/rhdeck)), Akshay Rakheja ([@akshay-rakheja](https://github.com/akshay-rakheja))
discussions-to: https://github.com/statechangelabs/Polydocs/issues
status: Draft
type: Standards
category (*only required for Standards Track): ERC
created: 2022-12-15
requires: 165
---

## Simple Summary

This standard describes a simple, supple interface for expressing and transferring time-limited rights or obligations, also known as leases.

## Motivation

Time is the ultimate scarce resource. We have less of it every second. Time slicing is critical to ideas of fractional possession - allocating rights for a finite period allows resources to generate more value for more humans without requiring their growth or change.

The surging popularity of ERC721 tokens shows the opportunity for clear, simple standards for allocating property rights on the blockchain. Critical to any idea of property rights is the ability to lend or lease an asset for a limited period of time. Blockchain has a unique opportunity to permit these transactions without trust or a third party guarantor because of the public, immutable record.

However, ERC721 and related standards do not provide functionality to enable leasing of NFTs or other assets for a specific period.

Allocating time-based rights in a standard that lets people know who possesses a given asset, as separate from ultimate ownership. The question is who has possession at a specific point in time. For example, the tenant/occupant of a flat can change between months or years, while ownership is indefinite. This standard looks at the question of allocating those rights, who one can allocate them from (e.g. subletting), and looking into the future to understand who will have those rights for making future use case decisions.

## Use Cases

### Electronic Apartment Lock - "Web3-n-B"

People lease apartments from property owners. Sometimes, we want to re-lease access to that apartment to a third party, a la as an AirBnB host. We want to give access to the apartment to the sub-letter for a specific period of time, and the sub-letter should expect that they will have privacy, e.g. the original tenant does not intrude during this period. The tenant has a lease from the property owner that might last a year. The goal is to tell the apartment lock to allow that tenant access during their term, and to transfer that access to the subletter during their (shorter) stay. A blockchain-powered lock could grant access based on who has the rights to that apartment at that point in time. The contract will allow other sublet arrangements to happen, and because it is on the contract, everything is transparent to the original owner, along with the potential for payment to the original owner for the privilege of making these sublet arrangements.

### Blockchain-powered automobile ignition - "EthCar"

Self-driving cars will be really expensive. Leasing them will probably be important for people to affordably get access. But we don’t need our car all the time. Leasing time windows to people for use of the vehicle will allow people to get access to the car (potentially even telling it to drive to one’s location) for a fixed period of time. All transactions for these rides would run on the chain, and if you get the ride to a location, and you do not need the ride until you are done, you can re-lease time on the vehicle to another lessee in a re-lease transaction. Now there is no wasted “downtime” on the vehicle. The vehicle gates access based on whether the current occupant’s address (e.g. msgSender) is the leaseholder at that point in time.

### Other potential use cases

- Renting streaming media
- Library books
- Staking financial assets
- Land deals
- Travel arrangements
- Seats at sports venues

## Specification

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

**Note**: The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119.

## Rationale

We believe that industry and type-specific interfaces will become common to make dapps easier to build in specific industries - real estate, transportation, finance.

There is some prior art that if anything reinforces the gap in standards for this basic rights management need.Transferring ownership is the only way to “lend,” and that leads to a requirement for massive collateralization (see renft.io). This defeats the affordability aspect of a lease arrangement: one must basically be able to afford to buy the house outright before being able to lease it! In another example, Cryptopunks uses a “white space” function to implement a bespoke method for leasing their NFTs for a fixed 99-day period. (cryptopunks.rent)

## Backwards Compatibility and Test Cases

This is designed as an ERC with the lease keyword added to all functions in order to prevent name conflicts.

## Reference Implementation

[Non-Fungible Travel Services](./nftravel) lets you lease airplanes for future travel. The owners of the airplanes approve leases by travellers in certain future dates. The implementation cuts down on potential gas costs by leveraging the idea of rounding all lease units to complete calendar days (based on midnight-midnight UTC-5).

## Security and Implementation Considerations

### Gas Consumption

Time-limited tokens are more mathematically involved because of the need to compare potentially quite fine distinctions (e.g. to the second or the block) in time windows. Our standard creates the opportunity to reduce that impact through setting a MIN_LEASE_LENGTH and a START_TIME that, when combined, mean the effective number of combinations falls dramatically. E.g. if the MIN_LEASE_LENGTH is 86,400s, and the START_TIME is midnight UTC-7, only whole days are calculated, allowing internal storage to be much simpler.

### Lessee rights vs owner rights

Property rights often consider ownership to be "absolute," but lessee rights are not. Enumerating and managing what it means to be a lessee without blindly just checking "lesseeOf" will be important to connecting on-chain knowledge to real-world considerations.

### Transferability

In a specific case of the preceding, it is entirely probable that a property owner will not want a lessee to further subdivide or reassign their rights. This is common in many residential real estate situations. This proposal would allow that kind of control if the contract considers it explicitly.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
