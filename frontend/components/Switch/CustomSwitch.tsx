import { alpha, styled } from '@mui/material/styles';
import Switch from '@mui/material/Switch';

const CustomSwitch = styled(Switch)(({ theme }) => ({
  '& .MuiSwitch-track': {
    backgroundColor: '#fff'
  },
  '& .MuiSwitch-switchBase.Mui-checked': {
    color: theme.palette.secondary.main,
    '&:hover': {
      backgroundColor: alpha(theme.palette.secondary.main, 0.2),
    },
  },
  '& .MuiSwitch-switchBase.Mui-checked + .MuiSwitch-track': {
    backgroundColor: theme.palette.secondary.main,
  },
}));
export default CustomSwitch