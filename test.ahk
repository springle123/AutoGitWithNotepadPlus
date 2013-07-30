#singleinstance force

git_commit()

return



git_commit()
{
	WinGetTitle, title, ahk_class Notepad++
	StringTrimRight, filePath, title, 12
	RegExMatch(title, "U)[^\\]*(?=\s)", fileName)
	RegExMatch(filePath, "\..*\b", fileType)
	StringTrimLeft, fileType, fileType, 1, 1
	if(fileType = "ahk" || fileType = "AHK")
	{
		RegExMatch(filePath, "(\\[^\\]*)\.(ahk|AHK)", subpat)
		folder := "F:\GitCode\ahk"
		folder .= subpat1
		;msgbox, %folder%
		if(FileExist(folder))
		{
			gitFolder := folder . "\.git"
			if(!FileExist(gitFolder))
			{
				msgbox, 4, , 当前git目录下文件夹未加入git资料库管理， 是否加入？
				ifmsgbox, yes
					git_init(folder)
				else
					return			
			}
			sleep,100
			filecopy, %filePath%, %folder%, 1
			if(ErrorLevel != 0)
			{
				msgbox, 复制文件失败！
				return
			}
			;msgbox,%folder%
			Output := StdoutToVar_CreateProcess("git add " . fileName, "", folder)
			msgbox, %Output%
			sleep, 100
			Output := StdoutToVar_CreateProcess("git commit -m ""first commit""", "", folder)
			msgbox, %Output%
		}
		else
		{
			msgbox, 4, , 当前文件未加入gitgub资料库管理， 是否加入？
			ifmsgbox, yes
			{
				FileCreateDir, %folder%
				sleep, 100
				git_init(folder)
			}
			;to be continued
		}
	}
	else
	{
		msgbox, 当前编辑文件类型未设置github同步！
		return
	}
}

git_init(folder)
{
	Output := StdoutToVar_CreateProcess("git init", "", folder)
	msgbox, %Output%
	ifnotinstring, Output, Initialized empty Git repository
	{
		msgbox, git init 命令失败 ! 请检查文件夹参数是否正确。
		return
	}
	else
		traytip, , 初始化成功！
	
}


StdoutToVar_CreateProcess(sCmd, bStream="", sDir="", sInput="")
{

   bStream=   ; not implemented

   

   DllCall("CreatePipe","Ptr*",hStdInRd,"Ptr*",hStdInWr,"Uint",0,"Uint",0)

   DllCall("CreatePipe","Ptr*",hStdOutRd,"Ptr*",hStdOutWr,"Uint",0,"Uint",0)

   DllCall("SetHandleInformation","Ptr",hStdInRd,"Uint",1,"Uint",1)

   DllCall("SetHandleInformation","Ptr",hStdOutWr,"Uint",1,"Uint",1)

   if A_PtrSize=4

      {

      VarSetCapacity(pi, 16, 0)

      sisize:=VarSetCapacity(si,68,0)

      NumPut(sisize,    si,  0, "UInt")

      NumPut(0x100,     si, 44, "UInt")

      NumPut(hStdInRd , si, 56, "Ptr")

      NumPut(hStdOutWr, si, 60, "Ptr")

      NumPut(hStdOutWr, si, 64, "Ptr")

      }

   else if A_PtrSize=8

      {

      VarSetCapacity(pi, 24, 0)

      sisize:=VarSetCapacity(si,96,0)

      NumPut(sisize,    si,  0, "UInt")

      NumPut(0x100,     si, 60, "UInt")

      NumPut(hStdInRd , si, 80, "Ptr")

      NumPut(hStdOutWr, si, 88, "Ptr")

      NumPut(hStdOutWr, si, 96, "Ptr")

      }



   DllCall("CreateProcess", "Uint", 0, "Ptr", &sCmd, "Uint", 0, "Uint", 0, "Int", True, "Uint", 0x08000000, "Uint", 0, "Ptr", sDir ? &sDir : 0, "Ptr", &si, "Ptr", &pi)

   DllCall("CloseHandle","Ptr",NumGet(pi,0))

   DllCall("CloseHandle","Ptr",NumGet(pi,A_PtrSize))

   DllCall("CloseHandle","Ptr",hStdOutWr)

   DllCall("CloseHandle","Ptr",hStdInRd)

   

   If   sInput <>

      FileOpen(hStdInWr, "h", "UTF-8").Write(sInput)

   

   DllCall("CloseHandle","Ptr",hStdInWr)



   VarSetCapacity(sTemp,4095)

   nSize:=0

   loop

      {

      result:=DllCall("Kernel32.dll\ReadFile", "Uint", hStdOutRd,  "Ptr", &sTemp, "Uint", 4095,"UintP", nSize,"Uint", 0)

      if (result="0")

         break

      else

         sOutput:= sOutput . StrGet(&sTemp,nSize,"cp936")

      }



   DllCall("CloseHandle","Ptr",hStdOutRd)

   Return,sOutput

}