import React from "react";
import Button from "@mui/material/Button";
import { styled } from "@mui/material/styles";
interface ButtonProps {
  to?: string;
  activeClassName?: string;
  component?: any;
  onClick?: any;
  className?: string;
  key?: string | number;
  children?: string;
  color?: string;
  startIcon?: any;
  target?: string;
}

const WalletBtn = styled(Button)<ButtonProps>(({ theme }) => ({
  margin: "2rem 0 0 35px",
  padding: "20px 25px",
  height: "35px",
  fontSize: 12,
  lineHeight: 1,
  backgroundColor: "#9CC1D7",
  borderRadius: '7px;',
  color: theme.palette.primary.main,
  " &:hover": {
    backgroundColor: "#729AB1",
    color: theme.palette.menuBtn.main,
  },
}));

export default WalletBtn;
