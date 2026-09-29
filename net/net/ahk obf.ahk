#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , H
SetBatchLines, -1

if !A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

global _p0 := "RobloxPlayerBeta.exe"
global _k1 := "G"
global _k2 := "z"

DllCall("winmm\timeBeginPeriod", "UInt", 1)

Hotkey, ~*%_k1%, __g
return

__g:
    if !WinActive("ahk_exe " . _p0)
        return

    WinGet, _id, PID, ahk_exe %_p0%
    if !_id
        return

    Send, {%_k2% down}
    DllCall("Sleep", "UInt", 10)
    Send, {%_k2% up}

    _h := DllCall("OpenProcess", "UInt", 0x1F0FFF, "Int", 0, "Int", _id)
    if !_h
        return

    _t := A_TickCount

    loop
    {
        DllCall("ntdll.dll\NtSuspendProcess", "Int", _h)
        DllCall("Sleep", "UInt", 30)

        DllCall("ntdll.dll\NtResumeProcess", "Int", _h)
        DllCall("Sleep", "UInt", 5)

        if (A_TickCount - _t > 500)
            break
    }

    DllCall("CloseHandle", "Int", _h)

    KeyWait, %_k1%
return

F10::
    DllCall("winmm\timeEndPeriod", "UInt", 1)
    ExitApp