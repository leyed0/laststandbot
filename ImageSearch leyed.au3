#AutoIt3Wrapper_UseX64=y ; Set to Y or N depending on your situation/preference!!
#include-once

#Region When running compiled script, Install needed DLLs if they don't exist yet
If Not FileExists("ImageSearchDLLx32.dll") Then FileInstall("ImageSearchDLLx32.dll", "ImageSearchDLLx32.dll", 1);FileInstall ( "source", "dest" [, flag = 0] )
If Not FileExists("ImageSearchDLLx64.dll") Then FileInstall("ImageSearchDLLx64.dll", "ImageSearchDLLx64.dll", 1)
If Not FileExists("msvcr110d.dll") Then FileInstall("msvcr110d.dll", "msvcr110d.dll", 1);Microsoft Visual C++ Redistributable dll x64
If Not FileExists("msvcr110.dll") Then FileInstall("msvcr110.dll", "msvcr110.dll", 1);Microsoft Visual C++ Redistributable dll x32
#EndRegion

Local $h_ImageSearchDLL = -1; Will become Handle returned by DllOpen() that will be referenced in the _ImageSearchRegion() function

#Region ImageSearch Startup/Shutdown
Func _ImageSearchStartup()
	$sOSArch = @OSArch ;Check if running on x64 or x32 Windows ;@OSArch Returns one of the following: "X86", "IA64", "X64" - this is the architecture type of the currently running operating system.
	$sAutoItX64 = @AutoItX64 ;Check if using x64 AutoIt ;@AutoItX64 Returns 1 if the script is running under the native x64 version of AutoIt.
	If $sOSArch = "X86" Or $sAutoItX64 = 0 Then
		cr("+>" & "@OSArch=" & $sOSArch & @TAB & "@AutoItX64=" & $sAutoItX64 & @TAB & "therefore using x32 ImageSearch DLL")
		$h_ImageSearchDLL = DllOpen("/WINDOWS/ImageSearchDLLx32.dll")
		If $h_ImageSearchDLL = -1 Then Return "DllOpen failure"
	ElseIf $sOSArch = "X64" And $sAutoItX64 = 1 Then
		cr("+>" & "@OSArch=" & $sOSArch & @TAB & "@AutoItX64=" & $sAutoItX64 & @TAB & "therefore using x64 ImageSearch DLL")
		$h_ImageSearchDLL = DllOpen("/WINDOWS/ImageSearchDLLx64.dll")
		If $h_ImageSearchDLL = -1 Then Return "DllOpen failure"
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
;					$waitSecs - The amount of seconds to wait for the images
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
Func _WaitForImageSearchArea($findImages,$waitSecs, $resultPosition, $left, $top, $right, $bottom, ByRef $x, ByRef $y, $tolerance = 0, $transparency = 0)
	If Not IsArray($findImages) Then 
		Dim $findImage[2]
		$findImage[0]=1
		$findImage[1]=$findImages
	Else 
		$findImage=$findImages
	EndIf
	If $tolerance < 0 Or $tolerance > 255 Then $tolerance = 0
	If $h_ImageSearchDLL = -1 Then _ImageSearchStartup()
	$waitSecs = $waitSecs * 1000
	$startTime = TimerInit()
	Do
		For $i = 1 To $findImage[0]
			If $transparency <> 0 Then $findImage = "*" & $transparency & " " & $findImage
			If $tolerance > 0 Then $findImage = "*" & $tolerance & " " & $findImage
			;If Not FileExists($findImage[$i]) Then Return "Image ["& $i  &"] File not found"
			$result = DllCall($h_ImageSearchDLL, "str", "ImageSearch", "int", $left, "int", $top, "int", $right, "int", $bottom, "str", $findImage[$i])
			If @error Then Return "DllCall Error=" & @error
		Next
		$array = StringSplit($result[0], "|")
	Until TimerDiff($startTime) >= $waitSecs Or UBound($array) >= 4
	If $result = "0" Or Not IsArray($result) Or $result[0] = "0" Then Return False
	If (UBound($array) >= 4) Then
		$x = Int(Number($array[2])); Get the x,y location of the match
		$y = Int(Number($array[3]))
		If $resultPosition = 1 Then
			$x = $x + Int(Number($array[4]) / 2); Account for the size of the image to compute the centre of search
			$y = $y + Int(Number($array[5]) / 2)
		EndIf
		Return True
	EndIf
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
Func _ImageSearch($findImage, $resultPosition, ByRef $x, ByRef $y, $tolerance=0, $transparency = 0)																					;OK
	Return _WaitForImageSearchArea($findImage,0, $resultPosition,0,0, @DesktopWidth, @DesktopHeight,$x, $y, $tolerance, $transparency)
EndFunc   ;==>_ImageSearch

Func _ImageSearchArea($findImage, $resultPosition, $left, $top, $right, $bottom, ByRef $x, ByRef $y, $tolerance = 0, $transparency = 0);Credits to Sven for the Transparency addition	;OK
	Return _WaitForImageSearchArea($findImage,0, $resultPosition, $left, $top, $right, $bottom,$x, $y, $tolerance, $transparency)
EndFunc
;============================================================================================================================================================================================
Func _WaitForImageSearch($findImage, $waitSecs, $resultPosition, ByRef $x, ByRef $y, $tolerance=0, $transparency = 0)
	Return _WaitForImageSearchArea($findImage,$waitSecs, $resultPosition,0,0, @DesktopWidth, @DesktopHeight,$x, $y, $tolerance, $transparency)
EndFunc   ;==>_WaitForImageSearch
;============================================================================================================================================================================================
;Func _WaitForImagesSearch($findImage, $waitSecs, $resultPosition, ByRef $x, ByRef $y, $tolerance=0, $transparency = 0)
;	Return _WaitForImagesSearchArea($findImage,$waitSecs, $resultPosition,0,0, @DesktopWidth, @DesktopHeight,$x, $y, $tolerance, $transparency)
;EndFunc   ;==>_WaitForImagesSearch
;============================================================================================================================================================================================
;Func _WaitForImageSearchArea($findImage,$waitSecs, $resultPosition, $left, $top, $right, $bottom, ByRef $x, ByRef $y, $tolerance = 0, $transparency = 0)
;	Return _WaitForImagesSearchArea($findImage,0, $resultPosition,0,0, @DesktopWidth, @DesktopHeight,$x, $y, $tolerance, $transparency)
;EndFunc   ;==>_WaitForImageSearchArea
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