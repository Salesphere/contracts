require("dotenv").config();
const { RPC_URL } = require("./constants");
require("@nomicfoundation/hardhat-verify");

/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
	solidity: "0.8.24",
	networks: {
		sepolia: {
			accounts: [process.env.PRIVATE_KEY],
			url: RPC_URL,
		},
	},
	etherscan: {
		apiKey: {
			sepolia: process.env.ETHERSCAN_API_KEY,
		},
	},
};
