# Set your OpenMC working directory here:
export OMCDIR=$SCRATCH/omc
mkdir -p $OMCDIR
cd $OMCDIR

# Load required modules and/or sourcing the toolchain environment setup scripts here:
# Example: for Launch cluster, simply load intel module, with CMake:
ml intel/2025a CMake

# For other clusters without intel module, you will need to manually source intel/AOCC setup scripts, e.g.
# . $OMCDIR/intel/setvars.sh

# Special treatment for a particular HPC:
# - For STAMPEDE3: make sure to load CMake 3.x.x:
#   ml cmake/3.31.9
# - For Anvil: make sure to load newer GCC and curl:
#   ml purge
#   ml gcc/14.2.0 curl cmake

# Next, define a name for a build (e.g. o3_march), and set corresponding build flags
export BUILD_NAME=o3_march
export GCC_BUILD_FLAGS="-O3 -DNDEBUG -march=native -ftree-vectorize"
export BUILD_FLAGS="-O3 -DNDEBUG -march=native -ftree-vectorize"

# Below are set of commands to build OpenMC and its dependencies
# Note that if you copy-and-paste the entire script (or run it all at once), you might need to separate the PETSc configure and build commands. This is because PETSc might interrupt the paste command at the end of its configuration step.

#For Eigen3:
cd $OMCDIR/eigen
mkdir build_$BUILD_NAME
cd build_$BUILD_NAME
CC=mpiicx FC=mpiifx CXX=mpiicpx cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_Fortran_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_CXX_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX=$OMCDIR/eigen/release_$BUILD_NAME
VERBOSE=1 make install

#For HDF5, make sure to use a relatively recent one (not the one recommended by DAGMC)
cd $OMCDIR/hdf5
mkdir build_$BUILD_NAME
cd build_$BUILD_NAME
CC=mpiicx FC=mpiifx CXX=mpiicpx cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_Fortran_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_CXX_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_SHARED_LIBS=ON -DHDF5_ENABLE_PARALLEL=ON -DHDF5_ENABLE_THREADSAFE=ON -DHDF5_BUILD_FORTRAN=ON -DHDF5_BUILD_CPP_LIB=ON -DALLOW_UNSUPPORTED=ON -DCMAKE_INSTALL_PREFIX=$OMCDIR/hdf5/release_$BUILD_NAME
VERBOSE=1 cmake --build . --config Release
VERBOSE=1 make install

#For netCDF:
cd $OMCDIR/netcdf-c
mkdir build_$BUILD_NAME
cd build_$BUILD_NAME
CC=mpiicx CXX=mpiicpx cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_CXX_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DNETCDF_ENABLE_HDF5=ON -DHDF5_ROOT=$OMCDIR/hdf5/release_$BUILD_NAME -DCMAKE_INSTALL_PREFIX=$OMCDIR/netcdf-c/release_$BUILD_NAME
VERBOSE=1 make install

#For MOAB, note that Intel icx and icpx does not work, falling back to GCC equivalent:
cd $OMCDIR/moab
mkdir build_$BUILD_NAME
cd build_$BUILD_NAME
FC=mpiifx cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE="$GCC_BUILD_FLAGS" -DCMAKE_Fortran_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_CXX_FLAGS_RELEASE="$GCC_BUILD_FLAGS" -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DENABLE_MPI=ON -DENABLE_HDF5=ON -DHDF5_ROOT=$OMCDIR/hdf5/release_$BUILD_NAME -DENABLE_NETCDF=ON -DNETCDF_ROOT=$OMCDIR/netcdf-c/release_$BUILD_NAME -DEIGEN3_DIR=$OMCDIR/eigen/release_$BUILD_NAME/include/eigen3 -DCMAKE_INSTALL_PREFIX=$OMCDIR/moab/release_$BUILD_NAME
VERBOSE=1 make install

# For Embree with Internal Tasking:
cd $OMCDIR/embree
mkdir build_$BUILD_NAME
cd build_$BUILD_NAME
CC=mpiicx CXX=mpiicpx cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_CXX_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DEMBREE_TASKING_SYSTEM=INTERNAL -DEMBREE_TUTORIALS=OFF -DEMBREE_IGNORE_CMAKE_CXX_FLAGS=OFF -DEMBREE_MAX_ISA=AVX512 -DCMAKE_INSTALL_PREFIX=$OMCDIR/embree/release_$BUILD_NAME
VERBOSE=1 make install

# For double-down
cd $OMCDIR/double-down
mkdir build_$BUILD_NAME
cd build_$BUILD_NAME
CC=mpiicx CXX=mpiicpx cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_CXX_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DMOAB_DIR=$OMCDIR/moab/release_$BUILD_NAME -DEMBREE_DIR=$OMCDIR/embree/release_$BUILD_NAME -DCMAKE_INSTALL_PREFIX=$OMCDIR/double-down/release_$BUILD_NAME
VERBOSE=1 make install

#For DAGMC:
cd $OMCDIR/DAGMC
mkdir build_$BUILD_NAME
cd build_$BUILD_NAME
CC=mpiicx FC=mpiifx CXX=mpiicpx cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_Fortran_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_CXX_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DMOAB_DIR=$OMCDIR/moab/release_$BUILD_NAME -DBUILD_TALLY=ON -DDOUBLE_DOWN=ON -DDOUBLE_DOWN_DIR=$OMCDIR/double-down/release_$BUILD_NAME -DCMAKE_INSTALL_PREFIX=$OMCDIR/DAGMC/release_$BUILD_NAME
VERBOSE=1 LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OMCDIR/netcdf-c/release_$BUILD_NAME/lib64 make install

#For PETSc:
cd $OMCDIR/petsc
make allclean
./configure --configModules=PETSc.Configure --optionsModule=config.compilerOptions --with-cc=mpiicx --with-fc=mpiifx --with-cxx=mpiicpx --with-blaslapack-dir=$MKLROOT --with-debugging=0 --prefix=$OMCDIR/petsc/release_$BUILD_NAME COPTFLAGS="$BUILD_FLAGS" CXXOPTFLAGS="$BUILD_FLAGS" FOPTFLAGS="$BUILD_FLAGS" PETSC_ARCH=$BUILD_NAME
# At this point, if the build stop right here, copy and paste the rest of the commands below and run them. PETSc might stop the copy-and-paste right at this point.
make PETSC_DIR=$OMCDIR/petsc PETSC_ARCH=$BUILD_NAME all
make PETSC_DIR=$OMCDIR/petsc PETSC_ARCH=$BUILD_NAME install

#For libmesh, make sure to disable eigen and enable petsc:
cd $OMCDIR/libmesh
mkdir build_$BUILD_NAME
cd build_$BUILD_NAME
../configure --enable-mpi --with-cc=mpiicx --with-fc=mpiifx --with-cxx=mpiicpx --with-methods="opt" --enable-march --enable-hdf5 --with-hdf5=$OMCDIR/hdf5/release_$BUILD_NAME --enable-netcdf=v492 --enable-petsc --enable-petsc-required --disable-eigen PETSC_DIR=$OMCDIR/petsc/release_$BUILD_NAME --prefix=$OMCDIR/libmesh/release_$BUILD_NAME
VERBOSE=1 make install

#For OpenMC new with libmesh:
cd $OMCDIR/openmc
mkdir build_$BUILD_NAME
cd build_$BUILD_NAME
CC=mpiicx FC=mpiifx CXX=mpiicpx cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_Fortran_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_CXX_FLAGS_RELEASE="$BUILD_FLAGS" -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DOPENMC_USE_OPENMP=ON -DOPENMC_USE_MPI=ON -DOPENMC_USE_DAGMC=on -DCMAKE_PREFIX_PATH="$OMCDIR/DAGMC/release_$BUILD_NAME;$OMCDIR/libmesh/release_$BUILD_NAME" -DOPENMC_USE_LIBMESH=ON -DHDF5_ROOT=$OMCDIR/hdf5/release_$BUILD_NAME -DHDF5_PREFER_PARALLEL=on -DCMAKE_INSTALL_PREFIX=$OMCDIR/openmc/release_$BUILD_NAME
VERBOSE=1 make install
