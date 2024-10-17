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
		berachain_bartio: {
			url: "https://bartio.rpc.berachain.com",
			accounts: [process.env.PRIVATE_KEY],
		},
	},
	etherscan: {
		apiKey: {
			sepolia: process.env.ETHERSCAN_API_KEY,
		},
		apiKey: {
			berachain_bartio: "berachain_bartio", // apiKey is not required, just set a placeholder
		},
		customChains: [
			{
				network: "berachain_bartio",
				chainId: 80084,
				urls: {
					apiURL:
						"https://api.routescan.io/v2/network/testnet/evm/80084/etherscan",
					browserURL: "https://bartio.beratrail.io",
				},
			},
		],
	},
};
