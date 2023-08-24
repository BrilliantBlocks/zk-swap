import styles from './Cards.module.css'
import Image from 'next/image'
import { Box, Checkbox, Typography } from '@mui/material'
import eth from '../assets/images/eth-logo.png'
import Card from './Card'
import { CollectionCardType } from '../../pages/collections/index'
import { useEffect, useState } from 'react'
import { isItemSelected } from '../../utils/cart.utils'

type CollectionCardProps = {
	item: any
	cartItems: CollectionCardType[]
	handleAddToCart: (clickedItem: CollectionCardType) => void
}

const CollectionCardSell: React.FC<CollectionCardProps> = ({ item, cartItems, handleAddToCart }): React.ReactElement => {
	const [isSelected, setIsSelected] = useState<boolean>(isItemSelected(cartItems, item))

	const clickAddToCart: any = () => {
		handleAddToCart(item)
	}

	useEffect(() => {
		setIsSelected(cartItems.find((cartItem) => cartItem.TokenId === item.TokenId && cartItem.amount !== 0) ? true : false)
	}, [cartItems, item.TokenId])

	if (!item || !item.Metadata) {
		return <></>
	}

	return (
		<Card width="10rem!important" onClick={clickAddToCart} className={isSelected ? ` ${styles.card_outline} ${styles.wrapper}` : styles.wrapper}>
			{!isSelected ? undefined : (
				<Box sx={{ position: 'relative' }}>
					<Checkbox checked={isSelected} onClick={clickAddToCart} color="success" sx={{ position: 'absolute', zIndex: '22', left: '2px' }} />{' '}
				</Box>
			)}
			<Box className={styles.card_image_container}>
				<img src={item.Metadata.image} alt={`${item.Metadata.name} Collection NFT.`} width={130} height={130} />
			</Box>
			<Box className={styles.cart_text_container}>
				<Typography className={styles.cart_title}>{item.Metadata.name}</Typography>
			</Box>
			<Box className={styles.card_button}>
				<Image src={eth} width="20" height="15" className={styles.round_img} />
				<Typography className={styles.card_button_text}>{item.nextPrice}</Typography>
			</Box>
		</Card>
	)
}
export default CollectionCardSell
