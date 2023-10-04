import React, { Children } from "react"
import Dialog from "@mui/material/Dialog"
import Toolbar from "@mui/material/Toolbar"
import Typography from "@mui/material/Typography"
import Slide from "@mui/material/Slide"
import { TransitionProps } from "@mui/material/transitions"
import { Box, Avatar } from "@mui/material"
import { theme } from '../../utils/theme';

// import logo from "../assets/images/brilliant-blocks-logo.png"

type DialogProps = {
	onClose: () => void
	open: any
	children?: React.ReactNode
}
const Transition = React.forwardRef(function Transition(
	props: TransitionProps & {
		children: React.ReactElement
	},
	ref: React.Ref<unknown>
) {
	return <Slide direction="down" ref={ref} {...props} />
})
const LostConnectionDialog: React.FC<DialogProps> = (props: DialogProps) => {
	const { onClose, open } = props
	const handleClose = () => {
		onClose()
	}
	return (
		<>
			<div>
				<Dialog
					fullScreen
					open={open}
					onClose={handleClose}
					PaperProps={{
						sx: {
							backgroundColor: theme.palette.primary.main
						}
					}}
					TransitionComponent={Transition}
				>
					<Toolbar>
					<Box sx={{ zIndex: (theme) => theme.zIndex.drawer + 2, my: 0, p: 0, display: "flex", alignItems: "center" }}>
					<Typography variant="h1" component="h4" sx={{ fontSize: "1.1rem", ml: "0.5rem", color: "#ffff" }}>
						ZK-Swap
					</Typography>
				</Box>
					</Toolbar>
					<Box
						sx={{
							color: "#ffff",
							marginTop: "15%",
							marginBottom: "7%",
							display: "flex",
							justifyContent: "center",
							alignItems: "center",
							flexDirection: "column"
						}}
					>
						<Typography variant="h1" component="h2" sx={{ fontSize: "2rem" }}>
							There is no connection. Please try later
						</Typography>
					</Box>
				</Dialog>
			</div>
		</>
	)
}
export default LostConnectionDialog