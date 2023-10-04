import * as React from 'react';
import './Switch.module.css'
import FormGroup from '@mui/material/FormGroup';
import FormControlLabel from '@mui/material/FormControlLabel';
import CustomSwitch from './CustomSwitch'

interface SwitchProps {
    checked?: boolean
    onChange?: () => void;
    label: string
}

const SwitchBtn: React.FC<SwitchProps> = (props): React.ReactElement => {


    return (
        <FormGroup>
            <FormControlLabel sx={{ color: '#ff0000 important' }} control={<CustomSwitch
                checked={props.checked}
                onChange={props.onChange}
                color="secondary"
                size='medium'
            />} label={props.label} />
        </FormGroup>

    );
};
export default SwitchBtn