import React from "react";
import Button, { ButtonProps } from "@mui/material/Button";
import { styled } from "@mui/material/styles";

const CreatePoolBtn = styled(Button)<ButtonProps>(({ theme }) => ({
  minWidth: 150,
  minHeight: '2,5rem',
    borderRadius: '5px',
    fontFamily: 'Helvetica',
    fontWeight: '500',
  backgroundColor: '#fac079',
    border: '3px solid #F5B700',
  " &:hover": {
    backgroundColor: theme.palette.secondary.dark,
  },
}));

export default CreatePoolBtn;
