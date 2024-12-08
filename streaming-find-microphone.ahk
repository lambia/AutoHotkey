#Requires AutoHotkey v2.0
#SingleInstance Force

ConfigurationPath := ".\sh.ini"

ReadConfig() {
    DeviceIndex := 0
    try DeviceIndex := IniRead(ConfigurationPath, "Config", "mute-device-index")
    ;MsgBox "Selected device: #" DeviceIndex
    return DeviceIndex
}

SelectDevice() {
    myGui := Gui(, "Streaming Hotkeys v. 0.2")
    table := myGui.Add('ListView', "w400 h200", ["#", "Device", "Volume"])
    table.OnEvent("DoubleClick", OnTableRowDoubleClick)

    devMap := Map()

    loop
    {
        try ; Finchè ci sono dispositivi da iterare
            devName := SoundGetName(, dev := A_Index)
        catch  ; Altrimenti, esci
            break
            
        ; Retrieve master volume, if possible.
        vol := ""
        try vol := Round(SoundGetVolume( , dev), 0)
        table.Add("", dev, devName, vol "%")    
    }

    loop 3
        table.ModifyCol(A_Index, 'AutoHdr Logical')

    myGui.Add("Text",, "Please double click on the chosen device")

    OnTableRowDoubleClick(table, RowNumber)
    {
        numero := table.GetText(RowNumber, 1)
        nome := table.GetText(RowNumber, 2)

        Result := MsgBox("Hai selezionato il dispositivo #" numero "`n" nome "`n`nConfermi?",, "YesNo")
        if Result = "Yes" {

            IniWrite numero, ConfigurationPath, "Config", "mute-device-index"
            MsgBox "Informazioni salvate. Al prossimo avvio non ti verrà chiesto nuovamente. Per cambiare le impostazioni elimina il file sh.ini"

            TraySetIcon "imageres.dll", SoundGetMute(, nome) ? 234 : 231
        }
        
        myGui.Destroy()
    }

    myGui.Show()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SavedDevice := ReadConfig()
if(SavedDevice==0) {
    SelectDevice()
} else {
    SelectedDeviceName := SoundGetName(, SavedDevice)
    TraySetIcon "imageres.dll", SoundGetMute(, SelectedDeviceName) ? 234 : 231
}

;ToDo: permettere configurazione tasto
;ToDo: single click = toggle, long press = push to talk

#HotIf SavedDevice!=0
Pause:: {
    SoundSetMute -1 ,, SavedDevice
    isDeviceMuted := SoundGetMute(, SavedDevice)

    TraySetIcon "imageres.dll", isDeviceMuted ? 234 : 231

    TrayTip ;Chiude il tooltip prima di aprirlo
    TrayTip "Device is " (isDeviceMuted ? "" : "NOT ") "muted", SelectedDeviceName, 20 ;20=4+16=Tray+Mute
    SetTimer () => TrayTip(), -1000

    try SoundPlay "ferma-riproduzione"
    SoundPlay A_WinDir "\Media\Windows Hardware " (isDeviceMuted ? "Remove" : "Insert") ".wav"
}
#HotIf


