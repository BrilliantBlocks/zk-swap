import React from 'react'
import toast, { Toaster, ToastBar, resolveValue } from 'react-hot-toast'
import 'react-toastify/dist/ReactToastify.css'
import 'material-react-toastify/dist/ReactToastify.css'

import CloseIcon from '@mui/icons-material/Close'
import Button from '@mui/material/Button'
import { Box, Avatar } from '@mui/material'

export const ErrorToaster: React.FC = () => {
	return (
		<>
			<Toaster
				position="top-right"
				reverseOrder={false}
				toastOptions={{
					success: {
						style: {
							background: '#ebfdf4',
							color: '#3d9073'
						}
					},
					loading: {
						style: {
							background: '#eef6ff',
							color: '#456ddf'
						}
					},
					error: {
						style: {
							background: '#fef1f2',
							color: '#bf2f2e'
						}
					},
					custom: {
						style: {
							// Create custom toast information (color and background)
						}
					},
					style: {
						margin: '10px',
						padding: '20px',
						textTransform: 'none'
					}
				}}
			>
				{(t) => (
					<ToastBar toast={t}>
						{({ icon, message }) => (
							<>
								{icon}
								<Box>{message}</Box>
								{t.type !== 'loading' && (
									<Button sx={{ m: -1 }} color="inherit" onClick={() => toast.dismiss(t.id)}>
										<CloseIcon />
									</Button>
								)}
							</>
						)}
					</ToastBar>
				)}
			</Toaster>
		</>
	)
}
