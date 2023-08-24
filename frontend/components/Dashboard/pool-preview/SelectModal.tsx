import React, { useState } from 'react'
import { Dialog, DialogTitle, Button, Tooltip, IconButton, DialogContent, FormGroup, FormControlLabel, Checkbox } from '@mui/material'
import { Box } from '@mui/material'
import styles from '../../../pages/pool-preview/PoolPreview.module.css'
import PrimaryButton from '../../PrimaryButton'
import HelpIcon from '@mui/icons-material/Help'
import CardNFT from '../../Card/CardPoolPreview'
import { withdrawNFT, walletAddress, checkSupportedCollection, depositNFTs, getNFTsOfCollection, getMetaData } from '../../../services/wallet.service'

type ModalSelectProps = {
	title: string
	poolAddress: string
	collectionAddress: string
	type: 'deposit' | 'withdraw'
}

export type NFT = {
	CollectionContractAddress: string
	TokenId: string
	Metadata: {
		name: string
		image: string
	}
	isChecked: boolean
}

type SupportedCollection = { collectionAddress: string; isSupported: boolean }

export const ModalSelect: React.FC<ModalSelectProps> = (props): React.ReactElement => {
	const [openSelectModal, setOpenSelectModal] = useState(false)
	const [nfts, setNfts] = useState<NFT[]>([])

	const [count, setCount] = useState(0)

	const handleOpen = async () => {
		setOpenSelectModal(true)

		try {
			if (props.type === 'deposit') {
				const [address, error] = await walletAddress()
				//const result = await fetch(`https://api.mintsquare.io/nfts/owner/starknet-testnet/${address}`)
				const result = await fetch(`https://api.mintsquare.io/nfts/starknet-testnet?collection=${props.collectionAddress}&owner_address=${address}`)
				const data = await result.json()
				let supportedNfts: NFT[] = []
				const processedCollections: SupportedCollection[] = []

				data
					.filter((nft: NFT) => nft.CollectionContractAddress === props.collectionAddress)
					.filter(async (nft: NFT) => {
						const found = processedCollections.find((pc: SupportedCollection) => pc.collectionAddress === nft.CollectionContractAddress)

						if (!found) {
							const isSupported = await checkSupportedCollection(props.poolAddress, nft.CollectionContractAddress)

							if (isSupported) {
								supportedNfts.push(nft)
							}

							processedCollections.push({
								collectionAddress: nft.CollectionContractAddress,
								isSupported
							})
						} else {
							if (found.isSupported) {
								supportedNfts.push(nft)
							}
						}
					})

				setNfts(supportedNfts)
				console.log('supported nfts', supportedNfts)
			} else if (props.type === 'withdraw') {
				const nfts = await getNFTsOfCollection(props.poolAddress, props.collectionAddress)
				const nftsMetadata = await Promise.all(
					nfts.map(async (tokenId: any) => {
						const url = await getMetaData(props.collectionAddress, tokenId)
						const metadata = await fetch(url)

						return metadata.json()
					})
				)

				setNfts(nftsMetadata)
			}
		} catch (error) {
			console.error(error)
		}
	}
	const handleClose = () => {
		setOpenSelectModal(false)
	}

	const handleChange = (e: any) => {
		const { name, checked } = e.target
		if (name === 'selectAll') {
			let tempNft = nfts.map((nft) => {
				return { ...nft, isChecked: checked }
			})
			setNfts(tempNft)
			if (checked) {
				setCount(tempNft.length)
			} else {
				setCount(0)
			}
		} else {
			let tempNft = nfts.map((nft) => (nft.Metadata.name === name ? { ...nft, isChecked: checked } : nft))
			setNfts(tempNft)
			if (checked) {
				setCount(count + 1)
			} else {
				setCount(count - 1)
			}
		}
	}

	const handleWithdrawNfts = async () => {
		const isCheckedNfts = nfts.filter((nft) => nft.isChecked)
		console.log('withdraw nfts', isCheckedNfts)
		await withdrawNFT(props.poolAddress, props.collectionAddress, isCheckedNfts)
		setOpenSelectModal(false)
	}

	const handleDepositNfts = async () => {
		const isCheckedNfts = nfts.filter((nft) => nft.isChecked)
		console.log('deposit nfts', isCheckedNfts)
		await depositNFTs(props.poolAddress, props.collectionAddress, isCheckedNfts)
		setOpenSelectModal(false)
	}

	return (
		<>
			<PrimaryButton onClick={handleOpen} backgroundColor="#141414" className={styles.btn}>
				{props.title}
			</PrimaryButton>
			<Dialog open={openSelectModal} onClose={handleClose}>
				<Box className={styles.select_container}>
					<DialogTitle align="center" className={styles.content_title_container}>
						<Box className={styles.content_left}>
							{props.title}
							<Tooltip title="Information about operation." placement="right">
								<IconButton>
									<div className={styles.color_white}>
										<HelpIcon />
									</div>
								</IconButton>
							</Tooltip>
						</Box>
						<Box className={styles.content_x_right}>
							<Button className={`${styles.dialogCloseButton} ${styles.color_white}`} onClick={handleClose}>
								X
							</Button>
						</Box>
					</DialogTitle>
					<DialogContent>
						<Box>
							<FormGroup>
								<FormControlLabel
									control={
										<Checkbox
											className={styles.color_white}
											checked={!nfts.some((nft) => nft?.isChecked !== true)}
											onChange={handleChange}
											name="selectAll"
										/>
									}
									label="Select All"
								/>
							</FormGroup>
						</Box>
						<Box sx={{ display: 'flex', flexWrap: 'wrap', marginBottom: '1rem', gap: '0.5rem' }}>
							{nfts.map((nft: NFT, index: any) => {
								return nfts.length < 8 ? (
									<CardNFT name={nft.Metadata?.name} nft={nft} selected={nft?.isChecked || false} onChange={handleChange} key={index + 1} />
								) : (
									<p>Hey</p>
								)
							})}
						</Box>
						<Box className={styles.select_dialog_cta}>
							{props.title === 'deposit' ? (
								<Button variant="contained" className={`${styles.btn} ${styles.bg} ${styles.button}`} onClick={() => handleDepositNfts()}>
									{props.title} {count}
								</Button>
							) : (
								<Button variant="contained" className={`${styles.btn} ${styles.bg} ${styles.button}`} onClick={() => handleWithdrawNfts()}>
									{props.title} {count}
								</Button>
							)}
						</Box>
					</DialogContent>
				</Box>
			</Dialog>
		</>
	)
}
