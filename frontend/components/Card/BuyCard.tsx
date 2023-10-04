import styles from './Cards.module.css'
import { Box } from '@mui/material';

import CollectionCard from './CollectionCard';

interface BuyCardProps {
    key: string
    cartItems: any
    item: any
    handleAddToCart: any
}

const BuyCard: React.FC<BuyCardProps> = (props): React.ReactElement => {
    return (
        <Box key={props.key} className={styles.card_wrapper}>
            <CollectionCard item={props.item} cartItems={props.cartItems} handleAddToCart={props.handleAddToCart} />
        </Box>
    );
};
export default BuyCard