#Requires AutoHotkey >=2.0
#SingleInstance
Persistent()
^+p::
{
send("{rbutton}")
sleep(150)
send("{w down}")
send("{rbutton}")
send("{w}")
}