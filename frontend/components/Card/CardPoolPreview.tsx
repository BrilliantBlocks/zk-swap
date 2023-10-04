import React from 'react'
import styles from '../../pages/pool-preview/PoolPreview.module.css'
import { Box, Typography } from '@mui/material'
import Image from 'next/image'
import { NFT } from '../Dashboard/pool-preview/SelectModal'

export interface CardProps {
	name?: string
	onChange?: any
	selected?: any
	onClick?: any
	myKey?: any
	nft?: NFT
}

const CardNFT: React.FC<CardProps> = (props): React.ReactElement => {
	return (
		<Box className={styles.nft_card} key={props.myKey}>
			<Box sx={{ position: 'relative', left: '0px', marginBottom: '0.5rem ', marginTop: '0.3rem' }} onClick={props.onClick}>
				{props.onChange && (
					<>
						<input type="checkbox" className="form-check-input" name={props.name} checked={props.selected} onChange={props.onChange} />
					</>
				)}
			</Box>
			{props.nft ? <Image src={props.nft.Metadata.image} alt={`banner image`} width={65} height={65} objectFit="cover" /> : null}
			<Typography sx={{ fontSize: '14px!important' }}>{props.nft ? props.nft.Metadata.name : props.name}</Typography>
		</Box>
	)
}
export default CardNFT
