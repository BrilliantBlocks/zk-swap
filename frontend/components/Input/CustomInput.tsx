import * as React from 'react';
import { useInput } from '@mui/base';
import StyledInput from './StyledInput';
import { unstable_useForkRef as useForkRef } from '@mui/utils';

const CustomInput = React.forwardRef(function CustomInput(
    props: React.InputHTMLAttributes<HTMLInputElement>,
    ref: React.ForwardedRef<HTMLInputElement>,
) {
    const { getRootProps, getInputProps } = useInput(props);

    const inputProps = getInputProps();

    inputProps.ref = useForkRef(inputProps.ref, ref);

    return (
        <div {...getRootProps()}>
            <StyledInput {...props} {...inputProps} />
        </div>
    );
});

export default function UseInput() {
    return <CustomInput aria-label="Demo input" placeholder="Search Collections" />;
}
