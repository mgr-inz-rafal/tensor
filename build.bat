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

echo Building Tensor...

tools\mads.exe tensor.asm -o:tensor.xex -l:tensor.lst -t:tensor.lab

echo Done