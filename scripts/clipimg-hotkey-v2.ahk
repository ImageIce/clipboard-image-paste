#Requires AutoHotkey v2.0
#SingleInstance Ignore
SendMode "Input"
SetWorkingDir A_ScriptDir

if (A_Args.Length >= 1 && A_Args[1] = "--self-test") {
    ExitApp 0
}

mutexHandle := DllCall("CreateMutex", "Ptr", 0, "Int", true, "Str", "Local\ClipboardImagePasteHotkey", "Ptr")
if (!mutexHandle) {
    ExitApp 1
}
if (A_LastError = 183) {
    ExitApp 0
}

; Scope image paste handling to command-line windows. Convert image clipboard
; contents to a local path before pasting, which avoids slow native image paste.
#HotIf IsTerminalWindow()
$^v:: {
    if ClipboardHasImage() {
        PasteConvertedImagePath()
    } else {
        Send "^v"
    }
}

$^!v:: {
    if ClipboardHasImage() {
        PasteConvertedImagePath()
    }
}
#HotIf

IsTerminalWindow() {
    try {
        processName := WinGetProcessName("A")
    } catch {
        return false
    }

    return processName ~= "i)^(WindowsTerminal|wt|powershell|pwsh|cmd|OpenConsole)\.exe$"
}

ClipboardHasImage() {
    return DllCall("IsClipboardFormatAvailable", "UInt", 2)
        || DllCall("IsClipboardFormatAvailable", "UInt", 8)
        || DllCall("IsClipboardFormatAvailable", "UInt", 17)
}

WaitForPasteChordRelease() {
    KeyWait "v"
    KeyWait "LControl"
    KeyWait "RControl"
    KeyWait "LAlt"
    KeyWait "RAlt"
}

ClearPasteModifiers() {
    Send "{LControl up}{RControl up}{LAlt up}{RAlt up}"
}

SendTextPasteShortcut() {
    WaitForPasteChordRelease()
    ClearPasteModifiers()
    Send "{Control down}v{Control up}"
}

PasteConvertedImagePath() {
    ConvertClipboardImage()
    Sleep 80
    SendTextPasteShortcut()
}

RunPasteScript(format := "claude-path") {
    outputDir := A_Temp "\clipboard-image-paste"
    helperPath := EnvGet("LOCALAPPDATA") "\ClipboardImagePaste\clipboard-image-save.exe"
    quote := Chr(34)

    if FileExist(helperPath) {
        command := quote helperPath quote " --output-dir " quote outputDir quote " --format " format
    } else {
        scriptPath := A_ScriptDir "\paste-clipboard-image.ps1"
        command := "powershell.exe -NoProfile -Sta -ExecutionPolicy Bypass -File " quote scriptPath quote " -OutputDir " quote outputDir quote " -Format " format
    }

    RunWait command,, "Hide"
}

ConvertClipboardImage() {
    RunPasteScript("claude-path")
}
