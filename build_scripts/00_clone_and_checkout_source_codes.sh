# Set your OpenMC working directory here:
export OMCDIR=$SCRATCH/omc
mkdir -p $OMCDIR

# Eigen3
cd $OMCDIR
git clone https://gitlab.com/libeigen/eigen.git
cd eigen
git checkout 3.4.0

# HDF5
cd $OMCDIR
git clone https://github.com/HDFGroup/hdf5.git
cd hdf5
git checkout hdf5-1_14_3

# NetCDF-C
cd $OMCDIR
git clone https://github.com/Unidata/netcdf-c.git
cd netcdf-c
git checkout v4.9.2

# MOAB
cd $OMCDIR
git clone https://bitbucket.org/fathomteam/moab.git
cd moab
git checkout 5.5.1

# Embree
cd $OMCDIR
git clone https://github.com/RenderKit/embree.git
cd embree
git checkout v4.4.0

# Double-down
cd $OMCDIR
git clone https://github.com/pshriwise/double-down.git
cd double-down
git checkout v1.1.0

# DAGMC
cd $OMCDIR
git clone https://github.com/svalinn/DAGMC.git
cd DAGMC
git checkout v3.2.4

# PETSc
cd $OMCDIR
git clone https://github.com/petsc/petsc.git
cd petsc
git checkout v3.24.3

# libmesh
cd $OMCDIR
git clone https://github.com/libMesh/libmesh.git
cd libmesh
git checkout v1.8.4

# OpenMC
cd $OMCDIR
git clone https://github.com/openmc-dev/openmc
cd openmc
git checkout v0.15.3
