import './Cards.module.css'
import { Box } from '@mui/material';

interface CardProps {
    children: React.ReactNode
    border?: string
    width?: string
    onClick?: () => void;
    className?: string
}

const Card: React.FC<CardProps> = (props): React.ReactElement => {
    const classes = "wrapper " + props.className
    const { children, border, width, onClick, className } = props;

    return (
        <Box style={{ border, width, cursor: 'pointer' }} className={classes} onClick={onClick} sx={{ ml: '0 !important' }}>
            {children}
        </Box>
    );
};
export default Card