import { Box, Typography, IconButton } from '@mui/material'
import Image from 'next/image'
import { CollectionCardType } from '../../pages/collections'
import styles from './CartItem.module.css'
import eth from '../assets/images/eth-logo.png'
import CancelPresentationIcon from '@mui/icons-material/CancelPresentation'
import { truncateWords } from '../../utils/helper-functions/shortenText'

type CartItemProps = {
	// item: CollectionCardType;
	item: any
	removeFromCart: (TokenId: number) => void
}

const CartItem: React.FC<CartItemProps> = ({ item, removeFromCart }) => {
	const { hash } = item

	return (
		<>
			<Box className={styles.cart_item_container}>
				<Box className={styles.card_visual}>
					<img src={`${item.Metadata?.image}`} alt={`${item.Metadata?.name} NFT`} width={70} height={70} />
				</Box>
				<Box className={styles.card_description}>
					<Typography className={`${styles.card_title} ${styles.card_text}`}>{item.Metadata?.name}</Typography>
				</Box>
				<Box className={styles.card_info}>
					<Box className={styles.card_info_visual}>
						<Image src={eth} width={30} height={30} />
					</Box>
					<Box className={styles.card_info_text}>
						<Typography variant="body2" className={styles.card_text}>
							{item.nextPrice}
						</Typography>
					</Box>
				</Box>
				<Box className={styles.card_actions}>
					<IconButton color="icon" onClick={() => removeFromCart(item.TokenId)}>
						<CancelPresentationIcon />
					</IconButton>
				</Box>
			</Box>
		</>
	)
}

export default CartItem
