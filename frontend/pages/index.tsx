import React, { useEffect, useState, useRef } from 'react'

import { theme } from '../utils/theme'
import { ThemeProvider } from '@mui/material'

import HomeBoxDetails from '../components/Dashboard/home/HomeBoxDetails'
import TableCollections from '../components/Dashboard/home/TableCollections'
import { fetchCollectionsWithMetadata, getAllCollectionsFromAllPools } from '../services/wallet.service'
import { generateMockedTableCollection } from '../utils/mockedData'

export type CollectionDataType = {
	collectionAddress: string
	collectionName: string
}

interface NftMetadata {
	tokenId: string
	nftMetadata: string
}

export interface TableCollection {
	collectionAddr: string
	poolAddr: string
	name: string
	nftsMetadata: NftMetadata[]
	volume: number
	bestOffer: number
	poolDelta: number
	nextPrice: number
}


const Home = () => {
	const [collections, setCollections] = useState<string[]>([])
	const [tableCollections, setTableCollections] = useState<TableCollection[]>([])

	const loadedRef = useRef(false)

	// useEffect(() => {
	// 	if (!loadedRef.current) {
	// 		loadedRef.current = true
	// 		;(async () => {
	// 			try {
	// 				const collectionsData = await getAllCollectionsFromAllPools()

	// 				if (collectionsData) {
	// 					setCollections(collectionsData)
	// 				}
	// 			} catch (error) {
	// 				console.error(error)
	// 			}
	// 		})()
	// 	}
	// }, [])

	// useEffect(() => {
	// 	;(async () => {
	// 		try {
	// 			const tableCollections = await fetchCollectionsWithMetadata(collections)
	// 			setTableCollections(tableCollections)
	// 		} catch (error) {
	// 			console.error(error)
	// 		}
	// 	})()
	// }, [collections])

	useEffect(() => {
		const mockedData = generateMockedTableCollection();
		setTableCollections(mockedData)
	}, [])

	return (
		<>
			<ThemeProvider theme={theme}>
				<HomeBoxDetails />
				<TableCollections CollectionsLists={tableCollections} />
			</ThemeProvider>
		</>
	)
}

export default Home
