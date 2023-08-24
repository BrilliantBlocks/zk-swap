import * as React from 'react'
import { Box, Button } from '@mui/material'
import styles from '../collections/Collections.module.css'
import { useState, useEffect } from 'react'
import { COLLECTION_CARDS_PER_ROW } from '../../utils/manuallyDefinedValues'
import NFTCard from '../../components/Card/NFTCard'
import { walletAddress } from '../../services/wallet.service'
import Spinner from '../../utils/core-ui/Spinner'
import { mockedNfts } from '../../utils/mockedData'

const MyNFTsCollection = () => {
	const [loadCollectionCards, setLoadCollectionCards] = useState(COLLECTION_CARDS_PER_ROW)
	const [collectionCards, setCollectionCards] = useState([])

	// React.useEffect(() => {
	// 	if (collectionCards.length === 0) {
	// 		walletAddress()
	// 			.then((address) => {
	// 				return fetch(`https://api.mintsquare.io/nfts/owner/starknet-testnet/${address}`)
	// 			})
	// 			.then(async (result) => {
	// 				const data = await result.json()
	// 				setCollectionCards(data)
	// 			})
	// 	}
	// }, [loadCollectionCards])

	useEffect(() => {
		const data = mockedNfts
		setCollectionCards(data)
	}, [])

	const handleMoreImage = () => {
		setLoadCollectionCards(loadCollectionCards + COLLECTION_CARDS_PER_ROW)
	}

	if (collectionCards?.length === 0) {
		return <Spinner />
	}

	return (
		<>
			<div className={`${styles.spacing_inline} ${styles.spacing_top} ${styles.spacing_bottom}`}>
				<main className={styles.container}>
					{collectionCards ? (
						<>
							<Box className={`${styles.grid} ${styles.margin_top}`} sx={{ cursor: 'pointer' }}>
								{collectionCards
									?.slice(0, loadCollectionCards)
									.map((item: any, key: any) =>
										item && item.Metadata ? <NFTCard image={item?.Metadata.image} name={item?.Metadata?.name} key={key} /> : null
									)}
							</Box>
							<Box className={`${styles.flex} ${styles.loadMore_margin_top}`}>
								{loadCollectionCards < collectionCards.length && (
									<Button variant="contained" color="secondary" onClick={handleMoreImage} className={styles.btn}>
										Load more
									</Button>
								)}
							</Box>
						</>
					) : (
						<></>
					)}
				</main>
			</div>
		</>
	)
}

export default MyNFTsCollection
