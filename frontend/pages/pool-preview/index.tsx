import * as React from 'react'
import styles from './PoolPreview.module.css'
import { Box, Typography } from '@mui/material'
import HeaderLinks from '../../components/Header/HeaderLinks'
import ContainerHeader from '../../components/Card/ContainerNFTToEth'
import eth from '../../components/assets/images/eth-logo.png'
import Image from 'next/image'
import CardNFT from '../../components/Card/CardPoolPreview'
import { ModalSelect } from '../../components/Dashboard/pool-preview/SelectModal'
import { ModalToken } from '../../components/Dashboard/pool-preview/TokenModal'
import { useRouter } from 'next/router'
import AboutPool from '../../components/Dashboard/pool-preview/AboutSection'
import PricingPool from '../../components/Dashboard/pool-preview/PricingSection'
import { PoolProps } from '../../utils/helper-functions/storePool'
import { getBalance, getNFTsOfCollection, getPoolConfig } from '../../services/wallet.service'
import { mockedNfts } from '../../utils/mockedData'


interface PoolPreview {
	poolAddress?: any
}

const PoolPreviewPage: React.FC<PoolPreview> = (): React.ReactElement => {
	const router = useRouter()
	const [startPrice, setStartPrice] = React.useState(0)
	const [deltaAmount, setDeltaAmount] = React.useState(0)
	const [collectionAddress, setCollectionAddress] = React.useState('')
	const [poolType, setPoolType] = React.useState('')
	const [balance, setBalance] = React.useState<number>(0)
	const [nfts, setNfts] = React.useState<string[]>([])

	let { poolAddress }: any = router.query

	React.useEffect(() => {
		const getPoolParams = localStorage.getItem('pool') || '[]'
		var data = JSON.parse(getPoolParams) || []

		data.map(async (item: PoolProps) => {
			if (item?.poolAddress === poolAddress) {
				setCollectionAddress(item?.collectionAddress)
				const data = await getPoolConfig(item.poolAddress)

				setStartPrice(data.price)
				setPoolType(item.poolType)
				setDeltaAmount(data.delta)

				const nfts = await getNFTsOfCollection(poolAddress, item.collectionAddress)
				setNfts(nfts)

				const balance = await getBalance(poolAddress)
				setBalance(balance)
			}
		})
	}, [])

	return (
		<>
			<div className={`${styles.spacing_inline} ${styles.spacing_top} ${styles.spacing_bottom}`}>
				<main className={styles.container}>
					<Box className={styles.header_container}>
						<ContainerHeader />
						<HeaderLinks poolAddress={poolAddress} />
					</Box>
					<Box className={styles.main_container}>
						<Box className={`${styles.card} ${styles.bg}`}>
							<Box className={styles.cards_header_container}>
								<Typography variant="h2" className={styles.headline}>
									Assets
								</Typography>
							</Box>
							<Box className={styles.nft_container}>
								<Box className={styles.nft_header}>
									<Typography variant="h4" className={styles.subheading}>
										{' '}
										Tokens
									</Typography>
									<Box className={styles.btn_container}>
										<ModalToken title="Deposit" poolAddress={poolAddress} />
										{balance === 0 ? null : <ModalToken title="Withdraw" poolAddress={poolAddress} />}
									</Box>
								</Box>
								<Box className={styles.container_b}>
									<Box className={styles.content_icon}>
										<Image src={eth} width={35} height={35} objectFit="cover" className={styles.img} />
										<Typography variant="body2" className={styles.number}>
											{balance}
										</Typography>
									</Box>
								</Box>
							</Box>
							<Box className={styles.nft_container}>
								<Box>
									<Box className={styles.nft_header}>
										<Typography variant="h4" className={styles.subheading}>
											{' '}
											NFTs
										</Typography>
										{poolAddress && collectionAddress ? (
											<Box className={styles.btn_container}>
												{poolType === 'Sell NFTs for tokens' ? (
													<ModalSelect type="deposit" title="deposit" poolAddress={poolAddress} collectionAddress={collectionAddress} />
												) : null}
												{nfts.length === 0 ? null : (
													<ModalSelect type="withdraw" title="withdraw" poolAddress={poolAddress} collectionAddress={collectionAddress} />
												)}
											</Box>
										) : (
											''
										)}
									</Box>
									<Box className={styles.container_b}>
										<Box className={styles.content_icon}>
											<Image src={'/starknet.png'} alt={` banner image`} width={35} height={35} objectFit="cover" className={styles.img} />
											<Typography variant="body2" className={styles.number}>
												{/* {nfts.length} */}
												{mockedNfts.length}
											</Typography>
										</Box>
										<Box className={styles.card_container}>
											{mockedNfts?.map((item: any, index: any) => (
												<CardNFT name={item.Metadata.name} key={item.Metadata.id} />
											))}
											{/* {nfts.map((item: any, index: any) => (
												<CardNFT name={item.name} key={item.id} />
											))} */}
										</Box>
									</Box>
								</Box>
							</Box>
						</Box>
						<Box className={styles.flex_space}>
							<PricingPool startPrice={startPrice} deltaAmount={deltaAmount} />
							<AboutPool startPrice={startPrice} deltaAmount={deltaAmount} />
						</Box>
					</Box>
				</main>
			</div>
		</>
	)
}
export default PoolPreviewPage
