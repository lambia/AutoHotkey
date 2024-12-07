#Requires AutoHotkey v2.0

myGui := Gui(, "Sound Components")
scLV := myGui.Add('ListView', "w400 h200", ["#", "Device", "Volume"])

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
    scLV.Add("", dev, devName, vol "%")    
}

loop 3
    scLV.ModifyCol(A_Index, 'AutoHdr Logical')
myGui.Show()
