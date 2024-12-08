#Requires AutoHotkey v2.0
#SingleInstance Force

ConfigurationPath := ".\sh.ini"
SavedDevice := 0
IsNotified := 0
IsAlerted := 1
SelectedDeviceName := ""

IconFile := "imageres.dll"
IconMuted := 231
IconNotMuted := 234

ReadConfig() {
    try global IsNotified := IniRead(ConfigurationPath, "Notifications", "enabled")
    try global IsAlerted := IniRead(ConfigurationPath, "Alert", "enabled")
    try global SavedDevice := IniRead(ConfigurationPath, "Device", "index")

    if(SavedDevice!=0) {
        global SelectedDeviceName := SoundGetName(, SavedDevice)
        TraySetIcon IconFile, SoundGetMute(, SelectedDeviceName) ? IconMuted : IconNotMuted
    }

    ;MsgBox "Selected device: #" SavedDevice "
}

SelectDevice() {
    myGui := Gui(, "Streaming Hotkeys v. 0.2")
    table := myGui.Add('ListView', "w400 h200", ["#", "Device", "Volume"])
    table.OnEvent("DoubleClick", OnTableRowDoubleClick)

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
    myGui.isNotified := myGui.Add("CheckBox", "", "Abilita notifiche testuali windows")
    myGui.isAlerted := myGui.Add("CheckBox", "checked", "Abilita avviso sonoro")

    OnTableRowDoubleClick(table, RowNumber)
    {
        numero := table.GetText(RowNumber, 1)
        nome := table.GetText(RowNumber, 2)

        global IsNotified := myGui.isNotified.value
        global IsAlerted := myGui.isAlerted.value

        IniWrite numero, ConfigurationPath, "Device", "index"
        IniWrite IsNotified, ConfigurationPath, "Notifications", "enabled"
        IniWrite IsAlerted, ConfigurationPath, "Alert", "enabled"

        ReadConfig()
        
        myGui.Destroy()
        
    }

    myGui.Show()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReadConfig()
if(SavedDevice==0) {
    SelectDevice()
}

A_TrayMenu.Add()
A_TrayMenu.Add("Impostazioni", MyCallback)

MyCallback(ItemName, ItemPos, MyMenu) {
    SelectDevice()
}

;ToDo: nel ri-configuratore mostrare i valori attuali
;ToDo: permettere configurazione tasto
;ToDo: single click = toggle, long press = push to talk
;ToDo: Single click tray?

#HotIf SavedDevice!=0
Pause:: {
    SoundSetMute -1 ,, SavedDevice
    isDeviceMuted := SoundGetMute(, SavedDevice)

    TraySetIcon IconFile, isDeviceMuted ? IconMuted : IconNotMuted

    if(isNotified==1) {
        TrayTip ;Chiude il tooltip prima di aprirlo
        TrayTip "Device is " (isDeviceMuted ? "" : "NOT ") "muted", SelectedDeviceName, 20 ;20=4+16=Tray+Mute
        SetTimer () => TrayTip(), -1000
    }

    if(isAlerted==1) {
        try SoundPlay "ferma-riproduzione"
        SoundPlay A_WinDir "\Media\Windows Hardware " (isDeviceMuted ? "Remove" : "Insert") ".wav"
    }
}

