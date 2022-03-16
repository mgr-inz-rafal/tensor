@ECHO OFF

echo Compressing fonts...
del fonts\*.kloc 2>NUL
setlocal enabledelayedexpansion
for %%f in (fonts\*.*) do (
  set /p val=<%%f
  tools\zx5.exe -f %%f %%f.kloc 2>&1 >NUL
)
echo DONE
echo=

echo Compressing maps...
del maps\*.kloc 2>NUL
setlocal enabledelayedexpansion
for %%f in (maps\*.*) do (
  set /p val=<%%f
  tools\zx5.exe -f %%f %%f.kloc 2>&1 >NUL
)
echo DONE
echo=

echo Compressing PMG data...
tools\zx5.exe -f data\decoration.pmg data\decoration.pmg.kloc 2>&1 >NUL
echo DONE
echo=

echo Compiling level names
tools\mads.exe data\level_names.asm -b:0000 -o:data\level_names.obx
tools\mads.exe data\level_names_en.asm -b:0000 -o:data\level_names_en.obx
echo DONE
echo=

echo Stripping level name binaries
tools\strip_header.exe data\level_names.obx
tools\strip_header.exe data\level_names_en.obx
echo DONE
echo=

echo Compressing Level Names...
tools\zx5.exe -f data\level_names.obx data\level_names.obx.kloc 2>&1 >NUL
tools\zx5.exe -f data\level_names_en.obx data\level_names_en.obx.kloc 2>&1 >NUL
echo DONE
echo=

echo Building Datamatrix
tools\mads.exe datamatrix.asx -o:datamatrix.xex -l:datamatrix.lst -t:datamatrix.lab
echo Done
echo=

echo Stripping datamatrix binary
tools\strip_header.exe datamatrix.xex
echo DONE
echo=

echo Compressing Datamatrix...
tools\zx5.exe -f datamatrix.xex datamatrix.kloc 2>&1 >NUL
echo DONE
echo=

echo Building Tensor...
tools\mads.exe tensor.asm -o:tensor.xex -l:tensor.lst -t:tensor.lab
echo Done

echo Building Title Screen...
cd intro
..\tools\mads.exe title_1.asm -o:title_1.xex -l:title_1.lst -t:title_1.lab
cd ..
echo Done