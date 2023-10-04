import React, { useEffect, useState } from 'react'
import styles from './Cards.module.css'
import Image from 'next/image'
import { Box, Typography } from '@mui/material'
import eth from '../assets/images/eth-logo.png'
import { TbArrowsHorizontal, TbArrowUpRight } from 'react-icons/tb'
import PrimaryButton from '../PrimaryButton'
import { ModalEdit } from '../Dashboard/pool-preview/EditModal'
import {
	addSupportedCollections,
	checkSupportedCollection,
	deployPool,
	getPoolConfig,
	isPoolPaused,
	pausePool,
	setPoolParams,
	getNFTsOfCollection,
	getBalance,
	getNameFromCollection
} from '../../services/wallet.service'
import { BuyPool, ETHAddress, SellPool } from '../../utils/manuallyDefinedValues'
import { toast } from 'react-hot-toast'
import Link from 'next/link'
import { PoolProps } from '../../utils/helper-functions/storePool'

interface PoolsCardProps {
	transactionHash?: string
	paramsTransactionHash?: string
	collectionTransactionHash?: string
	poolAddress?: any
	collectionAddress?: any
	ethAddress?: typeof ETHAddress
	startPrice: string
	deltaAmount: string
	poolType?: any
	id: any
	owner: string | undefined
}

const addFieldToPoolStorage = (poolAddress: string, key: 'paramsTransactionHash' | 'collectionTransactionHash', value: string) => {

	const getPoolParams = localStorage.getItem('pool') || '[]'
	var data = JSON.parse(getPoolParams) || []

	data.forEach((item: PoolProps) => {
		if (item?.poolAddress === poolAddress) {	
			
			item[key] = value
			localStorage.setItem('pool', JSON.stringify(data))
		}
	})
}

const PoolsCard: React.FC<PoolsCardProps> = (props): React.ReactElement => {
	const [inputValue, setInputValue] = useState('')
	const [accountAddress, setAccountAddress] = useState<string>('')
	const [checkedPause, setCheckedPause] = useState<boolean>(false)
	const [ethBalance, setEthBalance] = React.useState<number>(0)
	const [nftBalance, setNftBalance] = React.useState<number>(0)
	const [collectionName, setCollectionName] = useState<string>('Collection Name')

	let PoolHashVariable: string

	if (props.poolType === 'Buy NFTs with tokens') {
		PoolHashVariable = BuyPool
	} else {
		PoolHashVariable = SellPool
	}

	useEffect(() => {
		const account = localStorage.getItem('accountAddress') as string
		setAccountAddress(account)
	}, [])

	useEffect(() => {
		if (props.poolAddress && props.poolAddress !== '') {
			;(async () => {

				try {

					const name = await getNameFromCollection(props.collectionAddress)
					const nfts = await getNFTsOfCollection(props.poolAddress, props.collectionAddress)
					const balance = await getBalance(props.poolAddress)

					setCollectionName(name)
					setNftBalance(nfts.length)
					setEthBalance(balance)

					const data: boolean = await isPoolPaused(props.poolAddress)

					setCheckedPause(data)
					const poolConfig = await getPoolConfig(props.poolAddress)

					if (
						`${poolConfig.delta}` !== props.deltaAmount &&
						`${poolConfig.price}` !== props.startPrice &&
						(!props.paramsTransactionHash || props.paramsTransactionHash === '')
					) {
						const paramsTransactionHash = await setPoolParams(props.poolAddress, props.startPrice, props.deltaAmount)
						addFieldToPoolStorage(props.poolAddress, 'paramsTransactionHash', paramsTransactionHash)
					} else {
						const checkSupportCollection: any = await checkSupportedCollection(props.poolAddress, props.collectionAddress)
						if (!checkSupportCollection && (!props.collectionTransactionHash || props.collectionTransactionHash === '')) {
							const collectionTransactionHash = await addSupportedCollections(props.poolAddress, props.collectionAddress)
							addFieldToPoolStorage(props.poolAddress, 'collectionTransactionHash', collectionTransactionHash)
						}
					}
				} catch (error) {
					console.error('Error', error)
				}
			})()
		}
	}, [])

	const handleChange = (event: any) => {
		setInputValue(event?.target.value)
	}

	return (accountAddress == props.owner ? 
		<Box className={styles.pools_wrapper}>
			<Box>
				<Box className={styles.pool_container}>
					{' '}
					<Typography className={styles.pools_content_headline}>Pool address: {props.poolAddress ? props.poolAddress : ''} </Typography>
				</Box>
			</Box>
			<Box className={styles.pools_flex}>
				<Box className={styles.pools_content}>
					<Box className={styles.pools_content_visual}>
						<Image src={eth} width="24" height="26" className={styles.round_img} />
						<Typography className={styles.pools_content_text}>ETH </Typography>
					</Box>

					<div className={styles.pools_content_flex}>
						<TbArrowsHorizontal size={25} />
					</div>
					<Box className={styles.pools_content_visual}>
						<Image src={'/starknet.png'} alt={` banner image`} width={25} height={25} objectFit="cover" />
						<Typography className={styles.pools_content_text}>{collectionName}</Typography>
					</Box>
				</Box>
				<Box className={styles.pools_right_content}>
					<Typography className={`${styles.pools_content_text} ${styles.text_s}`}>Balance:</Typography>
					<Box className={styles.pools_end}>
						<Box className={styles.pools_content_flex}>
							<Typography className={styles.pools_right_text}> {nftBalance}</Typography>
							<div className={styles.pools_img}>
								<Image src={'/starknet.png'} alt={` banner image`} width={25} height={25} objectFit="cover" className={styles.round_img} />
							</div>
							<Typography className={`${styles.card_subtitle} ${styles.pools_accent}`}> NFT</Typography>
						</Box>
						<Box className={styles.visual_content}>
							<Typography className={styles.pools_right_text}> {ethBalance}</Typography>
							<Image src={eth} width="25" height="8" className={styles.round_img} />{' '}
							<Typography className={`${styles.card_subtitle} ${styles.pools_accent}`}> ETH</Typography>
						</Box>
					</Box>
				</Box>
			</Box>
			<Box className={styles.pools_btn_container}>
				{props.poolAddress ? (
					<>
						{checkedPause ? (
							''
						) : (
							<PrimaryButton backgroundColor="#333" border="1px solid rgb(217, 220, 223)" className={styles.text}>
								<Link
									href={{
										pathname: `/pool-preview`,
										query: {
											poolAddress: `${props.poolAddress}`,
											startPrice: `${props.startPrice}`,
											deltaAmount: `${props.deltaAmount}`,
											owner: `${props.owner}`
										}
									}}
								>
									View pool
								</Link>
							</PrimaryButton>
						)}
						<PrimaryButton
							backgroundColor="#333"
							border="1px solid rgb(217, 220, 223)"
							className={styles.text}
							onClick={() => {
								pausePool(props.poolAddress)
								toast.custom('This will take a few minutes, please wait')
							}}
						>
							{checkedPause ? 'Resume Pool' : 'Pause Pool'}
						</PrimaryButton>
					</>
				) : (
					<>
						<ModalEdit
							buttonTitle="Edit"
							startPrice={props.startPrice}
							deltaAmount={props.deltaAmount}
							id={props.id}
							poolAddress={props.poolAddress}
							transactionHash={props.transactionHash}
							ethAddress={props.ethAddress}
							poolType={props.poolType}
							onChange={handleChange}
							value={inputValue}
							bgColor="#333"
							border="1px solid rgb(217, 220, 223)"
							className={styles.text}
						/>
						<PrimaryButton
							backgroundColor="#333"
							border="1px solid rgb(217, 220, 223)"
							className={styles.text}
							onClick={() => {
								//deployPool(PoolHashVariable, props.id)
								toast.success('Your pool is being deployed')
							}}
						>
							Deploy pool
						</PrimaryButton>

						{/* Should generally appear only after pool deployment */}
						<PrimaryButton backgroundColor="#333" border="1px solid rgb(217, 220, 223)" className={styles.text}>
								<Link
									href={{
										pathname: `/pool-preview`,
										query: {
											poolAddress: `${props.ethAddress}`,
											startPrice: `${props.startPrice}`,
											deltaAmount: `${props.deltaAmount}`,
											owner: `${props.owner}`
										}
									}}
								>
									View pool
								</Link>
						</PrimaryButton>
					</>
				)}
			</Box>

			<Box className={styles.pools_flex_b}>
				<Box>
					<Typography className={styles.pools_b_headline}>Current Price</Typography>
					<Typography className={styles.pools_b_subheading}>{props.startPrice} eth</Typography>
				</Box>
				<Box>
					<Typography className={styles.pools_b_headline}>Bonding Curve:</Typography>
					<Box className={styles.icon_box}>
						<Typography className={styles.pools_b_subheading}>Linear</Typography>
						<div className={styles.icon_arrow}>
							<TbArrowUpRight size={20} />
						</div>
					</Box>
				</Box>
				<Box>
					<Typography className={styles.pools_b_headline}>Delta:</Typography>
					<Typography className={styles.pools_b_subheading}>{props.deltaAmount} ETH</Typography>
				</Box>
				<Box>
					<Typography className={styles.pools_b_headline}>Pool Type:</Typography>
					<Typography className={styles.pools_b_subheading}>{props.poolType} pool</Typography>
				</Box>
			</Box>
		</Box> : <> </>
	)
}
export default PoolsCard
