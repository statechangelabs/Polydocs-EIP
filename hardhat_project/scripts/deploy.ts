import { ethers } from "hardhat";

async function main() {
  
  // const [signer_1, signer_2, signer_3, signer_4] = await ethers.getSigners();
  const Registry = await ethers.getContractFactory("Registry");
  const registry = await Registry.deploy();

  await registry.deployed();

  console.log(`Registry deployed to ${registry.address}`);


  // // create template 

  // const create_template = await registry.connect(signer_2).mintTemplate("templateURI");
  // const receipt_create_template = await create_template.wait();
  // console.log(`Template created with id ${receipt_create_template?.events[0].args[0]} by signer_2 with address ${signer_2.address}`);


  // // set term

  // const set_term = await registry.connect(signer_2).setTerm(0, "key", "value");
  // const receipt_set_term = await set_term.wait();
  // console.log(`Term set with for template id: ${receipt_set_term?.events[0].args[0]} with key: ${receipt_set_term?.events[0].args[1]} and value: ${receipt_set_term?.events[0].args[2]}`);

  // // setTerm with signer 2

  // const set_term_signer_2 = await registry.connect(signer_2).setTerm(0, "key_2", "value_2");
  // const receipt_set_term_signer_2 = await set_term_signer_2.wait();
  // console.log(`Term set with for template id: ${receipt_set_term_signer_2?.events[0].args[0]} with key: ${receipt_set_term_signer_2?.events[0].args[1]} and value: ${receipt_set_term_signer_2?.events[0].args[2]}`);

  // // setTemplate with signer 2
  // const set_template_signer_2 = await registry.connect(signer_2).setTemplate(0, "bafkreifixnauyla72v2axblfn6qxy5i5i4jgy7ucwwnhllhdqoj3y22k6a");
  // const set_template_signer_2_receipt = await set_template_signer_2.wait();
  // console.log(`Template set with id ${set_template_signer_2_receipt?.events[0].args[0]} by signer_2 with address ${signer_2.address}`);

  // // View template URI set by signer 2
  // const templateURI = await registry.templateUrl(0);
  // console.log(`Template URI set by signer_2 is ${templateURI}`);

  // // accept terms with signer 3
  // // const accept_terms = await registry.connect(signer_3).acceptTerms(0, templateURI);
  // // const accept_terms_receipt = await accept_terms.wait();
  // // console.log(`Terms accepted with template id: ${accept_terms_receipt?.events[0].args[0]} by signer_3 with address ${signer_3.address}`);

  // // View terms accepted by signer 3 - should return false
  // const has_signer_3_accepted_terms = await registry.acceptedTerms(signer_3.address,0);
  // console.log(`Signer_3 has accepted terms: ${has_signer_3_accepted_terms}`);

  // // // View terms accepted by signer 4 - should return false
  // // const has_signer_4_accepted_terms = await registry.acceptedTerms(signer_4.address,0);
  // // console.log(`Signer_4 has accepted terms: ${has_signer_4_accepted_terms}`);

  // // signer 1 (owner of the contract) approves signer_4 to be metasigner

  // const approve_metasigner_signer_4 = await registry.connect(signer_1).approveMetaSigner(signer_4.address, true);
  // const approve_metasigner_signer_4_receipt = await approve_metasigner_signer_4.wait();
  // // console.log(`Signer_3 has approved signer_4 to accept terms on their behalf: ${approve_metasigner_signer_4_receipt?.events[0].args[0]}`);
  // console.log("Signer_4 is approved as a metasigner");

  // //check if signer_4 is approved as a metasigner
  // const is_signer_4_approved = await registry.isMetaSigner(signer_4.address);
  // console.log(`Signer_4 is approved as a metasigner: ${is_signer_4_approved}`);


  // // signer 3 signature

  // const signer_3_signature = await signer_3.signMessage(templateURI);
  // console.log(`Signer_3 signature: ${signer_3_signature}`);

  // // signer 4  (metasigner) signs on the behalf of signer 3
  // const accept_terms_signer_4 = await registry.connect(signer_4)['acceptTermsFor(address,string,uint256,bytes)'](signer_3.address, templateURI, 0, signer_3_signature);
  // const accept_terms_signer_4_receipt = await accept_terms_signer_4.wait();
  // console.log("Signer 4 accepted terms on behalf of signer 3");

  // // View terms accepted by signer 3 - should return false
  // const has_signer_3_accepted_terms_1 = await registry.acceptedTerms(signer_3.address,0);
  // console.log(`Signer_3 has accepted terms: ${has_signer_3_accepted_terms_1}`);

  // // Is signer 3 a template owner
  // const template_0_owner = await registry._templateOwners(0);
  // console.log("Owner of template 0 is: ", template_0_owner);
  // console.log("Signer 3 address is ", signer_3.address);

  // if (template_0_owner == signer_3.address) {
  //   console.log(`Signer_3 is a template owner of template 0(only 1 minted so far)`);
  // } else {
  //   console.log(`Signer_3 is not a template owner of template 0`);
  // }

  // // signer 4 mints a new template on behalf of signer 3

  // const signer_3_signature_2 = await signer_3.signMessage("templateURI_2");
  // console.log(`Signer_3 signature for templateURI_2: ${signer_3_signature_2}`);

  // const mint_template_signer_4 = await registry.connect(signer_4).mintTemplateFor(signer_3.address, "templateURI_2", signer_3_signature_2);
  // const mint_template_signer_4_receipt = await mint_template_signer_4.wait();

  // console.log(`Signer_4 minted a new template on behalf of signer_3 with id: ${mint_template_signer_4_receipt?.events[0].args[0]}`);

  // // Is signer 3 a template owner
  // const template_1_owner = await registry._templateOwners(1);
  // console.log("Owner of template 1 is: ", template_1_owner);
  // console.log("Signer 3 address is ", signer_3.address);

  // if (template_1_owner == signer_3.address) {
  //   console.log(`Signer_3 is a template owner of template 1`);
  // }
  // else {
  //   console.log(`Signer_3 is not a template owner of template 1`);
  // }

  // const set_template_signer_3 = await registry.connect(signer_3).setTemplate(1, "bafkreifixnauyla72v2axblfn6qxy5i5i4jgy7ucwwnhllhdqoj3y22k6a");
  // const set_template_signer_3_receipt = await set_template_signer_3.wait();
  // console.log(`Template set with id ${set_template_signer_3_receipt?.events[0].args[0]} by signer_3 with address ${signer_3.address}`);

  // // View template URI set by signer 3
  // const templateURI_1 = await registry.templateUrlWithPrefix(1,"https://ipfs.io:/ipfs/");
  // console.log(`Template URI set by signer_3 is ${templateURI_1}`);

  // const set_terms_signer_3 = await registry.connect(signer_3).setTerm(1, "key_abc", "value_abc");
  // const set_terms_signer_3_receipt = await set_terms_signer_3.wait();
  // console.log(`Terms set for template with id ${set_terms_signer_3_receipt?.events[0].args[0]} by signer_3 with address ${signer_3.address}`);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
