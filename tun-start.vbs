Set objShell = CreateObject("Shell.Application")
Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

scriptPath = fso.GetParentFolderName(WScript.ScriptFullName)

exePath = """" & scriptPath & "\app\sing-box.exe"""
configPath = """" & scriptPath & "\list\config.json"""
arguments = "run -c " & configPath

objShell.ShellExecute exePath, arguments, "", "runas", 0
