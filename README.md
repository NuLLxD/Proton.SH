# Proton.SH
A shell script created to simplify launching arbitrary executables inside the active Steam proton environment  

Based off work by [chrisgdouglas](https://github.com/chrisgdouglas/cehelper)

## Features
* Automatically detect steam installation.  
* Automatically locate Cheat Engine in the users home directory.  
* Automatically detect proton version.  
* Detect if multiple proton instances are running and allow switching between them.   
* Launch arbitrary executables with custom path.  
* Launch a windows command shell with the working directory being the same as the script.  
* Support for custom proton.  
* If at any point the script fails to do these things it will request user input. 

## Why Proton.SH?
This shell script keeps it incredibly simple and requires very little user input and virtually no configuration. Speed, portability and ease of use.

## Usage
1. Clone the repo or download the script.
2. Install Cheat Engine in your home directory (eg. ~/Cheat Engine 7.5)
3. Open terminal and browse to your script directory.  
4. Give the script execute permissions  
```chmod +x proton.sh```  
5. Run the script  
```./proton.sh```
![image](https://github.com/user-attachments/assets/f3f69941-a6c6-4d69-a036-f5fcdb8aa924)





## Alternatives
For more feature fledged and configurable options look into:  
https://github.com/sonic2kk/steamtinkerlaunch  
https://github.com/jcnils/protonhax  
https://github.com/Matoking/protontricks  
