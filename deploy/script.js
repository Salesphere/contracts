import { ContractFactory, Wallet, JsonRpcProvider } from "ethers";
import { config } from "dotenv";
config();
import path from "path";

import contractData from "../artifacts/contracts/MyToken.sol/TokenFactory.json" assert {type: "json"}

const provider = new JsonRpcProvider(process.env.RPC_URL);
const wallet = new Wallet(process.env.PRIVATE_KEY, provider);

const deploy = async () => {

	const factory = new ContractFactory(contractData.abi, contractData.bytecode, wallet)
	const contract = await factory.deploy()
	await contract.waitForDeployment()

	console.log("contract deployed to ", await contract.getAddress())
};

deploy();
