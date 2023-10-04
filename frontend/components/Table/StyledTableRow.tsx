import TableRow from '@mui/material/TableRow'
import { styled } from '@mui/material/styles'

const StyledTableRow = styled(TableRow)(({ theme }) => ({
	height: '50px',
	'&:nth-of-type(even)': {
		height: '50px',
		backgroundColor: '#1c1c24',
		color: '#fff !important',
		marginBottom: '10px',
		'&:hover': {
			backgroundColor: '#353545',
		}
	},
	'&:nth-of-type(odd)': {
		backgroundColor: '#1c1c24',
		'&:hover': {
			backgroundColor: '#353545'
		}
	},
	'&:last-child td, &:last-child th': {
		border: 0
	}
}))

export default StyledTableRow
