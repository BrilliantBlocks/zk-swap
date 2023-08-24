import styles from './Cards.module.css';
import Image from 'next/image';
import { Box, Typography } from '@mui/material';
import eth from '../assets/images/eth-logo.png'
import { truncateWords } from '../../utils/helper-functions/shortenText';
import { TbArrowsHorizontal } from 'react-icons/tb'

const ContainerHeader: React.FC = ({ }): React.ReactElement => {
    return (
        <Box className={styles.pools_flex}>
            <Box className={styles.pools_content}>
                <Box className={styles.pools_content_visual}>
                    <Image src={eth} width="42" height="44" className={styles.round_img} />
                    <Typography className={styles.pools_content_text}>eth</Typography>
                </Box>
                <div className={styles.pools_content_flex}><TbArrowsHorizontal size={25} />
                </div>
                <Box className={styles.pools_content_visual}>
                    <Image src={'/starknet.png'} alt={` banner image`} width={45} height={45} objectFit="cover" />
                    <Typography className={styles.pools_content_text}>
                        {truncateWords('ZK-Swap', 2, '...')}
                    </Typography>
                </Box>
            </Box>
        </Box>
    );
};
export default ContainerHeader;