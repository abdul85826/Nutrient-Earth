// ==============================================================================
// Nutrient Earth — Viem Client for Base Sepolia (84532) & Base Mainnet (8453)
// ==============================================================================

import { createPublicClient, http, defineChain } from 'viem';

export const baseSepolia = defineChain({
  id: 84532,
  name: 'Base Sepolia',
  nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
  rpcUrls: {
    default: { http: [process.env.BASE_SEPOLIA_RPC_URL || 'https://sepolia.base.org'] },
  },
  blockExplorers: {
    default: { name: 'BaseScan', url: 'https://sepolia.basescan.org' },
  },
  testnet: true,
});

export const baseMainnet = defineChain({
  id: 8453,
  name: 'Base',
  nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
  rpcUrls: {
    default: { http: [process.env.BASE_MAINNET_RPC_URL || 'https://mainnet.base.org'] },
  },
  blockExplorers: {
    default: { name: 'BaseScan', url: 'https://basescan.org' },
  },
  testnet: false,
});

export function getPublicClient(chainId: number = 84532) {
  const chain = chainId === 8453 ? baseMainnet : baseSepolia;
  return createPublicClient({
    chain,
    transport: http(),
  });
}
