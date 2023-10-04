import * as React from 'react'
import { useState, useEffect, useRef } from 'react'
import styles from './Collections.module.css'
import Header from '../../components/Header/Header'
import AsideBar from '../../components/Drawer/Drawer'
import { Box, Button, Tab } from '@mui/material'
import { toggleCartItem } from '../../utils/cart.utils'
import { useRouter } from 'next/router'
import CollectionsLayout from '../../layouts/secondLayout'
import CollectionCard from '../../components/Card/CollectionCard'
import CollectionCardSell from '../../components/Card/CollectionCardSell'
import StyledTabs from '../../components/Tabs/StyledTabs'
import TabsLabel from '../../components/Tabs/TabsLabel'
import { TabPanel } from '@mui/lab'
import TabContext from '@mui/lab/TabContext'
import { walletAddress } from '../../services/wallet.service'
import Web3 from 'web3'
import Spinner from '../../utils/core-ui/Spinner'
import { mockedNfts }  from '../../utils/mockedData'

export type CollectionCardType = {
	nftMetadata: any[]
	Listing: any
	TokenId: string
	name: string
	hash: string
	value: number
	nextPrice: number
	image: string
	amount: number
	collectionAddress: string
	poolAddress: string
}

const COLLECTION_CARDS_PER_ROW = 7

const CollectionPage = () => {
	const router = useRouter()
	const INITIAL_STATE: CollectionCardType[] = []
	const [cartItems, setCartItems] = useState(INITIAL_STATE)
	const [loadCollectionCards, setLoadCollectionCards] = useState(COLLECTION_CARDS_PER_ROW)
	const [value, setValue] = useState('buy')
	const [data, setData] = useState<any>([])
	const [sellData, setSellData] = useState<any>([])
	const [poolAddressArray, setPoolAddressArray] = useState<any>([])
	const [collectionData, setCollectionData] = useState<any>([])
	let { collectionAddress } = router.query

	useEffect(() => {
		
		let collectionData: any = JSON.parse(sessionStorage.getItem(collectionAddress as string)?? '[]')
		let poolAddressArray: any[] = []

		let specifiedCollection = collectionData.slice(-1)
		setCollectionData(specifiedCollection)
		
		collectionData[0]?.poolAddr.forEach((poolAddress: any, index: any) => {

			poolAddressArray.push(
				{ 
					poolAddress: poolAddress,
					nftsMetadata: collectionData[0].nftsMetadata[index],
					nextPrice: collectionData[0].nextPrice[index],
					poolDelta: collectionData[0].poolDelta[index]
				}
			)
			
		})

		poolAddressArray.sort((a, b) => a.nextPrice - b.nextPrice);
		setPoolAddressArray(poolAddressArray)
			
	}, [])

	useEffect(() => {
		;(async () => {

			//const nftMetadata = await getNftMetadata()
			const nftMetadata = mockedNfts

			const name = collectionData[0]?.name
			const nextPrice = Math.min.apply(Math, collectionData[0]?.nextPrice)
			const volume = collectionData[0]?.volume
			const bestOffer = collectionData[0]?.bestOffer

			setData({
				name,
				collectionAddress,
				nftMetadata,
				volume,
				bestOffer,
				nextPrice
			})

			// const address = await walletAddress()
			// const result = await fetch(`https://api.mintsquare.io/nfts/starknet-testnet?collection=${collectionAddress}&owner_address=${address}`)
			// const tempSellData = await result.json()

			// const sellData = await Promise.all(
			// 	tempSellData.map(async (nft: any) => {
			// 		//const nextPrice = await getNextPrice(buyPoolAddress)
			// 		const nextPrice = 1
			// 		return { ...nft, nextPrice }
			// 	})
			// )
			setSellData(sellData)

		})()
		
	}, [poolAddressArray])

	useEffect(() => {
		const cartData = JSON.parse(localStorage.getItem('cart') as string)

		if (cartData) {
			setCartItems(cartData)
		}
	}, [])

	useEffect(() => {
		if (cartItems !== INITIAL_STATE) {
			localStorage.setItem('cart', JSON.stringify(cartItems))
		}
	}, [cartItems])

	const handleMoreImage = () => {
		setLoadCollectionCards(loadCollectionCards + COLLECTION_CARDS_PER_ROW)
	}

	const handleAddToCart = (clickedItem: CollectionCardType) => {
		setCartItems((prev: any) => {
			return toggleCartItem(clickedItem, prev)
		})
		const updatedPool = clickedItem.poolAddress
		data.nftMetadata.forEach((item: any) => {
			if (item.poolAddress == updatedPool && clickedItem.TokenId != item.TokenId) {
				let oldPrice = item.nextPrice
				let delta = item.poolDelta
				item.nextPrice = oldPrice + delta
			}
		})
	}

	const handleRemoveFromCart = (id: number) => {
		setCartItems((prev) =>
			prev.reduce((ack, item) => {
				if (item.TokenId === `${id}`) {
					if (item.amount === 1) return ack
					return [...ack, { ...item, amount: 0 }]
				} else {
					return [...ack, item]
				}
			}, [] as CollectionCardType[])
		)
	}
	const isChecked = (e: any) => {
		const { name, checked } = e.target
		let arr = data.map((item: any) => {
			item.Metadata.name === name ? { ...item, isChecked: checked } : item
		})
	}

	useEffect(() => {
		isChecked
	}, [])

	const handleClearCart = () => {
		setCartItems([])
	}
	const updatePrices = (cartItems: CollectionCardType[]) => {
		setCartItems(cartItems)
	}
	const handleChangeValue = (event: React.SyntheticEvent, newValue: string) => {
		setValue(newValue)
	}
	const handleTradeAssets = () => {
		cartItems.forEach((item: any) => {
			data.nftMetadata.forEach((nft: any, index: any) => {
				if (nft.TokenId == item.TokenId) {
					data.nftMetadata.splice(index, 1)
				}
			})
			
		})
		setCartItems([])
	}

	const getNftMetadata = async () => {
		let nftMetadata: any[] = []
		poolAddressArray.forEach((pool: any, index: any) => {
			pool.nftsMetadata.forEach(async (item: any) => {
				const TokenId = item.tokenArray
				const metadata = await fetch(item.nftMetadata)
				const nftData = await metadata.json()
				const name = nftData.name
				const image = nftData.image
				const nextPrice = poolAddressArray[index].nextPrice
				const poolDelta = poolAddressArray[index].poolDelta
				const poolAddress = poolAddressArray[index].poolAddress
				nftMetadata.push({
					TokenId: `${Web3.utils.hexToNumberString(TokenId[0])}`,
					Metadata: {
						name,
						image
					},
					nextPrice,
					poolDelta,
					poolAddress, 
					collectionAddress
				})
			})
		})

		return nftMetadata
	}

	return (
		<>
			<AsideBar
				cartItems={cartItems.filter((cartItem) => cartItem.amount !== 0)}
				removeFromCart={handleRemoveFromCart}
				clearCart={handleClearCart}
				updatePrices={updatePrices}
				tradeAssets={handleTradeAssets}
			/>
			<div className={`${styles.spacing_inline} ${styles.spacing_top} ${styles.spacing_bottom}`}>
				<main className={styles.container}>
					<Box className={styles.flex}>
						<Header
							image="/starknet.png"
							collectionName={data.name}
							volumeValue={data.volume}
							floorPriceValue={data.nextPrice}
							collectionAddress={data.collectionAddress}
						/>
					</Box>
					<Box className={styles.grid}>
						<>
							<Box>
								<Box className={styles.flex_tabs}>
									{data && data.nftMetadata ? (
										<TabContext value={value}>
											<Box sx={{ borderBottom: 1, borderColor: 'divider', display: 'flex', flexDirection: 'column' }}>
												<StyledTabs onChange={handleChangeValue} aria-label="lab API tabs example">
													<Tab
														label={
															<>
																<TabsLabel name="Buy" value={data && data.nftMetadata ? data.nftMetadata.length : 0} />
															</>
														}
														value="buy"
														className={`${styles.flex} ${styles.margin_right}`}
														wrapped
													/>
													<Tab
														label={
															<>
																<TabsLabel name="Sell" value={sellData ? sellData.length : 0} />
															</>
														}
														value="sell"
														className={styles.flex}
													/>
												</StyledTabs>
											</Box>
											<Box>
												<TabPanel value="buy" className={styles.tabpanel}>
													<Box className={`${styles.tabpanel_content} ${styles.mt}`}>
														{data && data.nftMetadata
															? data.nftMetadata
																	.slice(0, loadCollectionCards)
																	.sort((a: any, b: any) => b.value - a.value)
																	?.map((item: any, key: any) => (
																		<Box key={key} className={styles.card_wrapper}>
																			<CollectionCard item={item} cartItems={cartItems} handleAddToCart={handleAddToCart} />
																		</Box>
																	))
															: null}
														{loadCollectionCards < data.nftMetadata.length && (
															<Box className={`${styles.flex} ${styles.spacing_top}`}>
																<Button variant="contained" color="secondary" onClick={handleMoreImage} className={styles.btn}>
																	Load more
																</Button>
															</Box>
														)}
													</Box>
												</TabPanel>
												<TabPanel value="sell" className={styles.tabpanel}>
													<Box className={styles.tabpanel_content}>
														{sellData
															? sellData
																	.slice(0, loadCollectionCards)
																	.sort((a: any, b: any) => b.value - a.value)
																	?.map((item: any, key: any) => (
																		<Box key={key} className={styles.card_wrapper}>
																			<CollectionCardSell item={item} cartItems={cartItems} handleAddToCart={handleAddToCart} />
																		</Box>
																	))
															: null}
													</Box>
													{loadCollectionCards < sellData.length && (
														<Box className={`${styles.flex} ${styles.spacing_top}`}>
															<Button variant="contained" color="secondary" onClick={handleMoreImage} className={styles.btn}>
																Load more
															</Button>
														</Box>
													)}
												</TabPanel>
											</Box>
										</TabContext>
									) : (
										<Spinner />
									)}
								</Box>
							</Box>
						</>
					</Box>
				</main>
			</div>
		</>
	)
}

CollectionPage.layout = CollectionsLayout

export default CollectionPage
