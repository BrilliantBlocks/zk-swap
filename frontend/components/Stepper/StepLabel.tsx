import { styled } from '@mui/material/styles'
import StepLabel, { stepLabelClasses } from '@mui/material/StepLabel'

export const CustomizedStepLabel = styled(StepLabel)(() => ({
    [`& .${stepLabelClasses.label}`]: {
        [`&.${stepLabelClasses.completed}`]: {
            color: '#ffe5b2'
        },
        [`&.${stepLabelClasses.active}`]: {
            color: 'rgba(250, 192, 121, 1)'
        },
        color: '#6f8498',
        fontSize: '10px !important'
    }
}))
