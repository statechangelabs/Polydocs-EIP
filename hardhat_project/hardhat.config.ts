import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();

// console.log(process.env);
const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    polygonMumbai: process.env.ALCHEMY_MUMBAI
      ? {
          url: process.env.ALCHEMY_MUMBAI || "",
          accounts: [process.env.PK || ""],
        }
      : undefined,
    polygon: process.env.ALCHEMY_POLYGON
      ? {
          url: process.env.ALCHEMY_POLYGON || "",
          accounts: [process.env.PK || ""],
        }
      : undefined,
  },
  etherscan: {
    apiKey: {
      polygonMumbai: process.env.POLYGON_API || "",
      polygon: process.env.POLYGON_API || "",
    },
  },
    
};

export default config;
