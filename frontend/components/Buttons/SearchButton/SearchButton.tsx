import { Button, ButtonProps } from '@mui/material';
import { style } from '@mui/system';
import PrimaryButton from '../../PrimaryButton';
import styles from './SearchButton.module.css'
import CloseIcon from '@mui/icons-material/Close';


interface MyCompanyButtonProps extends ButtonProps {
    children: React.ReactNode
    name?: any
}

const SearchButton: React.FC<MyCompanyButtonProps> = (props): React.ReactElement => {
    const { children, name } = props;

    return (
        <PrimaryButton backgroundColor="transparent" border="1px solid #d0d0d0" className={`${styles.btn} ${styles.name}}`} >
            {children}
        </PrimaryButton>

    );
};
export default SearchButton