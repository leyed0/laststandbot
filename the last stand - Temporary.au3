#include<ImageSearch2015.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Color.au3>

;setup inicial - variaveis
Dim $Icon[20],$InvPos[2], $InvSz[2], $DepFull[4], $IgnoreStock[3]
Global $tmx=0,$tmy=0, $Line=0,$GameFound=False,$Exit = False,$Activated = False, $GUI = False, $RecycleAll=False
Opt("WinTitleMatchMode", 2)     ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
GUICreate("Teste", 100,100,@DesktopWidth-150,@DesktopHeight-150,BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD), $WS_EX_TOPMOST)
$Splash = "icons/splash.jpg"
$Icon[0]="icons/1.bmp"
$Icon[1]="icons/2.bmp"
$Icon[2]="icons/3.bmp"
$Icon[3]="icons/4.bmp"
$Icon[4]="icons/5.bmp"
$Icon[5]="icons/6.bmp"
$Icon[6]="icons/7.bmp"
$Icon[7]="icons/8.bmp"
$Icon[8]="icons/9.bmp"
$Icon[9]="icons/10.bmp"
$Icon[10]="icons/11.bmp"
$Icon[11]="icons/12.bmp"
$Icon[12]="icons/13.bmp"
$Icon[13]="icons/14.bmp"
$Icon[14]="icons/15.bmp"
$Icon[15]="icons/16.bmp"

;0=icone do jogo	1=botao maximizar	2=borda fora do fullscreen	3=icone inventario	4=borda supesq inventario	5=borda infdir inventario 32x30	6=bot�o fecha	7=Chrome pentelho
;8=IronFull	9=ClothFull	10=WoodFull	11=EmptySpace	12=recycling...	13 = Recycle button	14=Cancelar	15=Confirmar

;teclas atalho
HotKeySet("{numpad0}", "Close")
HotKeySet("{numpad1}", "Activate")
HotKeySet("{numpad2}", "Deactivate")
HotKeySet("{numpad3}", "ToogleGUI")
HotKeySet("{numpad5}", "RecycleAll")
HotKeySet("{UP}", "NextLine")
HotKeySet("{DOWN}", "PreviousLine")
;fim do setup

;processo 1 (splash)
SplashImageOn("The last stand",$Splash,300,143)
	Sleep(2000)
SplashOff()
Call(Setup())
While 1 And Not $Exit==True
	If $Activated And _ImageSearch($Icon[4], 1, $tmx, $tmy, 1) = True Then MouseMove($InvPos[0]+$InvSz[0], $InvPos[1]+$InvSz[1]*(0.2+(0.15*$Line)))
	If $RecycleAll Then Call("RecycleAll")
WEnd

Func Setup()
	Local $tx=0, $ty=0, $Search=False
	If WinActivate("The Last Stand: Dead Zone") == 0 Then	;procura janela do jogo
		If _ImageSearch($Icon[0], 1, $tx, $ty, 1) = False Then ;procura icone do jogo
			MsgBox(4096,"ERRO!","A janela do jogo n�o foi encontrada!")
		Else
			MouseClick("left", $tx, $ty, 1,0)	;se o icone foi encontrado, clicka nele
			$GameFound = True
		EndIf
	Else
		$GameFound=True
	EndIf
	If _WaitForImageSearch($Icon[2],100, 1, $tx, $ty, 1) Then
		_WaitForImageSearch($Icon[1], 10, 1, $tx, $ty, 1)	;clicka fullscreen
		MouseClick("left", $tx,$ty,1,0)
	EndIf
	If _WaitForImageSearch($Icon[7],5, 1, $tx, $ty, 1) = True Then
		MouseClick("left", $tx,$ty,1,0)
	EndIf
	;_WaitForImageSearch($Icon[3], 10, 1, $tx, $ty, 1)	;procura imagem do inventario
	;MouseClick("left", $tx,$ty,1,0)						;clicka nela
	;Call("SetInv")
	;_WaitForImageSearch($Icon[6], 10, 1,$tx, $ty, 1)	;close button
	;MouseClick("left", $tx,$ty,1,0)
	Call("SetInv")
EndFunc

Func VerifDeposit()
	Local $tx=$InvPos[0]+$InvSz[0]*(0.255+(0.095*1)), $ty=$InvPos[1]+$InvSz[1]*(0.2+(0.15*1))
	If _ImageSearchArea($Icon[8], 1, $InvPos[0], $InvPos[1], $InvPos[0]+$InvSz[0],$InvPos[1]+$InvSz[1],   $tx, $ty, 1) Then
		$DepFull[0]=True
	Else
		$DepFull[0]=False
	EndIf
	If _ImageSearchArea($Icon[9], 1, $InvPos[0], $InvPos[1], $InvPos[0]+$InvSz[0],$InvPos[1]+$InvSz[1],   $tx, $ty, 1) Then
		$DepFull[1]=True
	Else
		$DepFull[1]=False
	EndIf
	If _ImageSearchArea($Icon[10], 1, $InvPos[0], $InvPos[1], $InvPos[0]+$InvSz[0],$InvPos[1]+$InvSz[1],   $tx, $ty, 1) Then
		$DepFull[2]=True
	Else
		$DepFull[2]=False
	EndIf
	If _ImageSearchArea($Icon[11], 1, $InvPos[0], $InvPos[1], $tx,$ty, $tx, $ty, 1) Then
		$DepFull[3]=False
	Else
		$DepFull[3]=True; indica se primeiro bloco esta vazio
	EndIf
EndFunc

Func KeyPressed()
	If $Activated Then
		If Not Recycle(@HotKeyPressed, $Line) Then MsgBox(4096, "", "n�o h� itens nessa posi��o")
	EndIf
EndFunc

Func Recycle2($Px, $Py)
	Local $tmx=$Px, $tmy=$Py, $return=False
	Call("VerifDeposit")
	If $DepFull[3] Then
		$Px = $InvPos[0]+$InvSz[0]*(0.255+(0.095*$Px))
		$Py = $InvPos[1]+$InvSz[1]*(0.2+(0.15*$Py))
		MouseClick("left", $Px, $Py,1,0)
		$Px = Int($InvPos[0]+$InvSz[0]*(0.304+(0.097*$tmx)))
		$Py = Int($InvPos[1]+$InvSz[1]*(0.17+(0.15*$tmy)))
		MouseClick("left", $Px, $Py, 1, 0)
		$Py = $InvPos[1]+$InvSz[1] *0.64
		If Not $DepFull[0] And Not $DepFull[1] And Not $DepFull[2] Then
			$Px = Int($InvPos[0]+$InvSz[0]*0.61)	;confirma
			$return = True
		Else
			$Px = Int($InvPos[0]+$InvSz[0]*0.41)	;cancela
		EndIf
			MouseClick("left", $Px, $Py,1,0)		;clicka
	;While _ImageSearchArea($Icon[8], 1, $InvPos[0], $InvPos[1], $InvPos[0]+$InvSz[0],$InvPos[1]+$InvSz[1],   $tmx, $tmy, 1)
	_WaitForImageSearch($Icon[12],10,1,$tmx,$tmy, 1)
	While _ImageSearch($Icon[12],1,$tmx,$tmy, 1)
		Sleep(1)
	WEnd
	EndIf
	Return $return
EndFunc

Func Recycle($Px, $Py)
	Local $return=False
	Call("VerifDeposit")
	If $DepFull[3] Then
		$Px = $InvPos[0]+$InvSz[0]*(0.255+(0.095*$Px))
		$Py = $InvPos[1]+$InvSz[1]*(0.2+(0.15*$Py))
		MouseClick("left", $Px, $Py,1,3)			;clicka no item
		_WaitForImageSearch($Icon[13],10,1,$Px,$Py, 1)
		;_ImageSearch($Icon[13],1,$Px,$Py, 1)
		MouseClick("left", $Px, $Py, 1, 0)			;clicka no reciclar
		Call("VerifDeposit")
		If Not $DepFull[0] And Not $DepFull[1] And Not $DepFull[2] Then
			_WaitForImageSearch($Icon[15],10,1,$Px,$Py, 1) 	;confirma
			;_ImageSearch($Icon[15],1,$Px,$Py, 1) 	;confirma
			$return = True
		Else
			_WaitForImageSearch($Icon[14],10,1,$Px,$Py, 1) 	;cancela
			;_ImageSearch($Icon[14],1,$Px,$Py, 1) 	;cancela
		EndIf
		MouseClick("left", $Px, $Py,1,0)		;clicka
		_WaitForImageSearch($Icon[12],10,1,$Px,$Py, 1)
		While _ImageSearch($Icon[12],1,$Px,$Py, 1)
			Sleep(1)
		WEnd
	EndIf
	Return $return
EndFunc

Func RecycleALl()
	Local $i=1,$j=0, $tx=1, $ty=0, $tmx=0, $tmy=0
	While Not $DepFull[0] And Not $DepFull[1] And Not $DepFull[2] And $Activated
		If Not Recycle($i,$j) Then
			$i+=1
			If $i=8 Then
				$i=1
				$j+=1
			EndIf
			If Not $DepFull[3] Then ExitLoop
		EndIf
	WEnd
EndFunc
;fun��es principais
Func Activate ()
	beep (600,200)
	Call("SetInv")
	For $i = 1 To 7 Step 1
		HotKeySet(Chr($i+48), "KeyPressed")
	Next
	$Activated = True
EndFunc

Func Deactivate ()
	beep (400,200)
	$Activated = False
EndFunc

Func Close ()
	beep(200,200)
	$Exit=True
	Exit
EndFunc

Func NextLine()
	$Line-=1
	If $Line < 0 Then $Line=4
EndFunc

Func PreviousLine()
	$Line+=1
	If $Line > 4 Then $Line=0
EndFunc


Func SetInv()
	Local $tx=0,$ty=0
	_WaitForImageSearch($Icon[4], 10, 0, $InvPos[0], $InvPos[1], 1)	;ponta superior esquerda do inventario
	_ImageSearch($Icon[5], 0, $InvSz[0], $InvSz[1], 1);22x26 inferior direita
	_ImageSearchArea($Icon[5], 0, $InvPos[0], $InvPos[1], @DesktopWidth, @DesktopHeight, $InvSz[0], $InvSz[1], 1);22x26 inferior direita
	$InvSz[0] += 22
	$InvSz[1] += 26
	$InvSz[0]=$InvSz[0]-$InvPos[0]
	$InvSz[1]=$InvSz[1]-$InvPos[1]
EndFunc

Func ToogleGUI()
	If $GUI Then
		GUISetState(@SW_HIDE)
	Else
		GUISetState(@SW_SHOW)
	EndIf
	$GUI = Not $GUI
EndFunc