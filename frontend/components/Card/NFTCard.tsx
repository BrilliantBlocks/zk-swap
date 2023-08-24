import styles from './Cards.module.css'
import { Box, Typography, TypographyProps } from '@mui/material'
import Card from './Card'

interface CardIconProps extends TypographyProps {
	image: string
	name: string
}

const NFTCard: React.FC<CardIconProps> = (props): React.ReactElement => {
	return (
		<Card className={`${styles.wrapper}`}>
			<Box className={`${styles.card_image_container} ${styles.position_center} `}>
				<img className={styles.cardImage} src={props.image} alt={`${props.name} Collection NFT`} />
			</Box>
			<Box className={styles.cart_text_container}>
				<Typography className={styles.cart_title}>{props.name}</Typography>
			</Box>
		</Card>
	)
}

export default NFTCard
