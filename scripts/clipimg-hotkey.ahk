#NoEnv
#SingleInstance Ignore
SendMode Input
SetWorkingDir %A_ScriptDir%

if (A_Args.Length() >= 1 && A_Args[1] = "--self-test")
    ExitApp, 0

mutexHandle := DllCall("CreateMutex", "Ptr", 0, "Int", true, "Str", "Local\ClipboardImagePasteHotkey", "Ptr")
if (!mutexHandle)
    ExitApp, 1
if (A_LastError = 183)
    ExitApp, 0

; Scope image paste handling to command-line windows. Convert image clipboard
; contents to a local path before pasting, which avoids slow native image paste.
#If IsTerminalWindow()
$^v::
    if ClipboardHasImage() {
        PasteConvertedImagePath()
    } else {
        SendInput ^v
    }
return

$^!v::
    if ClipboardHasImage()
        PasteConvertedImagePath()
return
#If

IsTerminalWindow() {
    WinGet, processName, ProcessName, A
    return RegExMatch(processName, "i)^(WindowsTerminal|wt|powershell|pwsh|cmd|OpenConsole)\.exe$")
}

ClipboardHasImage() {
    if DllCall("IsClipboardFormatAvailable", "UInt", 2) ; CF_BITMAP
        return true
    if DllCall("IsClipboardFormatAvailable", "UInt", 8) ; CF_DIB
        return true
    if DllCall("IsClipboardFormatAvailable", "UInt", 17) ; CF_DIBV5
        return true
    return false
}

WaitForPasteChordRelease() {
    KeyWait, v
    KeyWait, LControl
    KeyWait, RControl
    KeyWait, LAlt
    KeyWait, RAlt
}

ClearPasteModifiers() {
    SendInput {LControl up}{RControl up}{LAlt up}{RAlt up}
}

SendTextPasteShortcut() {
    WaitForPasteChordRelease()
    ClearPasteModifiers()
    SendInput {Control down}v{Control up}
}

PasteConvertedImagePath() {
    ConvertClipboardImage()
    Sleep, 80
    SendTextPasteShortcut()
}

RunPasteScript(format := "claude-path") {
    outputDir := A_Temp . "\clipboard-image-paste"
    helperPath := A_LocalAppData . "\ClipboardImagePaste\clipboard-image-save.exe"

    if FileExist(helperPath) {
        RunWait, % """" helperPath """ --output-dir """ outputDir """ --format " format,, Hide
    } else {
        scriptPath := A_ScriptDir . "\paste-clipboard-image.ps1"
        RunWait, % "powershell.exe -NoProfile -Sta -ExecutionPolicy Bypass -File """ scriptPath """ -OutputDir """ outputDir """ -Format " format,, Hide
    }
}

ConvertClipboardImage() {
    RunPasteScript("claude-path")
}
