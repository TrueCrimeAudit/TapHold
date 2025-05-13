#Requires AutoHotkey v2.1-alpha.17
#SingleInstance Force

#Include _zPopMenu_BU.ahk
#Include <TapHoldManager>
#Include <Notify>
#Include <Classes>
#Include _UHQ_Snipping.ahk

#SuspendExempt
Numlock::Suspend
#SuspendExempt False

ClipboardMonitor()

THM := TapHoldManager(200, 200)
THM.Add("F14", Layer1)
THM.Add("F13", Layer2)
THM.Add("F12", Layer3)
THM.Add("RAlt", Layer4)
THM.Add("F15", Layer5)

WheelOptimizer()

#HotIf GetKeyState("F14", "P")
{
    WheelUp::Cmd.NextTab
    WheelDown::Cmd.PrevTab
    Delete::Cmd.Backspace
    ^c::Cmd.SelectAll
    ^v::Cmd.SwapClip
    XButton2::Cmd.Redo
    XButton1::Cmd.Undo
    ^w::Cmd.DuplicateTab
}
#HotIf GetKeyState("F13", "P")
{
    WheelUp::Cmd.SendUp
    WheelDown::Cmd.SendDown
    Delete::Cmd.wordBackspace
    ^c::{
        Layer.ForceModifierState("Ctrl", true)
        Cmd.Grab
    }
    ^v::Cmd.ClipHistory
    XButton2::WinState.UnMinimize()
    XButton1::WinState.SameApp()
    ^w::Cmd.GoogleIt
}

#HotIf GetKeyState("F12", "P")
{
    WheelUp::Cmd.PgUp
    WheelDown::Cmd.PgDn
    a::(() => (Layer.Notify("Opened Edge"), Send("{LWin Down}{1}{LWin Up}")))
    s::(() => (Layer.Notify("Opened Code"), Send("{LWin Down}{2}{LWin Up}")))
    d::(() => (Layer.Notify("Opened Teams"), Send("{LWin Down}{3}{LWin Up}")))
    f::(() => (Layer.Notify("Opened Files"), Send("{LWin Down}{4}{LWin Up}")))
}
#HotIf GetKeyState("RAlt", "P")
{
    WheelUp::Cmd.VolumeUp
    WheelDown::Cmd.VolumeDown
    MButton::Cmd.PlayingTab
    Delete::Cmd.DeleteLine
    ^c::{
        Layer.ForceModifierState("Ctrl", true)
        Cmd.CopyLine
    }
    ^v::Cmd.PasteLine
    XButton2::Cmd.NextDesktop
    XButton1::Cmd.PrevDesktop
    F15::Cmd.DuplicateTab
    F12::Cmd.PlayPause
    Enter::WinState.MaximizeActive    ; OpenNotes
    Space::Backspace
}
#HotIf GetKeyState("F15", "P")
{
    WheelUp::Cmd.PgUp
    WheelDown::Cmd.PgDn
    RButton::MenuSystem.ShowMenu(1)
    LButton::Snip.Start()
    MButton::Snip.Tool()
}
#HotIf
;#EndRegion

ShowHoldNotify(keyToMonitor := "", duration := 0, color := "0xff0000", size := 25) {
    if (keyToMonitor && !GetKeyState(keyToMonitor, "P"))
        return

    holdGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    holdGui.BackColor := color

    clickArea := holdGui.AddText("x0 y0 w" size " h" size)
    clickArea.OnEvent("Click", (*) => holdGui.Destroy())
    holdGui.OnEvent("Close", (*) => holdGui.Destroy())

    MonitorGetWorkArea(MonitorGetPrimary(), &monLeft, &monTop, &monRight, &monBottom)
    xPos := monLeft + 15
    yPos := monBottom + 15

    holdGui.Show("x" xPos " y" yPos " w" size " h" size " NoActivate")

    if (keyToMonitor) {
        checkKeyTimer := () {
            if (!GetKeyState(keyToMonitor, "P")) {
                holdGui.Destroy()
                return false
            }
            return true
        }
        SetTimer(checkKeyTimer, 25)
    }
    else if (duration > 0) {
        SetTimer(() => holdGui.Destroy(), -duration * 250)
    }

    return holdGui
}

;#Region RichEdit
class Layer {
    static currentLayerName := ""
    static currentLayerKey := ""
    static isActive := false
    static modifiersPressed := Map("LControl", false, "RControl", false, 
                                   "LShift", false, "RShift", false,
                                   "LWin", false, "RWin", false, 
                                   "LAlt", false, "RAlt", false)
    static layerTimers := Map()
    static holdNotificationActive := false
    static layerStartTime := A_TickCount
    
    static SetLayer(layerKey) {
        if (this.currentLayerKey && this.currentLayerKey != layerKey) {
            this.Release(true)
        }
        
        this.currentLayerKey := layerKey
        this.isActive := true
        this.holdNotificationActive := false
        this.layerStartTime := A_TickCount
        
        if (this.layerTimers.Has(layerKey) && this.layerTimers[layerKey]) {
            SetTimer(this.layerTimers[layerKey], 0)
        }
        
        try {
            err := Error("Layer trace", "SetLayer")
            if err.Stack {
                stack := StrSplit(err.Stack, "`n")
                if stack.Length > 2 {
                    if RegExMatch(stack[2], "Layer(\d+)", &match)
                        this.currentLayerName := "Layer " match[1]
                }
            }
        }
        
        this.SetupLayerMonitoring(layerKey)
        this.RefreshModifierStates()
    }
    
    static RefreshModifierStates() {
        for modifier, state in this.modifiersPressed {
            this.modifiersPressed[modifier] := GetKeyState(modifier)
        }
    }
    
    static SetupLayerMonitoring(layerKey) {
        timerFn := ObjBindMethod(this, "MonitorLayerKey", layerKey)
        this.layerTimers[layerKey] := timerFn
        SetTimer(timerFn, 50)
    }
    
    static MonitorLayerKey(layerKey) {
        if (this.isActive && this.currentLayerKey == layerKey) {
            if (!GetKeyState(layerKey, "P") || GetKeyState("WheelUp", "P") || GetKeyState("WheelDown", "P")) {
                this.Release(true)
                return
            }
        }
    }
    
    static ForceModifierState(modifier, state) {
        if this.modifiersPressed.Has(modifier)
            this.modifiersPressed[modifier] := state
    }
    
    static Hold() {
        holdKey := this.currentLayerKey
        
        if (holdKey = "") {
            return
        }
        
        if (GetKeyState(holdKey, "P") && !this.holdNotificationActive) {
            this.holdNotificationActive := true
        }
    }
    
    static Release(force := false) {
        if (!this.isActive && !force)
            return
                
        releaseKey := this.currentLayerKey
        
        for tKey, timer in this.layerTimers {
            SetTimer(timer, 0)
            this.layerTimers.Delete(tKey)
        }
        
        static allModifiers := ["LControl", "RControl", "LShift", "RShift", 
                            "LAlt", "RAlt", "LWin", "RWin"]
        for modifier in allModifiers {
            if (GetKeyState(modifier)) {
                Send("{" modifier " Up}")
                Sleep(5)
            }
            this.modifiersPressed[modifier] := false
        }
        
        if (releaseKey && GetKeyState(releaseKey, "P")) {
            Send("{" releaseKey " Up}")
            Sleep(5)
        }
        
        static layerKeys := ["F12", "F13", "F14", "F15", "RAlt"]
        for lKey in layerKeys {
            if (GetKeyState(lKey, "P")) {
                Send("{" lKey " Up}")
                Sleep(5)
            }
        }
        
        Sleep(10)
        
        for modifier in allModifiers {
            if (GetKeyState(modifier)) {
                Send("{" modifier " Up}")
                Sleep(5)
            }
        }
        
        for lKey in layerKeys {
            if (GetKeyState(lKey, "P")) {
                Send("{" lKey " Up}")
                Sleep(5)
            }   
        }
        
        this.isActive := false
        this.currentLayerKey := ""
        this.currentLayerName := ""
        this.holdNotificationActive := false
        
        ToolTip()
    }

    static Notify(action) {
        layerPrefix := this.currentLayerName ? this.currentLayerName ": " : ""
        message := layerPrefix action
        this.ShowToolTip(message)
    }

    static ShowToolTip(message) {
        ToolTip(message, , , 1)
        SetTimer(() => ToolTip(, , , 1), -1000)
    }

    static EmergencyRelease() {
        this.Release(true)
        SoundBeep(500, 100)
        this.ShowToolTip("Emergency Layer Release")
    }
    
    static HandleWheelEvent() {
        if (this.isActive) {
            this.Release(true)
        }
    }
}
;#EndRegion

;#Region KeyHandler
class KeyHandler {
    static TAP := "Tap"
    static DOUBLE_TAP := "DoubleTap"
    static TRIPLE_TAP := "TripleTap"
    static HOLD := "Hold"
    static TAP_HOLD := "TapHold"
    static DOUBLE_TAP_HOLD := "DoubleTapHold"
    static TRIPLE_TAP_HOLD := "TripleTapHold"

    __New(tapTime := 200, holdTime := 200) {
        this.manager := TapHoldManager(tapTime, holdTime)
        this.keyActions := Map()
    }

    AddKey(keyName, tapTime?, holdTime?) {
        if !this.keyActions.Has(keyName)
            this.keyActions[keyName] := Map()
            
        this.manager.Add(keyName, this.HandleInput.Bind(this, keyName), tapTime?, holdTime?)
    }

    OnPattern(keyName, pattern, callback) {
        if !this.keyActions.Has(keyName)
            this.AddKey(keyName)
            
        this.keyActions[keyName][pattern] := callback
        return this
    }

    HandleInput(keyName, isHold, sequence, state) {
        pattern := this.DeterminePattern(isHold, sequence)
        if this.keyActions[keyName].Has(pattern)
            this.keyActions[keyName][pattern].Call()
    }

    DeterminePattern(isHold, sequence) {
        if (isHold) {
            switch sequence {
                case 1: return KeyHandler.HOLD
                case 2: return KeyHandler.TAP_HOLD
                case 3: return KeyHandler.DOUBLE_TAP_HOLD
                case 4: return KeyHandler.TRIPLE_TAP_HOLD
            }
        } else {
            switch sequence {
                case 1: return KeyHandler.TAP
                case 2: return KeyHandler.DOUBLE_TAP
                case 3: return KeyHandler.TRIPLE_TAP
            }
        }
        return "Unknown"
    }

    OnTap(keyName, callback) => this.OnPattern(keyName, KeyHandler.TAP, callback)
    OnDoubleTap(keyName, callback) => this.OnPattern(keyName, KeyHandler.DOUBLE_TAP, callback)
    OnTripleTap(keyName, callback) => this.OnPattern(keyName, KeyHandler.TRIPLE_TAP, callback)
    OnHold(keyName, callback) => this.OnPattern(keyName, KeyHandler.HOLD, callback)
    OnTapHold(keyName, callback) => this.OnPattern(keyName, KeyHandler.TAP_HOLD, callback)
    
    RemoveKey(keyName) {
        this.manager.RemoveHotkey(keyName)
        this.keyActions.Delete(keyName)
    }
    
    PauseKey(keyName) => this.manager.PauseHotkey(keyName)
    
    ResumeKey(keyName) => this.manager.ResumeHotkey(keyName)
}
;#EndRegion

;#Region Layers
Layer1(IsHold, Taps, State) {
    static wasHeld := false
    if (Layer.currentLayerKey && Layer.currentLayerKey != "F14")
        Layer.Release(true)
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
            SetTimer(() => Layer.Release(), -10)
    }
}

Layer2(IsHold, Taps, State) {
    static wasHeld := false
    
    if (Layer.currentLayerKey && Layer.currentLayerKey != "F13")
        Layer.Release(true)
    Layer.SetLayer("F13")
    
    switch {
        case IsHold:
            Layer.Hold()
            wasHeld := true
            if (Taps = 1) {
                if (State = -1) {
                    Layer.Notify("TapHold")
                    SoundBeep(1500, 100)
                }
            }
        case !IsHold:
            if (!wasHeld) {
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
            }
            wasHeld := false
            SetTimer(() => Layer.Release(), -10)
    }
}

Layer3(IsHold, Taps, State) {
    static wasHeld := false
    
    if (Layer.currentLayerKey  && Layer.currentLayerKey  != "F12")
        Layer.Release(true)
        
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
        case !IsHold:
            switch Taps {
                case 1:
                    if (State = -1) {
                        WinState.Minimize()
                        Layer.Notify("Tap")
                    }
                case 2:
                    Layer.Notify('DoubleTap')
                case 3:
                    Layer.Notify('TripleTap')
            }
            
            SetTimer(() => Layer.Release(), -10)
    }
}

Layer4(IsHold, Taps, State) {
    static wasHeld := false
    holdIndicator := ShowHoldNotify("RAlt")
    
    if (Layer.currentLayerKey && Layer.currentLayerKey  != "RAlt")
        Layer.Release(true)

    Layer.SetLayer("RAlt")

        switch {
            case IsHold:
                Layer.Hold()
                Layer.holdNotificationActive := true
                wasHeld := true
            case !IsHold:
                if (!wasHeld) {
                    switch Taps {
                        case 1:
                            if (State = -1) {
                                Layer.Notify("Tap")
                                Send("{PrintScreen}")
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
                }
                wasHeld := false
                SetTimer(() => Layer.Release(), -10)
        }
}

Layer5(IsHold, Taps, State) {
    static wasHeld := false

    if (Layer.currentLayerKey && Layer.currentLayerKey  != "F15")
        Layer.Release(true)

    Layer.SetLayer("RAlt")
    if (Taps = 1 && !IsHold) {
        SetTimer(() => ToolTipEx(), -800)
    } else if (Taps = 2 && !IsHold) {
        SetTimer(() => ToolTipEx(), -800)
    } else if (IsHold) {
        SetTimer(() => ToolTipEx(), -800)
    }
    if (IsHold) {
        Layer.Hold()
        KeyWait("F15")
    } else {
        switch Taps {
            case 1: 
                try {
                    Cmd.CloseTab()
                } catch as err {
                    ToolTipEx("Error: " err.Message)
                    SetTimer(() => ToolTipEx(), -1500)
                }
            case 2: 
                try {
                    Cmd.ReopenTab()
                } catch as err {
                    ToolTipEx("Error: " err.Message)
                    SetTimer(() => ToolTipEx(), -1500)
                }
            case 3: 
                try {
                    Cmd.NewTab()
                } catch as err {
                    ToolTipEx("Error: " err.Message)
                    SetTimer(() => ToolTipEx(), -1500)
                }
        }
    }
}
;#EndRegion

;#Region WheelOptimizer
class WheelOptimizer {
    static wheelLastProcessed := 0
    static wheelThrottleDelay := 50
    static isInstalled := false
    
    __New() {
        if (WheelOptimizer.isInstalled)
            return
            
        this.InstallWheelFilter()
        WheelOptimizer.isInstalled := true
    }
    
    InstallWheelFilter() {
        SetTimer(this.ProcessWheelEvents.Bind(this), 25)
    }
    
    ProcessWheelEvents() {
        static processing := false
        
        if (processing || !Layer.isActive)
            return
            
        processing := true
        
        try {
            if (GetKeyState("WheelUp", "P") || GetKeyState("WheelDown", "P")) {
                if (A_TickCount - WheelOptimizer.wheelLastProcessed > WheelOptimizer.wheelThrottleDelay) {
                    if (Notify.HasPending && Notify.HasPending("Hold"))
                        Notify.Destroy("Hold")
                    
                    Layer.holdNotificationActive := false
                    WheelOptimizer.wheelLastProcessed := A_TickCount
                }
            }
        } catch as err {
            OutputDebug("WheelOptimizer error: " err.Message)
        } finally {
            processing := false
        }
    }
}
;#EndRegion
