import * as React from 'react'
import { useState } from 'react'
import styles from './Table.module.css'
import eth from '../../assets/images/eth-logo.png'
import FormControl from '@mui/material/FormControl'
import Input from '@mui/material/Input'
import { Box, Tooltip, TableBody, Avatar } from '@mui/material'
import Link from 'next/link'
import Image from 'next/image'
import Table from '@mui/material/Table'
import TableContainer from '@mui/material/TableContainer'
import Paper from '@mui/material/Paper'
import TableHead from '@mui/material/TableHead'
import TableRow from '@mui/material/TableRow'
import StyledTableCell from '../../Table/StyledTableCell'
import StyledTableRow from '../../Table/StyledTableRow'

// Info Icon
import InfoIcon from '@mui/icons-material/Info'
import CtaBtn from '../../Buttons/CTAButton'

// Number of collections that will be displayed in the table
import { numberOfCollectionsInTable } from '../../../utils/manuallyDefinedValues'
import Spinner from '../../../utils/core-ui/Spinner'

const TableCollections = ({ CollectionsLists }: any) => {
	const [nameSort, setNameSort] = useState(false)
	const [offerTvlSort, setOfferTvlSort] = useState(false)
	const [volumeSort, setVolumeSort] = useState(false)
	const [search, setSearch] = React.useState('')
	const [loadCollections, setLoadCollections] = useState(numberOfCollectionsInTable)
	const [loading, setLoading] = useState(false)

	const SearchFilter = {
		filtered: CollectionsLists.filter((item: any) => item.name.toLowerCase().includes(search.toLowerCase()))
	}

	let collectionArray: any[] = []
	let nameArray: any[] = []
	SearchFilter.filtered.forEach((item: any) => {
		collectionArray.push(item.collectionAddr)
		nameArray.push(item.name)
	})
	const distinctCollectionArray = collectionArray.filter((n, i) => collectionArray.indexOf(n) === i);
	const distinctNameArray = nameArray.filter((n, i) => nameArray.indexOf(n) === i);

	let filteredCollectionArray: any[] = []

	distinctCollectionArray.forEach((distinctCollection: any, index: any) => {

		let nftArray: object[][] = []
		let poolArray: string[] = []
		let priceArray: number[] = []
		let deltaArray: number[] = []
		let offerArray: number[] = []
		let volumeArray: number[] = []

		SearchFilter.filtered.forEach((item: any) => {

			if (item.collectionAddr == distinctCollection) {

				nftArray.push(item.nftsMetadata)
				poolArray.push(item.poolAddr)
				priceArray.push(item.nextPrice)
				deltaArray.push(item.poolDelta)
				offerArray.push(item.bestOffer)
				volumeArray.push(item.volume)
			}
			
		})

		let bestOffer = Math.min.apply(Math, offerArray)
		const totalVolume = volumeArray.reduce((partialSum, a) => partialSum + a, 0);
		filteredCollectionArray.push(
			{ 
				collectionAddr: distinctCollection,
				name: distinctNameArray[index],
				nftsMetadata: nftArray, 
				poolAddr: poolArray,
				nextPrice: priceArray,
				poolDelta: deltaArray,
				bestOffer: bestOffer,
				volume: totalVolume
			}
		)
		sessionStorage.setItem(distinctCollection, JSON.stringify(filteredCollectionArray))
	})

	const handleMoreCollections = () => {
		setLoading(true)
		return setTimeout(() => {
			setLoadCollections(loadCollections + numberOfCollectionsInTable)
			setLoading(() => false)
		}, 400)
	}

	const handleSearch = (event: any) => {
		setSearch(event.target.value)
	}

	return (
		<>
			<TableContainer component={Paper} className={styles.table}>
				<Box className={styles.input_container}>
					<FormControl variant="standard">
						<Input className={styles.input} placeholder="Search Collection" onChange={handleSearch} />
					</FormControl>
				</Box>

				<Table stickyHeader aria-label="customed table" className={styles.border}>
					<TableHead>
						<TableRow>
							<StyledTableCell align="left" onClick={() => setNameSort(!nameSort)}>
								Name
							</StyledTableCell>
							<StyledTableCell align="center" onClick={() => setOfferTvlSort(!offerTvlSort)}>
								<div className={styles.th}>
									Best Offer
									<Tooltip title="The value of the highest collection offer" placement="top" className={styles.tooltip}>
										<InfoIcon />
									</Tooltip>
								</div>
							</StyledTableCell>
							<StyledTableCell align="center" onClick={() => setVolumeSort(!volumeSort)}>
								<div className={styles.th}>
									Volume
									<Tooltip title="the total amoun of ETH traded" placement="top" className={styles.tooltip}>
										<InfoIcon />
									</Tooltip>
								</div>
							</StyledTableCell>
						</TableRow>
					</TableHead>
					<TableBody>
						{CollectionsLists.length === 0 && SearchFilter.filtered.length === 0 ? <Spinner /> : null}
						{filteredCollectionArray.map((item: any, key: any) => (
							<Link
								href={{
									pathname: `/collections`,
									query: {
										collectionAddress: `${item.collectionAddr}`
									}
								}}
								key={item.collectionAddr}
								style={{ cursor: 'pointer' }}
							>
								<StyledTableRow hover sx={{ cursor: 'pointer' }}>
									<StyledTableCell align="left">
										{item.name}
									</StyledTableCell>
									<StyledTableCell align="left">
										<div className={`${styles.flex} ${styles.spacing}`}>
											<Image src={eth} width={25} height={25} />
											{item.bestOffer.toLocaleString()}
										</div>
									</StyledTableCell>
									<StyledTableCell align="left">
										<div className={`${styles.flex} ${styles.spacing}`}>
											<Image src={eth} width={25} height={25} />
											{item.volume.toLocaleString()}
										</div>
									</StyledTableCell>
								</StyledTableRow> 
							</Link>
						))}
					</TableBody>
				</Table>
				{loadCollections < SearchFilter.filtered.length && (
					<CtaBtn sx={{ float: 'right' }} disabled={loading} onClick={handleMoreCollections}>
						{loading ? 'Loading...' : 'Load More Collections'}
					</CtaBtn>
				)}
			</TableContainer>
		</>
	)
}

export default TableCollections
