import styles from './InputButton.module.css'
import { Box, Typography } from '@mui/material';

interface LabelProps {
    name: string
    value: number
    className?: string
}

const TabsLabel: React.FC<LabelProps> = (props): React.ReactElement => {
    return (
        <Box className={styles.row} >
            <Typography variant='h4' className={styles.type}>{props.name}</Typography>
            <Box className={styles.btn_container}><button className={styles.btn}>{props.value}</button></Box>
        </Box>
    );
};
export default TabsLabel