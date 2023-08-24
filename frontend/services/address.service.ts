import { encode } from "starknet";


export const formatAddress = (address: string) =>
  encode.addHexPrefix(encode.removeHexPrefix(address).padStart(64, "0"));

export const shortFormOfAddress = (address: string) => {
  return truncateHex(formatAddress(address))
}

export const truncateHex = (fullAddress: string) => {
  const hex = fullAddress.slice(0, 2);
  const start = fullAddress.slice(2, 6);
  const end = fullAddress.slice(-4);

  return `${hex} ${start} ... ${end}`;
};
