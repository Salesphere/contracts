const { ContractFactory, Wallet, JsonRpcProvider } = require("ethers");
require("dotenv").config();
const { RPC_URL, honey_CA_BARTIO, usdc_CA_BARTIO } = require("../constants");

const {
	abi,
	bytecode,
} = require("../artifacts/contracts/CrowdFunding.sol/CrowdFunding.json");

const provider = new JsonRpcProvider(RPC_URL);
const wallet = new Wallet(process.env.PRIVATE_KEY, provider);

const deployCrowdFunding = async () => {
	console.log("Deploying Crowdfunding contract ");
	const factory = new ContractFactory(abi, bytecode, wallet);
	const contract = await factory.deploy(usdc_CA_BARTIO, honey_CA_BARTIO);
	await contract.waitForDeployment();

	console.log("contract deployed to ", await contract.getAddress());
};

deployCrowdFunding();
