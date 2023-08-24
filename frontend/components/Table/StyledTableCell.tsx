import TableCell, { tableCellClasses } from '@mui/material/TableCell'
import { styled } from '@mui/material/styles'

const StyledTableCell = styled(TableCell)(({ theme }) => ({
	textTransform: 'none',
	[`&.${tableCellClasses.head}`]: {
		backgroundColor: '#1c1c24',
		color: '#c3c3d4',
		fontWeight: '800',

	},
	[`&.${tableCellClasses.body}`]: {
		fontWeight: '600',
		fontSize: '0.8rem !important',
		color: '#fff',
		borderBottom: '1px solid rgba(100, 100,100, 0.3)'
	}
}))
export default StyledTableCell
