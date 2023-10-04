import React, { useState, useEffect, useContext } from "react";
import LostConnectionDialog from "../components/Modals/lostConnectionDialog";

function getNetworkStatus() {
  return typeof navigator !== "undefined" &&
    typeof navigator.onLine === "boolean"
    ? navigator.onLine
    : true;
}

const OnlineStatusContext = React.createContext(true);

export const NetworkStatusProvider: React.FC = () => {
  const [onlineStatus, setOnlineStatus] = useState(getNetworkStatus);
  const [open, setOpen] = React.useState(false);

  const handleClickOpen = () => {
    setOpen(true);
  };
  const handleClose = () => {
    setOpen(false);
  };

  function handleOnline() {
    setOnlineStatus(true);
  }

  function handleOffline() {
    setOnlineStatus(false);
  }

  useEffect(() => {
    window.addEventListener("online", handleOnline);
    window.addEventListener("offline", handleOffline);
    return () => {
      window.removeEventListener("online", handleOnline);
      window.removeEventListener("offline", handleOffline);
    };
  }, []);

  useEffect(() => {
    if (!onlineStatus) {
      handleClickOpen();
    } else {
      handleClose();
    }
  });

  return (
    <OnlineStatusContext.Provider value={onlineStatus}>
      <LostConnectionDialog
        open={open}
        onClose={handleClose}
      >
      </LostConnectionDialog>
    </OnlineStatusContext.Provider>
  );
};

export const useNetworkStatus = () => {
  const networkStatus = useContext(OnlineStatusContext);
  return networkStatus;
};
