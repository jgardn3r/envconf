#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

CapsLock:: ; CapsLock
+CapsLock:: ; Shift+CapsLock
!CapsLock:: ; Alt+CapsLock
^CapsLock:: ; Ctrl+CapsLock
#CapsLock:: ; Win+CapsLock
^!CapsLock:: ; Ctrl+Alt+CapsLock
^!#CapsLock:: ; Ctrl+Alt+Win+CapsLock
SetCapsLockState Off
return ; Do nothing, return


CapsLock & Q::!
CapsLock & W::@
CapsLock & E::#
CapsLock & R::$
CapsLock & T::Send, `%
CapsLock & Y::^
CapsLock & U::&
CapsLock & I::*
CapsLock & O::-
CapsLock & P::=
CapsLock & A::<
CapsLock & S::{
CapsLock & D::[
CapsLock & F::(
CapsLock & G::/
CapsLock & H::\
CapsLock & J::)
CapsLock & K::]
CapsLock & L::}
CapsLock & `;::>
CapsLock & V::|
CapsLock & B::_
CapsLock & N::+

CapsLock & =::Send `:=

^Backspace:: Send ^+{Left}{Backspace}

Shift::
  Send {Shift down}
  SetCapsLockState Off
  KeyWait, Shift
  Send {Shift up}
return