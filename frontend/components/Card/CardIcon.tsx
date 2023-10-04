import styles from './Cards.module.css'
import { Box, Typography, TypographyProps } from '@mui/material';
import { Container } from '@mui/system';
import Image from 'next/image'
import eth from '../assets/images/eth-logo.png'

interface CardIconProps extends TypographyProps {
    headline: string
    value: number
}

const CardIcon: React.FC<CardIconProps> = (props): React.ReactElement => {
    return (
        <Container className={styles.flex}>
            <Typography variant="h2" component="h2" className={styles.content_headline}>
                {props.headline}
            </Typography>
            <Box className={styles.icon_wrapper}>
                <Image src={eth} width="29" height="30" className={styles.round_img} />
                <Typography className={styles.content_text}>{props.value}</Typography>
            </Box>
        </Container>
    );
};
export default CardIcon