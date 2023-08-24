import * as React from 'react';
import Box from '@mui/material/Box';
import Slider from '@mui/material/Slider';

function valuetext(value: number) {
    return `${value}°C`;
}

export default function AssetSlider() {
    return (
        <Box sx={{ width: 300 }}>
            <Slider
                aria-label="Small steps"
                defaultValue={0}
                getAriaValueText={valuetext}
                step={1}
                marks
                min={0}
                max={100}
                valueLabelDisplay="auto"
                sx={{ color: '#fff !important' }}
            />
        </Box>
    );
}
