@ECHO OFF

echo Compressing data...
del fonts\*.kloc 2>NUL
setlocal enabledelayedexpansion
for %%f in (fonts\*.*) do (
  set /p val=<%%f
  tools\zx5.exe -f %%f %%f.kloc 2>&1 >NUL
)
echo DONE
echo=

echo Building Tensor...

mads.exe tensor.asm -o:tensor.xex -l:tensor.lst -t:tensor.lab

echo Done