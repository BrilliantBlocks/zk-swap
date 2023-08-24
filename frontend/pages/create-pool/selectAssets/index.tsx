import React from 'react'
import { Typography } from '@mui/material'
import { Box } from '@mui/material'
import styles from './SelectAssets.module.css'
import { PoolType } from '../selectPoolType'
import { ModalEth } from '../../../components/Dashboard/create-pool/modalETH'
import { ModalNft } from '../../../components/Dashboard/create-pool/modalNFT'

export interface SelectAssetsProps {
	poolType: PoolType
	formField?: any
	name?: any
}
export interface InputProps {
	deposit: string
	receive: string
}
const SelectAssets = (props: any) => {
	const {
		formField: { assetsDeposit }
	} = props

	return (
		<>
			<Box className={styles.flex}>
				<Box className={styles.container}>
					<Typography align="left" className={styles.headline}>
						I want to...
					</Typography>
					<Box className={styles.content}>
						<Typography className={styles.subheading}>
							deposit
							{props.poolType === 'Buy NFTs with tokens' ? <ModalEth /> : <ModalNft name={assetsDeposit.name} />}
						</Typography>
					</Box>
					<Typography className={styles.headline}>and...</Typography>
					<Box className={styles.content}>
						<Typography className={styles.subheading}>
							receive
							{props.poolType === 'Buy NFTs with tokens' ? <ModalNft name={assetsDeposit.name} /> : <ModalEth />}
						</Typography>
					</Box>
				</Box>
			</Box>
		</>
	)
}

export default SelectAssets
