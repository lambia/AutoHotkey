#Requires AutoHotkey v2.0

ReadConfig() {
    DeviceIndex := 0
    try DeviceIndex := IniRead("C:\Users\Luca\Documents\AutoHotkey\sh.ini", "Config", "mute-device-index")
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

    MyGui.Add("Text",, "Please double click on the chosen device")

    OnTableRowDoubleClick(table, RowNumber)
    {
        numero := table.GetText(RowNumber, 1)
        nome := table.GetText(RowNumber, 2)

        Result := MsgBox("Hai selezionato il dispositivo #" numero "`n" nome "`n`nConfermi?",, "YesNo")
        if Result = "Yes" {

            IniWrite numero, "C:\Users\Luca\Documents\AutoHotkey\sh.ini", "Config", "mute-device-index"
            MsgBox "Informazioni salvate. Al prossimo avvio non ti verrà chiesto nuovamente. Per cambiare le impostazioni elimina il file sh.ini"
        }
        
        myGui.Destroy()
    }

    myGui.Show()
}

SavedDevice := ReadConfig()
if(SavedDevice==0) {
    SelectDevice()
}