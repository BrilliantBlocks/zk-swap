import { NextPage } from "next";
import { useEffect, useState } from "react";
import { shortFormOfAddress } from "../address.service";
import {
  addWalletChangeListener,
  connectWallet,
  removeWalletChangeListener,
  silentConnectWallet,
  chainId,
} from "../wallet.service";
import PrimaryButton from '../../components/PrimaryButton';
import { Box } from '@mui/material'
import styles from '../../components/Navigation/Navbar.module.css'

const ArgentX: NextPage = () => {
  const [address, setAddress] = useState<string>();
  const [chain, setChain] = useState<string | undefined>(undefined);
  const [isConnected, setConnected] = useState(false);

  const updateWalletState = async () => {
    const wallet = await silentConnectWallet();
    const currentChainId = await chainId();

    setAddress(wallet?.selectedAddress);
    setChain(currentChainId);
    setConnected(!!wallet?.isConnected);
  };

  useEffect(() => {
    updateWalletState();
    addWalletChangeListener(updateWalletState);

    return () => {
      removeWalletChangeListener(updateWalletState);
    };
  }, []);

  useEffect(() => {
    if (address) {
      localStorage.setItem('accountAddress', address);
    }
    if (chain) {
      localStorage.setItem('chainId', chain);
    }
  }, [address, chain]);

  const handleConnectClick = async () => {
    await connectWallet();
    await updateWalletState();
  };

  return (
    <>
      {isConnected ? (
        <PrimaryButton backgroundColor='#9CC1D7' className={styles.btn_connected}>
          {address && shortFormOfAddress(address)}
        </PrimaryButton>
      ) : (
        <PrimaryButton 
          backgroundColor="#9CC1D7" 
          onClick={handleConnectClick} 
          className={styles.btn_accent}
        >
          Connect Wallet
        </PrimaryButton>
      )}
    </>
  );
};

export default ArgentX;
