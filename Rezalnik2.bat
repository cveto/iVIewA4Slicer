:: Navodila: sliko daj v isto datoteko kot je batch.fajl. Samo ena fotka je lahko zraven. Ta jo bo razrezal na vec delov za print.
:: Najvecja stevilka v cmd (int) je lahko 2147483647
:: Brez decimalnih številk

@echo off

:: ----------  INPUT  ----------
:: Za koliko % naj bo velikost manjša od A4 (tezava s tiskanjem do roba).
		::SET /P odrobu=Vnesi velikost v odstotkih (100 je A4, 141 je A3, 71 za A5)
		SET odrobu=100
		echo Velikost bo %odrobu% napram A4.
	
:: Za koliko pik naj se slike prekrivajo
		::SET /P prekrivanje=Vnesi stevilo pikslov za prekrivanje (0 brez prekrivanja)
		SET prekrivanje=0
		echo Prekrivanje bo %prekrivanje% pikslov.

::  !!!!!!!----------  WHERE IS YOUR PROGRAM?  ---------- !!!!!!!!!!!!!!!!!!!!!NEED INPUT 
:: 	Lokacija programa Irfan View
		set iview=C:\Programi\IrfanView				
		set iviewDir=%iview:~0,2%						
		
:: 	Kam naj zapise zacasno datoteko (nepomembno za uporabnika)
		SET IWinfo=%temp%\IWinfo.txt
	
:: 	WHERE ARE WE?- naj bo v isti mapi kot batch fajl. in naj bo samo ena!
		SET img_dir=%~dp0.
		SET img_loc=%img_dir%\test.jpg
		SET img_drive=%CD:~0,2%					


		

		

::------- Pridobivanje informacije o sirini in visini -------
::	!!!!!!!! MUY IMPORTANTE
:: Zapiši zaèano info datoteko od slike, ki je zraven batch fajla. dp0 pove lokacijo, kjer je batch fajl
	%iviewDir%
	cd %iview%
	i_view64.exe %img_loc% /info=%IWinfo%	
::	notepad %IWinfo%
	

	
:: Poisci sirino in visino ter ju shrani v spremenljivki 'width' in 'height'
	for /f "tokens=4,6" %%a IN ('type %IWinfo% ^| find "Image dimensions"') do (set /a width=%%a) & (set /a height=%%b)
	


	
::Definicija za A standard - aspect ratio. 
	set /a pocez=841
	set /a podolgem=1189

::ker nimam decimalnih stevilk, uporabim ta trik (napaka ~1 piksel)
	set /a natancnost=2000

::---POKONCNO
::izracun stevilo pikslov po višini (da bo ratio 841*1189, A pokoncno)
	set /a visina_pokoncno = %podolgem% * %natancnost% / %pocez% * %width%
	set /a visina_pokoncno = %visina_pokoncno% / %natancnost%

::izracun potrebnega DPI-ja, da fotka ravno pride na A4 pokoncno - brez izgub (za A3 je treba to premodificirati - 8.3 je širina v inèih za A4).
	set /a dpi = %width% * 100000
	set /a dpi = %dpi% / 83
	set /a dpi = %dpi% / %odrobu% * 100
	set /a dpi = %dpi% / 10000

	
::---LEZECE
::izracun stevilo pikslov po višini (da bo ratio 841*1189, A lezece)
	set /a visina_lezece = %pocez% * %natancnost% / %podolgem% * %width%
	set /a visina_lezece = %visina_lezece% / %natancnost%

::izracun potrebnega DPI-ja, da fotka ravno pride na A4 lezece 11.7 je višina v inèih za A4).
	set /a dpiL = %width% * 100000
	set /a dpiL = %dpiL% / 117
	set /a dpiL = %dpiL% / %odrobu% * 100
	set /a dpiL = %dpiL% / 10000


:: Make new directory - but where?
		%img_drive%
		cd %img_dir%									
		if not exist Pokoncno mkdir Pokoncno
		if not exist Lezece mkdir Lezece

		echo %visina_lezece%
		echo %dpiL%


:: ---------- CUTTING AND SAVING THE IMAGES ----------
	%iviewDir%
	cd %iview%

	set /a x2 = 0
	:while1
		if %x2% leq %height% (
			set /a x2 = x2 + %visina_lezece% - %prekrivanje%
			i_view64.exe "%img_loc% /crop=(0,%x2%,%width%,%visina_lezece%) /dpi=(%dpiL%,%dpiL%) /convert=Lezece\Lezece_%x2%.jpg"
			echo Lezece_%x2%.jpg naredil.
			goto :while1
    )	
	
	set /a x = 0
	:while2
		if %x% leq %height% (
			set /a x = x + %visina_pokoncno% - %prekrivanje%
			i_view64.exe "%img_loc% /crop=(0,%x%,%width%,%visina_pokoncno%) /dpi=(%dpi%,%dpi%) /convert=Pokoncno\Pokoncno_%x%.jpg"
			echo Pokoncno_%x%.jpg naredil.
			goto :while2
    )


:: ---------- DELETE THE TEMPORARY FILE IF EXISTS ----------
::	if exist %IWinfo% del %IWinfo%
	
::pause
:: ---------- GO BACK TO WHERE WE STARTED ----------
%img_drive%
 cd %img_dir%