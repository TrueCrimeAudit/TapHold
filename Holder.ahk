#Requires Autohotkey v2.1-alpha.16
#SingleInstance Force

#Include <TapHoldManager>
#Include <Notify>
#Include <Classes>
#Include _zPopMenu_BU.ahk
#Include _UHQ_Snipping.ahk
#Warn All, Off

A_HotkeyInterval := 2000
A_MaxHotkeysPerInterval := 100

TraySetIcon(A_ScriptDir "/Lib/Icons/hKey.png")

SoundBeep(1000, 100)

THM := TapHoldManager()
THM.Add("F14", Layer1)
THM.Add("F13", Layer2)
THM.Add("F12", Layer3)
THM.Add("RAlt", Layer4)
THM.Add("F15", Layer5)

;/////////////////////////
#HotIf GetKeyState("F14", "P")
{
    WheelUp:: Cmd.NextTab
    WheelDown:: Cmd.PrevTab
    Delete:: Cmd.Backspace
    ^c:: Cmd.SelectAll
    ^v:: Cmd.SwapClip
    XButton2:: Cmd.Redo
    XButton1:: Cmd.Undo
    ^w:: Cmd.ReopenTab
    F13:: Cmd.DoBeep("Double")
}
#HotIf GetKeyState("F13", "P")
{
    WheelUp:: Cmd.SendUp
    WheelDown:: Cmd.SendDown
    Delete:: Cmd.wordBackspace
    ^c:: Cmd.Grab
    ^v:: Cmd.ClipHistory
    XButton2:: WinState.UnMinimize()
    XButton1:: WinState.SameApp()
    ^w:: Cmd.GoogleIt
}
#HotIf GetKeyState("F12", "P")
{
    WheelUp:: Cmd.PgUp
    WheelDown:: Cmd.PgDn
    a:: (() => (Layer.Notify("Opened Edge"), Send("{LWin Down}{1}{LWin Up}")))()
    s:: (() => (Layer.Notify("Opened Code"), Send("{LWin Down}{2}{LWin Up}")))()
    d:: (() => (Layer.Notify("Opened Teams"), Send("{LWin Down}{3}{LWin Up}")))()
    f:: (() => (Layer.Notify("Opened Files"), Send("{LWin Down}{4}{LWin Up}")))()
}
#HotIf GetKeyState("RAlt", "P")
{
    WheelUp:: Cmd.VolumeUp
    WheelDown:: Cmd.VolumeDown
    Delete:: Cmd.DeleteLine
    ^c:: Cmd.CopyLine
    ^v:: Cmd.PasteLine
    XButton2:: Cmd.NextDesktop
    XButton1:: Cmd.PrevDesktop
    ^w:: Cmd.CloseWindow
    Enter:: Cmd.OpenNotes
}
#HotIf GetKeyState("F15", "P")
{
    WheelUp::Send("^+{Tab}")
    WheelDown::Send("^{Tab}")
    Delete::Send("^w")
    ^c::Send("^+t")
    ^v::WinClose("A")
    RButton::Snip.Start()
    LButton::Snip.Tool()
    MButton::mensys.ShowMenu(1)
}
#HotIf

;/////////////////////////

class Layer {
    static currentLayerName := ""
    static currentLayerKey := ""
    static isActive := false

    static SetLayer(layerKey) {
        if (this.currentLayerKey && this.currentLayerKey != layerKey)
            this.Release()
        
        this.currentLayerKey := layerKey
        this.isActive := true
        
        try {
            err := Error("Layer trace", "SetLayer")
            if err.Stack {
                stack := StrSplit(err.Stack, "`n")
                if stack.Length > 2 {
                    if RegExMatch(stack[2], "Layer(\d+)", &match)
                        this.currentLayerName := "Layer " match[1]
                }
            }
        } catch ValueError as err {
            Notify.Show("Layer error: " err.Message)
        }
    }

    static Hold() {
        key := this.currentLayerKey
        if (!key || !GetKeyState(key, "P")) {
            this.Release()
            return
        }

        SetTimer(() => (GetKeyState(key, "P") ? SoundBeep(800, 200) : ""), -1000)
        this.NotifyHold("Hold", key)
    }

    static Release() {
        key := this.currentLayerKey
        if !this.isActive
            return
        Send(key)
        this.isActive := false
        this.currentLayerKey := ""
        this.currentLayerName := ""
    }

    static Notify(action) {
        layerPrefix := this.currentLayerName ? this.currentLayerName ": " : ""
        message := layerPrefix action
        Notify.Show(message, , , , , "dur=1 pos=bl tag=" message " ts=10")
    }

    static NotifyHold(message, key) {
        layerPrefix := this.currentLayerName ? this.currentLayerName ": " : ""
        Notify.Show(layerPrefix message, , , , , "dur=0 pos=bl tag=" message " ts=10")
        KeyWait(key)
        Notify.Destroy(message)
    }
}

;/////////////////////////

Layer1(IsHold, Taps, State) {
    static wasHeld := false
    Layer.SetLayer("F14")
    switch {
        case IsHold:
            Layer.Hold()
            switch Taps {
                case 1:
                    Layer.Hold()
                case 2:
                    Cmd.Run()
            }
            Cmd.ReleaseAll()
        case !IsHold:
            switch Taps {
                case 1:
                    if (State = -1)
                        Layer.Notify("Tap")
                case 2:
                    Cmd.SwitchMonitor()
                    Layer.Notify("DoubleTap")
                case 3:
                    SoundBeep(1000, 200)
                    Layer.Notify("TripleTap")
            }
    }
}

Layer2(IsHold, Taps, State) {
    static wasHeld := false
    Layer.SetLayer("F13")
    switch {
        case IsHold:
            Layer.Hold()
            if (Taps = 1) {
                if (State = -1) {
                    Layer.Notify("TapHold")
                    SoundBeep(1500, 100)
                }
            }
        case !IsHold:
            switch Taps {
                case 1:
                    if (State = -1) {
                        Layer.Notify("Tap")
                        Cmd.Run()
                    }
                case 2:
                    Cmd.SwitchMonitor()
                    Layer.Notify("DoubleTap")
                case 3:
                    Snip.Start()
                    Beep.RunSound()
                    Layer.Notify("TripleTap")
                case 4:
                    Snip.Snap()
                    Layer.Notify("QuadrupleTap")
            }
            Layer.Release()
    }
}

Layer3(IsHold, Taps, State) {
    static wasHeld := false
    Layer.SetLayer("F12")
    switch {
        case IsHold:
            switch Taps {
                case 1:
                    Layer.Hold()
                case 2:
                    Layer.Notify('TapHold')
                case 3:
                    Layer.Notify("TapTapHold")
            }
            Send("{LControl Up}{LShift Up}{LWin Up}{LAlt Up}")
        case Taps = 1:
            if (State = -1) {
                WinState.Minimize()
                Layer.Notify("Tap")
            }
        case Taps = 2:
            Layer.Notify('DoubleTap')
        case Taps = 3:
            Layer.Notify('TripleTap')
    }
}

Layer4(IsHold, Taps, State) {
    Layer.SetLayer("RAlt")
    if (IsHold) {
        Layer.Hold()
    }
}

Layer5(IsHold, Taps, State) {
    static wasHeld := false
    Layer.SetLayer("F15")
    switch {
        case IsHold:
            switch Taps {
                case 1:
                    Layer.Hold()
                case 2:
                    Layer.Notify('TapHold')
                case 3:
                    Layer.Notify("TapTapHold")
            }
        case Taps = 1:
            if (State = -1) {
                Send("^w")              ; Close tab on single tap
                Layer.Notify("Close Tab")
            }
        case Taps = 2:
            Send("^+t")               ; Reopen tab on double tap
            Layer.Notify('DoubleTap')
        case Taps = 3:
            processName := WinGetProcessName("A")
            switch processName {
                case "chrome.exe", "firefox.exe", "msedge.exe":
                    Send("^+w")       ; Close all tabs on triple tap
                default:
                    GroupAdd("ActiveWindows", "ahk_exe " processName)
                    WinClose("ahk_group ActiveWindows")
            }
            Layer.Notify('TripleTap')
    }
}

ClipboardMonitor()
