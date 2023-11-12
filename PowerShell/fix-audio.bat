:: My script

:: Fix C920 webcam
pnputil /remove-device "USB\VID_046D&PID_08E5&MI_02\6&EB97715&0&0002"
pnputil /scan-devices
net start audiosrv