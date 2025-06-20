#Requires AutoHotkey v2.1-alpha.14
#SingleInstance Force

#Include ClipboardHistory.ahk
#include WinEvent.ahk
#Include ToolTipEx.ahk

;#Region Classes
class Cmd {
    static UseBeeps := true
    static DoBeep(beepType) {
        if (!this.UseBeeps)
            return
        switch beepType {
            case "Tap": Beep.Tap()
            case "Hold": Beep.Hold()
            case "Double": Beep.DoubleTap()
            case "Triple": Beep.TripleTap()
            case "Run": Beep.RunSound()
        }
    }
    ; Modifier key management
    static ReleaseAllModifiers() {
        Send("{LControl Up}{RControl Up}")
        Send("{LShift Up}{RShift Up}")
        Send("{LWin Up}{RWin Up}")
        Send("{LAlt Up}{RAlt Up}")
    }
    static ReleaseFKeys() {
        Send("{F12 Up}{F13 Up}{F14 Up}")
    }
    static ReleaseAll() {
        this.ReleaseAllModifiers()
        this.ReleaseFKeys()
    }
    static SendEnter() {
        Send("{LControl Down}{Enter}{LControl Up}")
    }
    static RestartOSD() {
        Send("{LShift Down}{ScrollLock}{LShift Up}")
    }
    static Run() {
        Send("{LControl Down}{F5}{LControl Up}")
    }
    static Window2SnapLeft() {
        Send("{LShift Down}{LWin Down}{Left}{LWin Up}{LShift Up}")
    }
    static Window2SnapRight() {
        Send("{LWin Down}{LShift Down}{Right}{LWin Up}{LShift Up}")
    }
    static SnippingTool() {
        Send("{LShift Down}{LWin Down}{s}{LWin Up}{LShift Up}")
    }
    static GoogleIt() {
        Send("{LWin Down}{g}{LWin Up}")
    }
    static Copy() {
        Send("{LControl Down}{c}{LControl Up}")
    }
    static CopyURL() {
        Send("{LAlt Down}d{LAlt Up}")
        Sleep(50)
        Send("{LControl Down}c{LControl Up}")
    }
    static GrabAll() {
        Send("{LControl Down}{a}{c}{LControl Up}")
        Sleep(50)
        Send("{LButton}")
        this.DoBeep("double")
    }
    static Grab() {
        Send("{LControl Down}{LAlt Down}{c}{LAlt Up}{LControl Up}")
        Sleep(50)
    }
    static SwitchAccount() {
        Send("^l")
        Sleep(50)
        Send("/SwitchAccount")
        Sleep(50)
        Send("{Enter}")
    }
    static Paste() {
        Send("{LControl Down}{v}{LControl Up}")
    }
    static ColorPicker() {
        Send("{LShift Down}{LWin Down}{c}{LWin Up}{LShift Up}")
    }
    static SwapClip() {
        static SwapClip() {
            if !ClipboardHistory.Count >= 2
                return
            prevClip := ClipboardHistory.GetText(1)
            ClipboardHistory.SetItemAsContent(2)
            Send("{LControl Down}{v}{LControl Up}")
            Sleep(50)
            A_Clipboard := prevClip
        }
    }
    static SwapClip2(*) {
        try {
            currentClip := A_Clipboard
            try {
                ClipboardHistory.SetItemAsContent(2)
                Sleep(50)
                Send("^v")
                Sleep(100)
                A_Clipboard := currentClip
            } catch {
                ToolTip("Could not access clipboard history")
                SetTimer(() => ToolTip(), -2000)
            }
        } catch {
            ToolTip("Clipboard operation failed")
            SetTimer(() => ToolTip(), -2000)
        }
    }
    static Undo() {
        Send("{LControl Down}{z}{LControl Up}")
    }
    static Redo() {
        Send("{LControl Down}{y}{LControl Up}")
    }
    static ClipHistory() {
        Send("{RWin Down}{v}{RWin Up}")
    }
    static Paste2ndClip() {
        Send("{RWin Down}{v}{RWin Up}{Down}{Enter}")
    }
    static RestartExplorer() {
        Send("{LShift Down}{LWin Down}{r}{LWin Up}{LShift Up}")
    }
    static SelectAll() {
        Send("{LControl Down}{a}{LControl Up}")
    }
    static Backspace() {
        Send("{BackSpace}")
    }
    static wordBackspace() {
        Send("{LControl Down}{BackSpace}{LControl Up}")
    }
    static wordDelete() {
        Send("{LControl Down}{Delete}{LControl Up}")
    }
    ; Navigation commands
    static PlayingTab() {
        if WinActive("ahk_exe msedge.exe") {
            Send "^+n"
        } else {
            if WinExist("ahk_exe msedge.exe") {
                WinActivate "ahk_exe msedge.exe"
            } else {
                try {
                    Run "msedge.exe"
                } catch Error as err {
                    MsgBox "Error launching Edge: " err.Message
                }
            }
        }
    }
    static NextTab() {
        Send("{LControl Down}{Tab}{LControl Up}")
    }
    static PlayPause(){
        Send("{Media_Play_Pause}")
    }
    static PrevTab() {
        Send("{LControl Down}{LShift Down}{Tab}{LShift Up}{LControl Up}")
    }
    static NewTab() {
        Send("{LControl Down}{t}{LControl Up}")
    }
    static DuplicateTab() {
        Send("^+k")
    }
    static ReopenTab() {
        Send("{LControl Down}{LShift Down}t{LShift Up}{LControl Up}")
    }
    static CloseTab() {
        Send("{LControl Down}w{LControl Up}")
    }
    static DeleteWord() {
        Send("{LControl Down}{Backspace}{LControl Up}")
    }
    static GameBar() {
        Send("{LWin Down}{g}{LWin Up}")
    }
    ; Document navigation
    static Home() {
        Send("{LControl Down}{Home}{LControl Up}")
    }
    static End() {
        Send("{LControl Down}{End}{LControl Up}")
    }
    ; Window2 management
    static SwitchWindow2(num) {
        Send("{LWin Down}{" num "}{LWin Up}")
    }
    static SwitchMonitor() {
        Send("{LWin Down}{LShift Down}{Left}{LWin Up}{LShift Up}")
    }
    ; Simple key sends
    static SendUp() {
        Send("{Up}")
    }
    static SendDown() {
        Send("{Down}")
    }
    static SendLeft() {
        Send("{Left}")
    }
    static SendRight() {
        Send("{Right}")
    }
    static SendBackspace() {
        Send("{Backspace}")
    }
    static PgUp() {
        Send("{PgUp}")
    }
    static PgDn() {
        Send("{PgDn}")
    }
    ; Function key sends
    static SendF20() {
        Send("{F20}")
    }
    static SendF23() {
        Send("{F23}")
    }
    static OpenNotes() {
        Run("!!!GUI_DarkScintilla.ahk")
    }
    ; Media control
    static VolumeUp() {
        Send("{Volume_Up}")
    }
    static VolumeDown() {
        Send("{Volume_Down}")
    }
    ; Line operations
    static DeleteLine() {
        Send("{Home}{LShift Down}{End}{LShift Up}{Delete}")
    }
    static CopyLine() {
        Send("{Home}{LShift Down}{End}{LShift Up}{LControl Down}c{LControl Up}")
    }
    static PasteLine() {
        Send("{End}{Enter}{LControl Down}v{LControl Up}")
    }
    ; Desktop navigation
    static NextDesktop() {
        Send("{LWin Down}{LControl Down}{Right}{LControl Up}{LWin Up}")
    }
    static PrevDesktop() {
        Send("{LWin Down}{LControl Down}{Left}{LControl Up}{LWin Up}")
    }
    ; Window management
    static CloseWindow() {
        Send("{Alt Down}{F4}{Alt Up}")
    }
}

Runner()
class Runner {
    static EmptyBin(*) {
        try {
            FileRecycleEmpty()
            ToolTip("Recycle Bin Emptied")
            SetTimer(() => ToolTip(), -1000)
        }
        catch {
            ToolTip("Failed to empty Recycle Bin")
            SetTimer(() => ToolTip(), -1000)
        }
    }
    
    static OpenRecycleBin(*) {
        Run "shell:RecycleBinFolder"
    }
    
    static SelectAndOpenInclude(*) {
        scriptText := FileRead(A_ScriptFullPath)
        includePaths := this.ParseIncludes(scriptText)
        if !includePaths.Length {
            ToolTip("No include paths found")
            SetTimer(() => ToolTip(), -1000)
            return
        }
        SelectionGui(includePaths)
    }
    
    static ParseIncludes(scriptText) {
        paths := []
        libFolder := A_ScriptDir "\Lib\"

        loop parse scriptText, "`n", "`r" {
            line := Trim(A_LoopField)

            if RegExMatch(line, "i)^#Include\s+(?!<)(.+\.ahk)\s*$", &match) {
                filePath := match[1]
                if FileExist(filePath)
                    paths.Push(filePath)
                continue
            }

            if RegExMatch(line, "i)^#Include\s*<(.+?)>\s*$", &match) {
                libName := match[1]
                possiblePaths := [
                    libFolder libName ".ahk",
                    libFolder libName
                ]

                for path in possiblePaths {
                    if FileExist(path) {
                        paths.Push(path)
                        break
                    }
                }
            }
        }
        return paths
    }
    
    static RemoveComments(text := "") {
        if (text = "") {
            prevClip := A_Clipboard
            A_Clipboard := ""
            Send "^c"
            if !ClipWait(1)
                return
            text := A_Clipboard
        }
        
        lines := StrSplit(text, "`n", "`r")
        result := ""
        
        for line in lines {
            originalLine := line
            cleanLine := this.RemoveLineComment(line)
            
            ; Check if the line was initially empty/blank
            originalIsBlank := Trim(originalLine) = ""
            
            ; Check if the line contained only a comment
            commentOnly := Trim(originalLine) != "" && Trim(cleanLine) = ""
            
            ; If the line was originally blank, keep it
            ; If the line had content and still has content after comment removal, keep it
            ; If the line contained only a comment, remove it
            if (originalIsBlank || Trim(cleanLine) != "") {
                result .= cleanLine . "`n"
            }
        }
        
        result := RTrim(result, "`n")
        
        if (result = "") {
            A_Clipboard := prevClip
            return
        } else {
            A_Clipboard := result
            Send "^v"
            Sleep 50
            A_Clipboard := prevClip
        }
        
        return result
    }
    
    static RemoveLineComment(line) {
        len := StrLen(line)
        result := ""
        inString := false
        quoteChar := ""
        
        loop len {
            char := SubStr(line, A_Index, 1)
            prevChar := A_Index > 1 ? SubStr(line, A_Index-1, 1) : ""
            
            ; Handle string literals with both single and double quotes
            if (char = '"' || char = "'") {
                ; Check if quote is escaped with backtick
                if (prevChar != "``") {
                    if (!inString) {
                        inString := true
                        quoteChar := char
                    } else if (char = quoteChar) {
                        inString := false
                    }
                }
            }
            
            ; If we find a semicolon outside of a string, it's a comment start
            if (char = ";" && !inString) {
                return result
            }
            
            result .= char
        }
        
        return result
    }
}

class SelectionGui { ; 
    static Styles := Map(
        "dark", [0xFF171717, 0xFF1A1A1A, 0xFFFFFFFF, 6, 0xFF1A1A1A, 1]
    )

    __New(paths) {
        this.gui := Gui("+AlwaysOnTop +Resize", "Select Include File")
        this.SetupGui(paths)
        this.SetupEvents()
    }

    SetupGui(paths) {
        this.gui.SetFont("s10", "Segoe UI")
        this.gui.BackColor := "171717"

        this.lv := this.gui.Add("ListView", "x10 y10 w580 h300 -Multi Background171717 cWhite", ["Path"])
        this.lv.ModifyCol(1, 500)

        for path in paths
            this.lv.Add(, path)

        this.btnOpen := this.gui.Add("Button", "x10 y+10 w100 h30", "Open")
        this.btnCancel := this.gui.Add("Button", "x+10 w100 h30", "Cancel")

        this.gui.Show("AutoSize")
    }

    SetupEvents() {
        this.gui.OnEvent("Close", (*) => this.gui.Destroy())
        this.gui.OnEvent("Escape", (*) => this.gui.Destroy())
        this.gui.OnEvent("Size", this.OnResize.Bind(this))

        this.btnOpen.OnEvent("Click", this.OpenSelected.Bind(this))
        this.btnCancel.OnEvent("Click", (*) => this.gui.Destroy())

        this.lv.OnEvent("DoubleClick", this.OpenSelected.Bind(this))
    }

    OnResize(thisGui, minMax, width, height) {
        if minMax = -1
            return
        this.lv.Move(, , width - 20, height - 50)
        this.btnOpen.Move(, height - 35)
        this.btnCancel.Move(115, height - 35)
    }

    OpenSelected(*) {
        if !this.lv.GetNext()
            return
        selectedPath := this.lv.GetText(this.lv.GetNext())
        if selectedPath
            Run('cmd.exe /c code "' selectedPath '"', , "Hide")
        this.gui.Destroy()
    }
}

/**
 * @class Beep
 * @description Handles various sound effects and audio playback functionality
 * @static
 */
class Beep {
    /** @property {Number} DefaultFrequency - The default frequency in Hz for beep sounds */
    static DefaultFrequency := 500

    /** @property {Number} DefaultDuration - The default duration in milliseconds for beep sounds */
    static DefaultDuration := 100

    /** @property {Number} DefaultDelay - The default delay in milliseconds between beep sounds */
    static DefaultDelay := 100

    /**
     * @method Tap
     * @description Plays a single beep sound at default frequency and duration
     * @static
     */
    static Tap() {
        SoundBeep(this.DefaultFrequency, this.DefaultDuration)
    }

    /**
     * @method Hold
     * @description Plays a longer, higher-pitched beep sound
     * @static
     */
    static Hold() {
        SoundBeep(600, 500)
    }

    /**
     * @method DoubleTap
     * @description Plays two conseculetive beep sounds with default delay between them
     * @static
     */
    static DoubleTap() {
        SoundBeep(this.DefaultFrequency, this.DefaultDuration)
        Sleep(this.DefaultDelay)
        SoundBeep(this.DefaultFrequency, this.DefaultDuration)
    }

    /**
     * @method TapHold
     * @description Plays a tap sound followed by a hold sound
     * @static
     */
    static TapHold() {
        this.Tap()
        Sleep(this.DefaultDelay)
        this.Hold()
    }

    /**
     * @method TripleTap
     * @description Plays three consecutive beep sounds with default delay between them
     * @static
     */
    static TripleTap() {
        Loop 3 {
            SoundBeep(this.DefaultFrequency, this.DefaultDuration)
            if (A_Index < 3)
                Sleep(this.DefaultDelay)
        }
    }

    /**
     * @method QuadTap
     * @description Plays four consecutive beep sounds with default delay between them
     * @static
     */
    static QuadTap() {
        Loop 4 {
            SoundBeep(this.DefaultFrequency, this.DefaultDuration)
            if (A_Index < 4)
                Sleep(this.DefaultDelay)
        }
    }

    /**
     * @method IsSoundAvailable
     * @description Tests if sound playback is available
     * @returns {Boolean} True if sound is available
     * @static
     */
    static IsSoundAvailable() {
        SoundBeep(1000, 1)
        return true
    }

    /**
     * @method SetVolume
     * @description Sets the system volume level
     * @param {Number} level - The volume level to set
     * @static
     */
    static SetVolume(level) {
        SoundSetVolume(level)
    }

    /**
     * @method PlaySoundAtHalfVolume
     * @description Plays an audio file at reduced volume
     * @param {String} filePath - Path to the audio file
     * @static
     */
    static PlaySoundAtHalfVolume(filePath) {
        currentVolume := SoundGetVolume()
        this.SetVolume(currentVolume / 8)
        try {
            static wmp := ComObject("WMPlayer.OCX")
            wmp.URL := filePath
            wmp.controls.play()
            While wmp.playState != 1
                Sleep(100)
        } catch {
            Run(filePath)
            Sleep(3000)
        }
        this.SetVolume(currentVolume)
    }

    static PlaySound(filePath) {
        try {
            static wmp := ComObject("WMPlayer.OCX")
            wmp.URL := filePath
            wmp.controls.play()
            While wmp.playState != 1
                Sleep(100)
        } catch {
            Run(filePath)
            Sleep(3000)
        }
    }

    /**
     * @method RunSound
     * @description Plays the run sound effect from the Lib/Sounds folder
     * @static
     */
    static RunSound() {
        static soundFile := A_ScriptDir "\Lib\Sounds\Run.mp3"
        this.PlaySoundAtHalfVolume(soundFile)
    }

    /**
     * @method Run
     * @description Plays the record sound effect from the Lib/Sounds folder
     * @static
     */
    static Run() {
        static soundFile := A_ScriptDir "\Lib\Sounds\Record.mp3"
        this.PlaySoundAtHalfVolume(soundFile)
    }
    static SoundCopy() {
        static soundFile := A_ScriptDir "\Lib\Sounds\Click.wav"
        this.PlaySoundAtHalfVolume(soundFile)
    }
    static SoundClick() {
        static soundFile := A_ScriptDir "\Lib\Sounds\Click.wav"
        this.PlaySound(soundFile)
    }
    static SoundSelect() {
        static soundFile := A_ScriptDir "\Lib\Sounds\Select.wav"
        this.PlaySoundAtHalfVolume(soundFile)
    }
    static SoundAlert() {
        static soundFile := A_ScriptDir "\Lib\Sounds\Alert.wav"
        this.PlaySoundAtHalfVolume(soundFile)
    }
}

class KeyThrottle {
    static lastPress := 0
    static threshold := 400

    static CheckThrottle() {
        if (A_TickCount - this.lastPress < this.threshold)
            return false
        this.lastPress := A_TickCount
        return true
    }
}

class BambuMonitor {
    __New() {
        this.studioRunning := ProcessExist("Bambu-Studio.exe")
        this.runningIcon := A_ScriptDir "\Lib\Icons\bKeyDark.png"
        this.stoppedIcon := A_ScriptDir "\Lib\Icons\Icon_GreenCheck.png"

        TraySetIcon(this.studioRunning ? this.runningIcon : this.stoppedIcon)
        A_IconHidden := false

        WinEvent.Create(this.OnStudioStart.Bind(this), "ahk_exe Bambu-Studio.exe")
        WinEvent.Close(this.OnStudioClose.Bind(this), "ahk_exe Bambu-Studio.exe")

        this.UpdateTray()
    }
    OnStudioStart(hWnd, *) {
        this.studioRunning := true
        this.UpdateTray()
    }
    OnStudioClose(hWnd, *) {
        this.studioRunning := false
        this.UpdateTray()
    }
    UpdateTray() {
        TraySetIcon(this.studioRunning ? this.runningIcon : this.stoppedIcon)
    }
}

/**
 * Window2State Class
 * Manages window2 states including minimizing, unminimizing, and handling window2s with same titles or processes.
 * 
 * Properties:
 * - Minimized: Static array storing minimized window2 IDs
 * - State_Minimized: Static constant defining minimized state (-1)
 * 
 * Methods:
 * - Minimize(): Minimizes the active window2
 * - UnMinimize(): Restores the most recently minimized window2
 * - HandleChromeWindow2sWithSameTitle(): Manages multiple Chrome window2s with identical titles
 * - HandleWindow2sWithSameProcessAndClass(): Manages multiple window2s of the same process and class
 * - ExtractAppTitle(): Extracts application title from full window2 title
 */
class WinState {
    static Minimized := []
    static State_Minimized := -1

    static Minimize() {
        if (hwnd := WinExist("A")) {
            WinID := "ahk_id " hwnd
            if (WinGetMinMax(WinID) != this.State_Minimized) {
                if this.SendMinimize(WinID)
                    this.Minimized.Push({ id: WinID, title: WinGetTitle(WinID) })
            }
        }
    }

    static UnMinimize() {
        while (this.Minimized.Length) {
            winInfo := this.Minimized.Pop()
            if WinExist(winInfo.id) {
                this.SendRestore(winInfo.id)
                return true
            }
        }
        return false
    }

    static SendMinimize(winId) {
        try {
            PostMessage(0x0112, 0xF020, 0, , winId)
            return true
        }
        return false
    }

    static MaximizeActive() {
        hwnd := WinActive("A")
        if !hwnd
            return false
        try {
            WinMaximize("ahk_id " hwnd)
            return true
        }
        return false
    }

    static SendRestore(winId) {
        try {
            PostMessage(0x0112, 0xF120, 0, , winId)
            return true
        }
        return false
    }
    /**
     * Handles multiple Chrome window2s with the same title by cycling through them.
     * Activates the last window2 in the list of window2s with matching titles.
     */
    static HandleChromeWindow2s() {
        if !(hwnd := WinActive("A"))
            return

        fullTitle := WinGetTitle(hwnd)
        appTitle := this.ExtractAppTitle(fullTitle)
        SetTitleMatchMode(2)

        if (window2s := WinGetList(appTitle)) && window2s.Length {
            WinActivate("ahk_id " window2s[window2s.Length])
        }
    }

    /**
     * Extracts the application title from a full window2 title.
     * @param {string} fullTitle - The complete window2 title
     * @returns {string} The extracted application title
     */
    static ExtractAppTitle(fullTitle) {
        return fullTitle
    }

    /**
     * Cycles through window2s of the same application, with special handling for Explorer window2s.
     */
    static SameApp() {
        if !(win_id := WinActive("A"))
            return

        win_class := WinGetClass(win_id)
        active_process := WinGetProcessName(win_id)

        ; Get window2 list based on process and optionally class
        win_list := (active_process = "explorer.exe")
            ? WinGetList("ahk_exe " active_process " ahk_class " win_class)
            : WinGetList("ahk_exe " active_process)

        if (win_list && win_list.Length) {
            next_id := win_list[win_list.Length]
            WinMoveTop("ahk_id " next_id)
            WinActivate("ahk_id " next_id)
        }
    }
}
;#EndRegion
class ClipboardMonitor {
    __New() {
        this.previousClip := ""
        this.SetupTimer()
    }

    SetupTimer() {
        this.timer := this.CheckClipboard.Bind(this)
        SetTimer(this.timer, 200)
    }

    CheckClipboard() {
        if (this.previousClip != A_Clipboard && A_Clipboard != "") {
            try {
                Beep.SoundClick()
                trimmedText := Trim(A_Clipboard)
                previewText := RegExReplace(SubStr(trimmedText, 1, 20), "[\r\n]+", " ") " ..."
                ToolTipEx("Copied: " previewText, 1)
            }
            this.previousClip := A_Clipboard
        }
    }
}

class TextSend {
    static stateList := [
        "Illinois",
        "Indiana",
        "Iowa",
        "Kansas",
        "Michigan",
        "Minnesota",
        "Missouri",
        "Nebraska",
        "Ohio",
        "Wisconsin"
    ]

    static cityList := [
        "Chicago",
        "Columbus",
        "Des Moines",
        "Detroit",
        "Grand Rapids",
        "Indianapolis",
        "Kansas City",
        "Minneapolis",
        "St. Louis"
    ]

    __New() {
        Hotkey("^!s", this.SendStates.Bind(this))
        Hotkey("^!c", this.SendCities.Bind(this))
        Hotkey("^!a", this.SendCustomArray.Bind(this, ["Custom Item 1", "Custom Item 2"]))
    }

    SendStates(*) {
        this.SendArrayText(TextSend.stateList)
    }

    SendCities(*) {
        this.SendArrayText(TextSend.cityList)
    }

    SendCustomArray(customArray, *) {
        this.SendArrayText(customArray)
    }

    SendArrayText(arr) {
        for _, item in arr {
            Send(item)
            Send("{Enter}")
        }
    }
}

; class ErrorLog {
;     static tooltips := Map()

;     __New() {
;         OnError(ObjBindMethod(this, "HandleError"))
;     }

;     ShowToolTip(text, timeout := 1000) {
;         try {
;             TooltipEx(text)
;         } catch {
;             ToolTip(text)
;             timer := this.RemoveToolTip.Bind(this)
;             SetTimer(timer, -timeout)
;         }
;     }

;     RemoveToolTip(*) {
;         ToolTip()
;     }

;     HandleError(err, mode) {
;         this.stdo("Error: " err.Message "`nStack: " err.Stack)
;         clipText := "=== Error Details ===`n"
;         clipText .= "Message: " err.Message "`n"
;         clipText .= "File: " err.File "`n"
;         clipText .= "Line: " err.Line "`n"
;         clipText .= "What: " err.What "`n"
;         clipText .= "Error Code: " (err.HasProp("Number") ? err.Number : "N/A") "`n"
;         clipText .= "`n=== Stack Trace ===`n" err.Stack
;         A_Clipboard := clipText
;         this.ShowToolTip("Error details copied to clipboard")
;         return true
;     }

;     stdo(msg*) {
;         msg_out := ""
;         for itm in msg
;             msg_out .= this.TryStringOut(itm)
;         FileAppend(msg_out, "*")
;     }

;     TryStringOut(out_item, isMapVal := false) {
;         Try {
;             return String(out_item) "`n"
;         } Catch MethodError {
;             return this.TryArrayOut(out_item, isMapVal)
;         }
;     }

;     TryArrayOut(out_item, isMapVal := false) {
;         If Type(out_item) = "Array" {
;             out_string := ""
;             For item in out_item {
;                 if isMapVal
;                     out_string .= "`t"
;                 out_string .= this.TryStringOut(item)
;             }
;             return out_string
;         }
;         return this.TryMapOut(out_item)
;     }

;     TryMapOut(out_item) {
;         If Type(out_item) = "Map" {
;             out_string := ""
;             For itemkey, itemval in out_item {
;                 out_string .= itemkey " " itemval
;             }
;             return out_string
;         }
;         return this.TryObjectOut(out_item)
;     }

;     TryObjectOut(out_item) {
;         If IsObject(out_item) {
;             If out_string := ComObjType(out_item, "Name")
;                 return out_string
;             If out_item.HasOwnProp("Prototype")
;                 out_string := out_item.Prototype.__Class
;             Else out_string := out_item.__Class, out_item := ObjGetBase(out_item)
;             return out_string
;         }
;     }
; }


class FileManager2 {
    static basePath := "C:\Users\uphol\Documents\Design\Coding\AHK\"
    static archivePath := FileManager2.basePath "!Running\Lib\Archive"

    static Archive(*) {
        A_Clipboard := ""
        Send "^c"
        ClipWait(2)

        if !A_Clipboard
            return

        relativePath := StrReplace(Trim(A_Clipboard), "/", "\")
        sourcePath := FileManager2.basePath relativePath

        if !FileExist(sourcePath)
            return

        SplitPath(sourcePath, &fileName)
        destPath := FileManager2.archivePath "\" fileName

        try {
            FileMove(sourcePath, destPath)
            ToolTip("Archived", , , 1)
            SetTimer () => ToolTip(, , , 1), -1000
        }
    }
}

Key()
class Key {
    static Decrypt(str) {
        return str
    }
}

class Cmd2 {
    ;#Region System
    static UseBeeps := true
    
    static DoBeep(beepType) {
        if (!this.UseBeeps)
            return
        switch beepType {
            case "Tap": Beep.Tap()
            case "Hold": Beep.Hold()
            case "Double": Beep.DoubleTap()
            case "Triple": Beep.TripleTap()
            case "Run": Beep.RunSound()
        }
    }
    
    static RestartOSD() {
        Send("{LShift Down}{ScrollLock}{LShift Up}")
    }
    
    static RestartExplorer() {
        Run "C:\\Users\\uphol\\OneDrive\\Desktop\\RestartExplorer.bat"
    }
    
    static GameBar() {
        Send("{LWin Down}{g}{LWin Up}")
    }
    
    static GoogleIt() {
        Send("{LWin Down}{g}{LWin Up}")
    }
    
    static Researcher() {
        SavedClipboard := ClipboardAll()
        A_Clipboard := ""
        Send("^c")
        Errorlevel := !ClipWait(0.5)
        if ErrorLevel {
            A_Clipboard := SavedClipboard
            return
        }
        SelectedText := trim(A_Clipboard)
        if RegExMatch(SelectedText, "^https?://") {
            Run(SelectedText)
        } else if RegExMatch(SelectedText, "^\d:\\") {
            ExplorerPath := "explorer /select," SelectedText
            Run(ExplorerPath)
        } else {
            SelectedText := StrReplace(SelectedText, "`r`n", A_Space)
            SelectedText := StrReplace(SelectedText, "#", "`%23")
            SelectedText := StrReplace(SelectedText, "&", "`%26")
            SelectedText := StrReplace(SelectedText, "+", "`%2b")
            SelectedText := StrReplace(SelectedText, "`"", "`%22")
            Run("https://www.google.com/search?hl=en&q=" . SelectedText)
        }
        A_Clipboard := SavedClipboard
    }
    
    static ColorPicker() {
        Send("{LShift Down}{LWin Down}{c}{LWin Up}{LShift Up}")
    }
    
    static SnippingTool() {
        Send("{LShift Down}{LWin Down}{s}{LWin Up}{LShift Up}")
    }
    
    static OpenNotes() {
        Run("!!!GUI_DarkScintilla.ahk")
    }
    
    static Run() {
        Send("{LControl Down}{F5}{LControl Up}")
    }
    
    static ReleaseAllKeys() {
        SendInput("{LShift Up}{LControl Up}{LAlt Up}{LWin Up}{F14 Up}{F13 Up}{F12 Up}{NumLock}")
    }
    
    static AlwaysOnTop() {
        Active := WinGetTitle("A")
        If !(WinGetMinMax(Active)) {
            WinSetAlwaysOnTop -1, Active
            ExStyle := WinGetExStyle(Active)
            If ((ExStyle & 0x8))
                ToolTip Active "`nis always-on-top now."
            else
                ToolTip Active "`nis NOT always-on-top anymore."
        } else
            ToolTip "Maximized windows are protected to be always-on-top"
        SetTimer () => ToolTip(), -4000
    }
    
    static MSTeamsMute() {
        if WinExist("ahk_exe MsTeams.exe") {
            WinActivate
            Send("^+M")
        }
    }
    
    static OpenUnzip() {
        Destination := "C:\users\" A_userName "\Downloads"
        Time := 0
        LatestFolder := ""
        Loop Files, Destination "\*.*", "D"
        {
            if (SubStr(A_LoopFileName, -3) = ".zip")
                continue

            If (A_LoopFileTimeModified >= Time)
            {
                Time := A_LoopFileTimeModified
                LatestFolder := A_LoopFileName
            }
        }
        If (LatestFolder != "")
        {
            Run("explorer.exe /open,`"" Destination "\" LatestFolder "`"")
            Send("{Enter}")
        }
        else
        {
            Run(Destination)
        }
    }
    ;#EndRegion System
    
    ;#Region Modifier Keys
    static ReleaseAllModifiers() {
        Send("{LControl Up}{RControl Up}")
        Send("{LShift Up}{RShift Up}")
        Send("{LWin Up}{RWin Up}")
        Send("{LAlt Up}{RAlt Up}")
    }
    
    static ReleaseFKeys() {
        Send("{F12 Up}{F13 Up}{F14 Up}")
    }
    
    static ReleaseAll() {
        this.ReleaseAllModifiers()
        this.ReleaseFKeys()
    }
    ;#EndRegion Modifier Keys
    
    ;#Region Text Operations
    static Copy() {
        Send("{LControl Down}{c}{LControl Up}")
    }
    
    static CopyURL() {
        Send("{LAlt Down}d{LAlt Up}")
        Sleep(50)
        Send("{LControl Down}c{LControl Up}")
    }
    
    static CopyFilePath() {
        if WinActive("ahk_class CabinetWClass") or WinActive("ahk_class ExploreWClass") {
            Send "^c"
            Sleep 50
            if (A_Clipboard != "") {
                filepath := A_Clipboard
                filepath := StrReplace(filepath, "`r`n", "")
                filepath := StrReplace(filepath, "`n", "")
                filepath := StrReplace(filepath, "`"`"", "")
                A_Clipboard := filepath
                ToolTip "File path copied to clipboard: " filepath
                SetTimer () => ToolTip(), -2000
            }
        }
        Else If WinActive("ahk_exe MsEdge.exe") {
            Send("{F4}")
            Send("{Ctrl Down}{c}{Ctrl Up}")
            Send("{Esc 2}")
        }
    }
    
    static Paste() {
        Send("{LControl Down}{v}{LControl Up}")
    }
    
    static Grab() {
        Send("{LControl Down}{a}{c}{LControl Up}{Escape}{Home}")
        cmd.DoBeep("double")
    }
    
    static SwapClip() {
        if !ClipboardHistory.Count >= 2
            return
            
        prevClip := ClipboardHistory.GetText(1)
        ClipboardHistory.SetItemAsContent(2)
        Send("{LControl Down}{v}{LControl Up}")
        Sleep(50)
        A_Clipboard := prevClip
    }
    
    static SwapClip2(*) {
        try {
            ; Store current clipboard
            currentClip := A_Clipboard

            ; Attempt to use the second clipboard history item
            try {
                ClipboardHistory.SetItemAsContent(2)
                Sleep(50)
                Send("^v")
                Sleep(100)
                A_Clipboard := currentClip
            } catch {
                ; Simple fallback without calling other methods
                ToolTip("Could not access clipboard history")
                SetTimer(() => ToolTip(), -2000)
            }
        } catch {
            ; Fallback if any other error occurs
            ToolTip("Clipboard operation failed")
            SetTimer(() => ToolTip(), -2000)
        }
    }
    
    static ClipHistory() {
        Send("{RWin Down}{v}{RWin Up}")
    }
    
    static Paste2ndClip() {
        Send("{RWin Down}{v}{RWin Up}{Down}{Enter}")
    }
    
    static SelectAll() {
        Send("{LControl Down}{a}{LControl Up}")
    }
    
    static Undo() {
        Send("{LControl Down}{z}{LControl Up}")
    }
    
    static Redo() {
        Send("{LControl Down}{y}{LControl Up}")
    }
    
    static Backspace() {
        Send("{BackSpace}")
    }
    
    static WordBackspace() {
        Send("{LControl Down}{BackSpace}{LControl Up}")
    }
    
    static WordDelete() {
        Send("{LControl Down}{Delete}{LControl Up}")
    }
    
    static DeleteWord() {
        Send("{LControl Down}{Backspace}{LControl Up}")
    }
    
    static PasteAhkTemplate() {
        savedClipboard := ClipboardAll()
        A_Clipboard := "#Requires AutoHotkey v2.0`n#SingleInstance Force`n#Include <All>`n"
        Send "^v"
        Sleep 100
        Send "{Enter}"
        A_Clipboard := savedClipboard
    }
    
    static PasteDiscordCode() {
        Send("``````cpp`n")
        Send('^v')
        Send("`n``````")
    }
    ;#EndRegion Text Operations
    
    ;#Region Navigation
    static NextTab() {
        Send("{LControl Down}{Tab}{LControl Up}")
    }
    
    static PrevTab() {
        Send("{LControl Down}{LShift Down}{Tab}{LShift Up}{LControl Up}")
    }
    
    static ReopenTab() {
        Send("^+t")
    }
    
    static Home() {
        Send("{LControl Down}{Home}{LControl Up}")
    }
    
    static End() {
        Send("{LControl Down}{End}{LControl Up}")
    }
    
    static SendUp() {
        Send("{Up}")
    }
    
    static SendDown() {
        Send("{Down}")
    }
    
    static SendLeft() {
        Send("{Left}")
    }
    
    static SendRight() {
        Send("{Right}")
    }
    
    static SendBackspace() {
        Send("{Backspace}")
    }
    
    static PgUp() {
        Send("{PgUp}")
    }
    
    static PgDn() {
        Send("{PgDn}")
    }
    
    static SendEnter() {
        Send("{LControl Down}{Enter}{LControl Up}")
    }
    
    static AltTabKey() {
        SendEvent "{LWin Down}{Tab}{LWin Up}"
    }
    ;#EndRegion Navigation
    
    ;#Region Window Management
    static Window2SnapLeft() {
        Send("{LShift Down}{LWin Down}{Left}{LWin Up}{LShift Up}")
    }
    
    static Window2SnapRight() {
        Send("{LWin Down}{LShift Down}{Right}{LWin Up}{LShift Up}")
    }
    
    static SwitchWindow2(num) {
        Send("{LWin Down}{" num "}{LWin Up}")
    }
    
    static SwitchMonitor() {
        Send("{LWin Down}{LShift Down}{Left}{LWin Up}{LShift Up}")
    }
    
    static CloseWindow() {
        Send("{Alt Down}{F4}{Alt Up}")
    }
    
    static MinimizeWindow() {
        if (hwnd := WinExist("A")) {
            WinID := "ahk_id " hwnd
            PostMessage(0x0112, 0xF020, 0, , WinID)
        }
    }
    
    static RestoreWindow() {
        if (hwnd := WinExist("A")) {
            WinID := "ahk_id " hwnd
            PostMessage(0x0112, 0xF120, 0, , WinID)
        }
    }
    
    static MaximizeWindow() {
        if (hwnd := WinExist("A")) {
            WinID := "ahk_id " hwnd
            PostMessage(0x0112, 0xF030, 0, , WinID)
        }
    }
    
    static CycleWindowsOfSameApp() {
        if !(win_id := WinActive("A"))
            return

        win_class := WinGetClass(win_id)
        active_process := WinGetProcessName(win_id)

        ; Get window list based on process and optionally class
        win_list := (active_process = "explorer.exe")
            ? WinGetList("ahk_exe " active_process " ahk_class " win_class)
            : WinGetList("ahk_exe " active_process)

        if (win_list && win_list.Length) {
            next_id := win_list[win_list.Length]
            WinMoveTop("ahk_id " next_id)
            WinActivate("ahk_id " next_id)
        }
    }
    
    static CloseTab() {
        Send("{LControl down}w{LControl up}")
    }
    
    static NameWindow() {
        If WinActive("ahk_exe MsEdge.exe")
            Send("{Blind}{f}{LAlt Up}")
        Send("{l}")
        Send("{w}")
        SendInput("Main")
        Send("{Enter}")
    }
    
    static ShowComms() {
        if WinExist("ahk_exe MsTeams.exe") {
            WinActivate
        } else if WinExist("ahk_exe Discord.exe") {
            WinActivate
        }
    }
    
    static ShowEdge() {
        If WinActive("ahk_exe MsEdge.exe")
            Send("{F10}")
        else
            WinActivate("ahk_exe MsEdge.exe")
    }
    
    static OpenDownloads() {
        If WinExist("Downloads") {
            WinActivate("Downloads")
        } else {
            Run "C:\Users\" A_Username "\Downloads"
            if WinWait("Downloads", , 3)
                WinActivate("Downloads")
            else
                Run "C:\Users\" A_Username "\Downloads"
        }
    }
    ;#EndRegion Window Management
    
    ;#Region Line Operations
    static DeleteLine() {
        Send("{Home}{LShift Down}{End}{LShift Up}{Delete}")
    }
    
    static CopyLine() {
        Send("{Home}{LShift Down}{End}{LShift Up}{LControl Down}c{LControl Up}")
    }
    
    static PasteLine() {
        Send("{End}{Enter}{LControl Down}v{LControl Up}")
    }
    ;#EndRegion Line Operations
    
    ;#Region Function Keys
    static F6() {
        Send("{F6}")
    }
    
    static SendF20() {
        Send("{F20}")
    }
    
    static SendF23() {
        Send("{F23}")
    }
    ;#EndRegion Function Keys
    
    ;#Region Media Controls
    static VolumeUp() {
        Send("{Volume_Up}")
    }
    
    static VolumeDown() {
        Send("{Volume_Down}")
    }
    ;#EndRegion Media Controls
    
    ;#Region Desktop Management
    static NextDesktop() {
        Send("{LWin Down}{LControl Down}{Right}{LControl Up}{LWin Up}")
    }
    
    static PrevDesktop() {
        Send("{LWin Down}{LControl Down}{Left}{LControl Up}{LWin Up}")
    }
    ;#EndRegion Desktop Management
    
    ;#Region Special Functions
    static ExitAllScriptsExcept() {
        DetectHiddenWindows(true)
        for hwnd in WinGetList("ahk_class AutoHotkey") {
            title := WinGetTitle("ahk_id " hwnd)
            if !RegExMatch(title, "(_zHolder.ahk|_!Always.ahk)") {
                PostMessage(0x111, 65405, 0, , title)
            }
        }
    }
    
    static ReloadScripts() {
        ToolTip("Reloading autohotkey script " A_ScriptFullPath)
        SetTimer () => ToolTip(), -1000
        Reload()
    }
    
    static RunOSK() {
        MouseGetPos &mx, &my
        Run "osk.exe"
        try {
            oskHwnd := WinWait("ahk_exe osk.exe", , 5)
        } catch {
            MsgBox "Failed to launch on-screen keyboard."
            return
        }
        WinMove mx, my
        activeHwnd := WinGetID("A")
        WinActivate "ahk_id " activeHwnd
    }
    ;#EndRegion Special Functions
}

;#Region Text Functions
class TextClass {
    class FormatHeaders {
        static Title := "Format Text as Header"
        static Hotkey := "^+H"

        static Run(*) {
            savedClip := ClipboardAll()
            A_Clipboard := ""
            Send("^c")
            ClipWait(1)

            if (A_Clipboard) {
                text := Trim(A_Clipboard)
                text := RegExReplace(text, "[^\w\s]", "")
                text := Trim(text)
                text := StrReplace(text, " ", "_")
                text := Format("{:U}", text)
                text := "<" text ">"

                A_Clipboard := text
                Send("^v")
            }

            Sleep(100)
            A_Clipboard := savedClip
        }
    }

    class CapitalizeTag {
        static Title := "Capitalize Content Inside Tags"
        static Hotkey := "^+T"

        static Run(*) {
            savedClip := ClipboardAll()
            A_Clipboard := ""
            Send("^c")
            ClipWait(1)

            if (A_Clipboard) {
                text := A_Clipboard
                text := RegExReplace(text, ">([^<>]+)<", TextClass.CapitalizeTag.CapitalizeMatch)
                A_Clipboard := text
                Send("^v")
            }
            Sleep(100)
            A_Clipboard := savedClip
        }

        static CapitalizeMatch(match) {
            content := match[1]
            uppercaseContent := StrUpper(content)
            return ">" uppercaseContent "<"
        }
    }

    class ChangeFirst {
        static Title := "Change First Word"
        static Hotkey := "^+1"

        static Run(*) {
            Send("{LControl Down}{Left}{LControl Up}{LControl Down}{LShift Down}{Right}{LShift Up}{LControl Up}")
            Sleep(50)
            SendInput("Changed 1")
        }
    }

    class ChangeSecond {
        static Title := "Change Second Word"
        static Hotkey := "^+2"

        static Run(*) {
            Send("{LControl Down}{Left}{LControl Up}{LControl Down}{LShift Down}{Right}{LShift Up}{LControl Up}")
            Sleep(50)
            SendInput("Changed 2")
        }
    }

    class ChangeThird {
        static Title := "Change Third Word"
        static Hotkey := "^+3"

        static Run(*) {
            Send("{LControl Down}{Left}{LControl Up}{LControl Down}{LShift Down}{Right}{LShift Up}{LControl Up}")
            Sleep(50)
            SendInput("Changed 3")
        }
    }

    class ListNumbers {
        static Title := "Extract and List Numbers"
        static Hotkey := "^+N"

        static Run(*) {
            numbers := []
            uniqueNums := Map()
            clipContent := A_Clipboard

            if (clipContent) {
                Loop Parse, clipContent, "`n", "`r" {
                    if RegExMatch(A_LoopField, "\b\d{7}\b", &match) {
                        if !uniqueNums.Has(match[0]) {
                            numbers.Push(match[0])
                            uniqueNums[match[0]] := true
                        }
                    }
                }
            }

            result := ""
            for index, number in numbers {
                result .= number (index < numbers.Length ? "`n" : "")
            }

            A_Clipboard := result
        }
    }

    class CleanNumber {
        static Title := "Clean Number in Clipboard"
        static Hotkey := "^+C"

        static Run(*) {
            if RegExMatch(A_Clipboard, "\b\d{7}\b", &match)
                A_Clipboard := StrReplace(match[0], A_Space)
        }
    }
}
;#EndRegion Text Functions

class RestartHolder {
    __New() {
        this.RestartScript("_zHolder.ahk")
    }
    
    RestartScript(scriptName) {
        DetectHiddenWindows(true)
        WinTitle := "ahk_class AutoHotkey"
        ScriptList := WinGetList(WinTitle)
        
        foundScript := false
        
        for i, hwnd in ScriptList {
            WinTitle := WinGetTitle("ahk_id " hwnd)
            if InStr(WinTitle, scriptName) {
                pid := WinGetPID("ahk_id " hwnd)
                ProcessClose(pid)
                Sleep(200)
                foundScript := true
                break
            }
        }
        
        if (foundScript) {
            Run(A_AhkPath " " A_ScriptDir "\" scriptName)
            ToolTip(scriptName " has been restarted")
        } else {
            ToolTip("Could not find " scriptName)
            Run(A_AhkPath " " A_ScriptDir "\" scriptName)
        }
        
        SetTimer(() => ToolTip(), -3000)
    }
}

    
