# Special instruction to download and setup AMD AOCC:
# Commands:

# Set your OpenMC working directory here:
export OMCDIR=$SCRATCH/omc
mkdir -p $OMCDIR
cd $OMCDIR

wget https://download.amd.com/developer/eula/aocc/aocc-5-0/aocc-compiler-5.0.0.tar
tar xvf aocc-compiler-5.0.0.tar
rm aocc-compiler-5.0.0.tar
cd aocc-compiler-5.0.0
bash install.sh
source ../setenv_AOCC.sh

# The file setenv_AOCC.sh will be located in $OMCDIR, one level up from aocc-compiler-5.0.0 extracted directory

# Then, need to create config file for each clang compiler to add --gcc-install-dir to the correct path of the current gcc's lib/gcc/x86_64*/*, similar to the way easybuild handle AOCC easyblock here:
#https://github.com/easybuilders/easybuild-easyblocks/blob/4889a405c91548f11856344aba4a45e0476afd6f/easybuild/easyblocks/a/aocc.py
# Otherwise, clang will use the default gcc compiler come preinstalled in the system, which is usually heavily outdated

#That is, generate clang.cfg, clang++.cfg, and clang-cpp.cfg (and flang.cfg if AOCC<5) with the following content:
#--gcc-install-dir=/path/to/lib/gcc/x86_64*/*
# And put those .cfg files in the same directory with "clang", "clang++", and "flang" executables (usually aocc-compiler-5.0.0/bin)

# For Launch, ACES, and Dell POC, I built AMD AOCC using Easybuild so no need for any of these. Simply load AOCC/5.0.

# For STAMPEDE3: (if loading module gcc/15.1.0)
#--gcc-install-dir=/opt/apps/gcc/15.1.0/lib/gcc/x86_64-pc-linux-gnu/15.1.0

# For ANVIL: (if loading module gcc/14.2.0)
#--gcc-install-dir=/apps/spack/anvil-cpu-2025/apps/gcc/14.2.0-gcc-8.4.0-bhapg6a/lib/gcc/x86_64-pc-linux-gnu/14.2.0

# For DELTA: (the sysadmins prefer us to use the default gcc toolset)
#--gcc-install-dir=/opt/rh/gcc-toolset-13/root/lib/gcc/x86_64-redhat-linux/13
