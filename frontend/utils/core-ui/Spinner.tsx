import CircularProgress from "@mui/material/CircularProgress"
import { styled } from "@mui/material/styles"

const Spinner = styled(CircularProgress)(({ theme }) => ({
	position: "fixed",
	top: "56%",
	left: "48% !important",
	color: theme.palette.secondary.main
}))

export default Spinner
