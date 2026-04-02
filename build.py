import sys
import os
import subprocess

# 1. Check if file argument is provided
if len(sys.argv) < 2:
    print("\033[93mOops, looks like you forgot the filename! 😅\033[0m")
    print(f"Try running it like this: {os.path.basename(sys.argv[0])} <filename.asm>")
    sys.exit(1)

file_path = sys.argv[1]

# 2. Check if file exists
if not os.path.isfile(file_path):
    print(f"\033[91mHmm... I can't seem to find '{file_path}'. Are you sure it's in this folder? 🤔\033[0m")
    sys.exit(1)

# Setup variables
file_dir = os.path.dirname(os.path.abspath(file_path))
file_basename = os.path.splitext(os.path.basename(file_path))[0]

obj_file = os.path.join(file_dir, f"{file_basename}.obj")
exe_file = os.path.join(file_dir, f"{file_basename}.exe")

# Global Irvine Paths
irvine_lib = r"C:\irvine\Irvine32.lib"
irvine_inc = r"C:\irvine"

# Tools paths
uasm = r"C:\msys64\mingw64\bin\uasm.exe"
nasm = r"C:\msys64\mingw64\bin\nasm.exe"
gcc32 = r"C:\msys64\mingw32\bin\i686-w64-mingw32-gcc.exe"
gcc64 = r"C:\msys64\mingw64\bin\x86_64-w64-mingw32-gcc.exe"

print("\033[96mChoose build mode:\033[0m")
print("1) Win32 Irvine (Standard)")
print("2) Win32 Standalone (Standard)")
print("3) Win64 Standalone (Standard)")
print("4) Win32 Irvine (Custom main)")
print("5) Win32 Standalone (Custom main)")
print("6) Win64 Standalone (Custom main)")

opt = input("Option: ")

def run_cmd(cmd):
    """Helper function to run shell commands and return True if successful"""
    result = subprocess.run(cmd, shell=True)
    return result.returncode == 0

# Match options
if opt == '1':
    if run_cmd(f'"{uasm}" -q -coff -I"{irvine_inc}" -Fo"{obj_file}" "{file_path}"'):
        if run_cmd(f'"{gcc32}" "{obj_file}" "{irvine_lib}" -o "{exe_file}" -nostdlib -lkernel32 -luser32 -w -Wl,--subsystem,console'):
            run_cmd(f'"{exe_file}"')

elif opt == '2':
    if run_cmd(f'"{nasm}" -f win32 "{file_path}" -o "{obj_file}"'):
        if run_cmd(f'"{gcc32}" "{obj_file}" -o "{exe_file}" -nostartfiles -lkernel32 -luser32'):
            run_cmd(f'"{exe_file}"')

elif opt == '3':
    if run_cmd(f'"{nasm}" -f win64 "{file_path}" -o "{obj_file}"'):
        if run_cmd(f'"{gcc64}" "{obj_file}" -o "{exe_file}" -nostartfiles -lkernel32 -luser32'):
            run_cmd(f'"{exe_file}"')

elif opt == '4':
    if run_cmd(f'"{uasm}" -q -coff -I"{irvine_inc}" -Fo"{obj_file}" "{file_path}"'):
        if run_cmd(f'"{gcc32}" "{obj_file}" "{irvine_lib}" -o "{exe_file}" -nostdlib -lkernel32 -luser32 -w -Wl,-e_main -Wl,--subsystem,console -Wl,--enable-stdcall-fixup'):
            run_cmd(f'"{exe_file}"')

elif opt == '5':
    if run_cmd(f'"{nasm}" -f win32 "{file_path}" -o "{obj_file}"'):
        if run_cmd(f'"{gcc32}" "{obj_file}" -o "{exe_file}" -nostartfiles -lkernel32 -luser32 -Wl,-e_main'):
            run_cmd(f'"{exe_file}"')

elif opt == '6':
    if run_cmd(f'"{nasm}" -f win64 "{file_path}" -o "{obj_file}"'):
        if run_cmd(f'"{gcc64}" "{obj_file}" -o "{exe_file}" -nostartfiles -lkernel32 -luser32 -Wl,-emain'):
            run_cmd(f'"{exe_file}"')

else:
    print("\033[93mWhoops, that's not on the menu! Try picking a number from 1 to 6 next time. 😉\033[0m")
    sys.exit(1)