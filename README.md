# MCSimViaMSVC
Build [GNU MCSim](https://www.gnu.org/software/mcsim/) models on Windows using the Microsoft C compiler.

## Installation

Skip steps 1-3 if your system already has Microsoft Visual Studio 2019 installed (including the C/C++ build tools). 

1. Install [Chocolatey](https://chocolatey.org/docs/installation).

2. Install [Visual Studio 2019 Build Tools](https://chocolatey.org/packages/visualstudio2019buildtools).

3. Install [Visual C++ build tools workload for Visual Studio 2019 Build Tools](https://chocolatey.org/packages/visualstudio2019-workload-vctools).

4. Download this repo and unzip to ```Documents``` (```My Documents``` on older Windows systems).

5. Rename the directory (remove the ```-master``` suffix).

## Test

Follow these steps to test the build environment using the [butadiene](http://cvs.savannah.gnu.org/viewvc/mcsim/mcsim/examples/butadiene/) example model provided:

1. Start a command prompt and change directory to ```Documents\MCSimViaMSVC```.

2. Execute the build batch file:

  ``` 
  C:\Users\...\Documents\MCSimViaMSVC>model2exe.bat
  ```

3. Test the resulting executable:

  ```
  C:\Users\...\Documents\MCSimViaMSVC>.\out\butadiene.exe .\target\butadiene.in .\out\butadiene.out
  ```

## Build A Model

Either use the target directory:

1. Drop a ```.model``` file into the ```target``` directory.

2. Run ```model2exe.bat```.

or specify your ```.model``` file as an argument to ```model2exe.bat```:

    model2exe.bat <path to .model file>

In the former case, the resulting executable will be created in the ```out``` folder. In the latter case, the resulting executable will be created in the same directory as the ```.model``` file.
