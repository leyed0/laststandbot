#include <Array.au3>
#include "ImageSearch_leyed_2018.au3"
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Color.au3>
#include <Misc.au3>

Opt("WinTitleMatchMode", 2)     ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
Dim $Icon[20]
Dim $resultado
Dim $IsRunning = True, $IsRecicle = False

$Icon[0]="Ressources/icons/1.bmp"       ;game icon
$Icon[1]="Ressources/icons/2.bmp"       
$Icon[2]="Ressources/icons/3.bmp"       
$Icon[3]="Ressources/icons/4.bmp"       
$Icon[4]="Ressources/icons/5.bmp"       
$Icon[5]="Ressources/icons/6.bmp"       
$Icon[6]="Ressources/icons/7.bmp"       
$Icon[7]="Ressources/icons/8.bmp"       
$Icon[8]="Ressources/icons/9.bmp"       
$Icon[9]="Ressources/icons/10.bmp"      
$Icon[10]="Ressources/icons/11.bmp"     
$Icon[11]="Ressources/icons/12.bmp"     
$Icon[12]="Ressources/icons/13.bmp"     
$Icon[13]="Ressources/icons/14.bmp"     
$Icon[14]="Ressources/icons/15.bmp"     
$Icon[15]="Ressources/icons/16.bmp"     


;0=icone do jogo	1=botao maximizar	2=borda fora do fullscreen	3=icone inventario	4=borda supesq inventario	5=borda infdir inventario 32x30	6=bot�o fecha	7=Chrome pentelho
;8=IronFull	9=ClothFull	10=WoodFull	11=EmptySpace	12=recycling...	13 = Recycle button	14=Cancelar	15=Confirmar


HotKeySet("{numpad0}", "Close")
HotKeySet("{delete}", "SetReciclaMouse")



WinActivate("The Last Stand: Dead Zone")


While($IsRunning)
    If _IsPressed("02") Then 
        Call("ReciclaMouse")       ;clique direito
        $IsRecicle = False
    EndIf
    If $IsRecicle Then Call("ReciclaMouse")
WEnd


Func SetReciclaMouse()
    $IsRecicle = Not $IsRecicle
EndFunc

Func Close()
    $IsRunning = False
EndFunc

Func ReciclaMouse()
	$startTime = TimerInit()
    $x = MouseGetPos(0)
    $y = MouseGetPos(1)
    Do      ;========================================================================
        MouseMove($x+Random(-5,5),$y+Random(-5,5),0)
        MouseClick("left",$x+Random(-1,1)*3,$y+Random(-1,1)*3,1,0)
        $result = _ImageSearch($Icon[13])
    Until $result[0][0] <> Null or TimerDiff($startTime) > 1000     ;=================

    If $result[0][0] <> Null Then       ;================
        MouseClick("left", $result[0][0],$result[0][1],1,0)

        
        MouseMove(@DesktopWidth, @DesktopHeight,0)
        $result = _WaitForImageSearch($Icon[15], 1000)
        MouseClick("left", $result[0][0],$result[0][1],1,0)


        _WaitForImageSearch($Icon[12], 1000)
        Do
            $result = _ImageSearch($Icon[12])
        Until $result[0][0] = Null

    Else 
    $IsRecicle = False
    EndIf
    MouseMove($x,$y,0)
EndFunc
