import { styled } from '@mui/material/styles'

export const ColorlibStepIconRoot = styled('div')<{
    ownerState: { completed?: boolean; active?: boolean }
}>(({ theme, ownerState }) => ({
    backgroundColor: theme.palette.mode === 'dark' ? theme.palette.grey[700] : '#d0d0d0',
    zIndex: 1,
    color: '#161616',
    width: 25,
    height: 25,
    fontSize: '10px',
    fontWeight: '800',
    display: 'flex',
    borderRadius: '50%',
    justifyContent: 'center',
    alignItems: 'center',
    ...(ownerState.active && {
        backgroundColor: '#FAC079',
        color: 'black'
    }),
    ...(ownerState.completed && {
        backgroundColor: '#ffe0a2',
        color: 'black'
    })
}))