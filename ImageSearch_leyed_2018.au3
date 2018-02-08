#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_type=a3x
#AutoIt3Wrapper_Compile_Both=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include-once
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>


#Region When running compiled/script, Install needed DLLs if they don't exist yet
If Not FileExists("Ressources/dlls") Then DirCreate("Ressources\dlls")
If Not FileExists("Ressources/dlls/ImageSearchDLLx32.dll") Then FileInstall("Ressources/dlls/ImageSearchDLLx32.dll", "Ressources/dlls/ImageSearchDLLx32.dll", 1);FileInstall ( "source", "dest" [, flag = 0] )
If Not FileExists("Ressources/dlls/ImageSearchDLLx64.dll") Then FileInstall("Ressources/dlls/ImageSearchDLLx64.dll", "Ressources/dlls/ImageSearchDLLx64.dll", 1)
If Not FileExists("Ressources/dlls/msvcr110d.dll") Then FileInstall("Ressources/dlls/msvcr110d.dll", "Ressources/dlls/msvcr110d.dll", 1);Microsoft Visual C++ Redistributable dll x64
If Not FileExists("Ressources/dlls/msvcr110.dll") Then FileInstall("Ressources/dlls/msvcr110.dll", "Ressources/dlls/msvcr110.dll", 1);Microsoft Visual C++ Redistributable dll x32
#EndRegion/

Local $h_ImageSearchDLL = -1; Will become Handle returned by DllOpen() that will be referenced in the _ImageSearchRegion() function

#Region ImageSearch Startup/Shutdown
Func _ImageSearchStartup()
	$sOSArch = @OSArch ;Check if running on x64 or x32 Windows ;@OSArch Returns one of the following: "X86", "IA64", "X64" - this is the architecture type of the currently running operating system.
	$sAutoItX64 = @AutoItX64 ;Check if using x64 AutoIt ;@AutoItX64 Returns 1 if the script is running under the native x64 version of AutoIt.
	If $sOSArch = "X86" Or $sAutoItX64 = 0 Then
		cr("+>" & "@OSArch=" & $sOSArch & @TAB & "@AutoItX64=" & $sAutoItX64 & @TAB & "therefore using x32 ImageSearch DLL")
		$h_ImageSearchDLL = DllOpen("Ressources/dlls/ImageSearchDLLx32.dll")
		If $h_ImageSearchDLL = -1 Then Return "DllOpen failure"
	ElseIf $sOSArch = "X64" And $sAutoItX64 = 1 Then
		cr("+>" & "@OSArch=" & $sOSArch & @TAB & "@AutoItX64=" & $sAutoItX64 & @TAB & "therefore using x64 ImageSearch DLL")
		$h_ImageSearchDLL = DllOpen("Ressources/dlls/ImageSearchDLLx64.dll")
		If $h_ImageSearchDLL = -1 Then	Return "DllOpen failure"
	Else
		Return "Inconsistent or incompatible Script/Windows/CPU Architecture"
	EndIf
	Return True
EndFunc   ;==>_ImageSearchStartup

Func _ImageSearchShutdown()
	DllClose($h_ImageSearchDLL)
	cr(">" & "_ImageSearchShutdown() completed")
	Return True
EndFunc   ;==>_ImageSearchShutdown
#EndRegion ImageSearch Startup/Shutdown

#Region ImageSearch UDF;slightly modified

;===============================================================================
;
; Description:      Wait for a specified number of seconds for any of a set of images to appear in a given area
; Syntax:           _ImageSearch, _ImageSearchArea, _WaitForImageSearch, _WaitForImagesSearch, _WaitForImageSearchArea, _WaitForImagesSearchArea
; Parameter(s):
;                   $findImages - the image(s) to locate on the desktop
;								can be a single image address or a array 
;								containning the amount of images inthe [0] 
;								position and the set of images in the subsequent positions
;					$waitMilis - The amount of Miliseconds to wait for the images
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $transparency - TRANSBLACK, TRANSWHITE or hex value (e.g. 0xffffff) of
;                                  the color to be used as transparency; can be omitted if
;                                  not needed ff00ff
;
; Return Value(s):  On Success - Returns True
;                   On Failure - Returns False
;
; Note: Use _ImageSearch to search the entire desktop, _ImageSearchArea to specify
;       a desktop region to search
;============================================================================================================================================================================================
Func _WaitForImagesSearchArea($findImages,$waitMilis, $left, $top, $right, $bottom, $resultPosition = 1, $tolerance = 0, $transparency = 0)
	If Not IsArray($findImages) Then
	    Dim $findImage[1]
        Dim $Results[1][2]
        $findImage[0] = $findImages
	Else
        Dim $Results[Ubound($findImages)][2]
	    Dim $findImage[Ubound($findImages)]
        $findImage = $findImages
	EndIf

	If $h_ImageSearchDLL = -1 Then _ImageSearchStartup()
	$startTime = TimerInit()

    ;threat the images strings
    for $i = 0 to Ubound($findImage)-1
        $Results[$i][0] = Null
		If $transparency <> 0 Then $findImage[$i] = "*" & $transparency & " " & $findImage[$i]
		If $tolerance > 0 And $tolerance <= 255 Then $findImage[$i] = "*" & $tolerance & " " & $findImage[$i]
    Next

    ;search for the images

	Do
        $Complete = True
		For $i = 0 To Ubound($findImage)-1
			If $Results[$i][0] = Null Then 
                $result = DllCall($h_ImageSearchDLL, "str", "ImageSearch", "int", $left, "int", $top, "int", $right, "int", $bottom, "str", $findImage[$i])
                If @error Then Return "DllCall Error=" & @error


                $array = StringSplit($result[0], "|")
                If UBound($array) >= 4 Then
                    $Results[$i][0] = $array[2]
                    $Results[$i][1] = $array[3]
                     If $resultPosition = 1 Then
                        $Results[$i][0] = $Results[$i][0] + Int(Number($array[4]) / 2)
                        $Results[$i][1] = $Results[$i][1] + Int(Number($array[5]) / 2)
                    EndIf
                EndIf
            EndIf
            If $Results[$i][0] = Null Then $Complete = False
		Next

	Until TimerDiff($startTime) > $waitMilis Or $Complete
    Return $Results
EndFunc   ;==>_WaitForImagesSearch
#EndRegion ImageSearch UDF;slightly modified
;===============================================================================
;
; Description:      Find the position of an image on the desktop
; Syntax:           _ImageSearch, _ImageSearchArea, _WaitForImageSearch, _WaitForImagesSearch, _WaitForImageSearchArea, _WaitForImagesSearchArea
; Parameter(s):
;                   $findImage - the image to locate on the desktop
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;                   $transparency - TRANSBLACK, TRANSWHITE or hex value (e.g. 0xffffff) of
;                                  the color to be used as transparency; can be omitted if
;                                  not needed ff00ff
;
; Return Value(s):  On Success - Returns True
;                   On Failure - Returns False
;
; Note: Use _ImageSearch to search the entire desktop, _ImageSearchArea to specify
;       a desktop region to search
;============================================================================================================================================================================================
Func _ImageSearch($findImage, $resultPosition = 1, $tolerance = 0, $transparency = 0)																					;OK
	Return _WaitForImagesSearchArea($findImage,0,0,0, @DesktopWidth, @DesktopHeight, $resultPosition, $tolerance, $transparency)
EndFunc   ;==>_ImageSearch

Func _ImageSearchArea($findImage, $left, $top, $right, $bottom, $resultPosition = 1, $tolerance = 0, $transparency = 0);Credits to Sven for the Transparency addition	;OK
	Return _WaitForImagesSearchArea($findImage,0, $left, $top, $right, $bottom, $resultPosition, $tolerance, $transparency)
EndFunc
;============================================================================================================================================================================================
Func _WaitForImageSearch($findImage, $waitSecs, $resultPosition = 1, $tolerance=0, $transparency = 0)
	Return _WaitForImagesSearchArea($findImage,$waitSecs,0,0, @DesktopWidth, @DesktopHeight, $resultPosition , $tolerance, $transparency)
EndFunc   ;==>_WaitForImageSearch

;============================================================================================================================================================================================
#Region My Custom ConsoleWrite/debug Function
Func cr($text = "", $addCR = 1, $printTime = False) ;Print to console
	Static $sToolTip
	If Not @Compiled Then
		If $printTime Then ConsoleWrite(@HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC & " ")
		ConsoleWrite($text)
		If $addCR >= 1 Then ConsoleWrite(@CR)
		If $addCR = 2 Then ConsoleWrite(@CR)
	Else
		If $printTime Then $sToolTip &= @HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC & " "
		$sToolTip &= $text
		If $addCR >= 1 Then $sToolTip &= @CR
		If $addCR = 2 Then $sToolTip &= @CR
		ToolTip($sToolTip)
	EndIf
	Return $text
EndFunc   ;==>cr
#EndRegion My Custom ConsoleWrite/debug Function
;============================================================================================================================================================================================