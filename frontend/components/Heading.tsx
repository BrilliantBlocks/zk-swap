import { Typography, TypographyProps } from '@mui/material';

interface HeadingProps extends TypographyProps {
    children: React.ReactNode
}

const Heading: React.FC<HeadingProps> = (props): React.ReactElement => {
    const { children } = props;

    return (
        <Typography variant="h2" component="h2" sx={{ fontFamily: 'Inter', fontWeight: '800', fontSize: "3rem", textTransform: 'capitalize' }}>
            {children}
        </Typography>
    );
};
export default Heading
