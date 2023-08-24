import { styled } from '@mui/system';

const StyledInput = styled('input')(({ theme }) => `
  width: 320px;
  font-size: 0.875rem;
  font-weight: 400;
  line-height: 1.5;
  padding: 12px;
  border-radius: 7px;
  color: ${theme.palette.primary.dark};
  background: rgba(250, 192, 121, 0.4);
  border: 1px solid ${theme.palette.secondary.main};
  &:hover {
    border-color: ${theme.palette.secondary.main};
  }
  &:focus {
    border-color: ${theme.palette.secondary.main};
    outline: 1px solid ${theme.palette.secondary.main};
  }  'input': {
    '&::placeholder': {
      textOverflow: 'ellipsis !important',
      color: '#fff'
    }
  }
`,
);

export default StyledInput