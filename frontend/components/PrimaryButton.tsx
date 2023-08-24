import { Button, ButtonProps } from '@mui/material'

interface MyCompanyButtonProps extends ButtonProps {
	children: React.ReactNode
	backgroundColor: string
	className?: string
	border?: string
	startIcon?: any
	endIcon?: any
	onClick?: (e: any) => void
}

const PrimaryButton: React.FC<MyCompanyButtonProps> = (props): React.ReactElement => {
	const { children, backgroundColor, border, startIcon, endIcon, onClick, } = props;

	return (
		<Button style={{ backgroundColor }} sx={{ minWidth: 150, minHeight: '2,5rem', borderRadius: '5px', fontFamily: 'Helvetica', fontWeight: '500', border: '1px solid grey' }} startIcon={startIcon} endIcon={endIcon} className={props.className} onClick={props.onClick} >
			{children}
		</Button>
	);
};

export default PrimaryButton
