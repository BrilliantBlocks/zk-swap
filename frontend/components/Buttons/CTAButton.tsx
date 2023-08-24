import React from "react";
import Button, { ButtonProps } from "@mui/material/Button";
import { styled } from "@mui/material/styles";

const CtaBtn = styled(Button)<ButtonProps>(({ theme }) => ({
  margin: "2rem 0 0 35px",
  padding: "20px 40px",
  height: "35px",
  fontSize: 12,
  lineHeight: 1,
  backgroundColor: theme.palette.secondary.main,
  color: theme.palette.primary.main,
  " &:hover": {
    backgroundColor: theme.palette.secondary.dark,
  },
}));

export default CtaBtn;
