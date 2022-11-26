import { ethers } from "hardhat";

async function main() {
  
  const [signer_1, signer_2, signer_3, signer_4] = await ethers.getSigners();
  const Registry = await ethers.getContractFactory("Registry");
  const registry = await Registry.deploy();

  await registry.deployed();

  console.log(`Registry deployed to ${registry.address}`);


  // create template 

  const create_template = await registry.connect(signer_2).mintTemplate("templateURI");
  const receipt_create_template = await create_template.wait();
  console.log(`Template created with id ${receipt_create_template?.events[0].args[0]} by signer_2 with address ${signer_2.address}`);


  // set term

  const set_term = await registry.connect(signer_2).setTerm(0, "key", "value");
  const receipt_set_term = await set_term.wait();
  console.log(`Term set with for template id: ${receipt_set_term?.events[0].args[0]} with key: ${receipt_set_term?.events[0].args[1]} and value: ${receipt_set_term?.events[0].args[2]}`);

  // setTerm with signer 2

  const set_term_signer_2 = await registry.connect(signer_2).setTerm(0, "key_2", "value_2");
  const receipt_set_term_signer_2 = await set_term_signer_2.wait();
  console.log(`Term set with for template id: ${receipt_set_term_signer_2?.events[0].args[0]} with key: ${receipt_set_term_signer_2?.events[0].args[1]} and value: ${receipt_set_term_signer_2?.events[0].args[2]}`);

  // setTemplate with signer 2
  const set_template_signer_2 = await registry.connect(signer_2).setTemplate(0, "bafkreifixnauyla72v2axblfn6qxy5i5i4jgy7ucwwnhllhdqoj3y22k6a");
  const set_template_signer_2_receipt = await set_template_signer_2.wait();
  console.log(`Template set with id ${set_template_signer_2_receipt?.events[0].args[0]} by signer_2 with address ${signer_2.address}`);

  // View template URI set by signer 2
  const templateURI = await registry.templateUrl(0);
  console.log(`Template URI set by signer_2 is ${templateURI}`);

  // accept terms with signer 3
  const accept_terms = await registry.connect(signer_3).acceptTerms(0, templateURI);
  const accept_terms_receipt = await accept_terms.wait();
  console.log(`Terms accepted with template id: ${accept_terms_receipt?.events[0].args[0]} by signer_3 with address ${signer_3.address}`);

  // View terms accepted by signer 3 - should return true
  const has_signer_3_accepted_terms = await registry.acceptedTerms(signer_3.address,0);
  console.log(`Signer_3 has accepted terms: ${has_signer_3_accepted_terms}`);

  // View terms accepted by signer 4 - should return false
  const has_signer_4_accepted_terms = await registry.acceptedTerms(signer_4.address,0);
  console.log(`Signer_4 has accepted terms: ${has_signer_4_accepted_terms}`);


  // Test accepttermsFor

  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
