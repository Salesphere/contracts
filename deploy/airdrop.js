import { ContractFactory, Wallet, JsonRpcProvider } from "ethers";
import { config } from "dotenv";
config();

import contractData from "../artifacts/contracts/Airdrop.sol/MultiUserAirdropWithPercentageFee.json" assert { type: "json" };

const provider = new JsonRpcProvider(process.env.RPC_URL);
const wallet = new Wallet(process.env.PRIVATE_KEY, provider);

const deployAirdrop = async () => {
	const factory = new ContractFactory(
		contractData.abi,
		contractData.bytecode,
		wallet
	);
	const contract = await factory.deploy();
	await contract.waitForDeployment();

	console.log("contract deployed to ", await contract.getAddress());
};

deployAirdrop();