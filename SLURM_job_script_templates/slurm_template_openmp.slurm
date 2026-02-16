#!/bin/bash
#SBATCH --job-name=oeia5o3l
#SBATCH --time=0-06:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --ntasks-per-node=32
#SBATCH --mem=100G
#SBATCH --output=out.openmp.a5o3.moab.%J
#SBATCH --exclusive
#SBATCH --partition=staff

# Load required modules and source toolchain setup scripts here
# For example this is on Launch supercomputer:
ml purge
ml intel/2025a CMake AOCC/5.0.0

# For other clusters without intel and/or AOCC modules, you will need to manually source intel/AOCC setup scripts, e.g.
# . $OMCDIR/setenv_AOCC.sh
# . $OMCDIR/intel/setvars.sh

# Set OMCDIR to the directory where you build OpenMC and its components
export OMCDIR=$SCRATCH/omc

# Make "openmc" and its required libraries "visible" (e.g. include them in PATH and LD_LIBRARY_PATH environment variables
export BUILD_NAME=a5o3
export PATH=$PATH:$OMCDIR/openmc_new/release_$BUILD_NAME/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OMCDIR/hdf5/release_$BUILD_NAME/lib:$OMCDIR/netcdf-c/release_$BUILD_NAME/lib64

# Make sure this command returns the right openmc executable
which openmc

# OpenMP related settings (to ensure OpenMP threads are binned as "close" to each other within a MPI process as possible)
export OMP_PLACES='threads'
export OMP_PROC_BIND='close'
export OMP_WAIT_POLICY=PASSIVE

# This is where you specify the path to cross_sections.xml
export OPENMC_CROSS_SECTIONS=/path/to/your/cross_sections.xml

# Some benchmarking parameters
export MAX_PROCS=$SLURM_NTASKS_PER_NODE
export MAX_ITERS=3
export BASE_NP=200000
# For OpenMP run, use the same number of particles for all run. It's stable enough.
# Note that this is to run OpenMC simulation with the HYLIFE-II model
# To run simulation with the small sphere model, change Model_HYLIFE_II to Model_Small_Sphere
sed -i "s/<particles>[0-9]*<\/particles>/<particles>$BASE_NP<\/particles>/" Model_HYLIFE_II/model.xml

# Create a directory for screen output logging purpose
export LOGDIR=a5o3_moab
mkdir -p $LOGDIR

# Create a directory for the actual output of the OpenMC simulation. This should be the name of the directory specified in the <output> field of your model.xml file
mkdir -p output
# For Small Sphere model:
# mkdir -p SimOut

# Main Loop through each number of MPI processors
# Note that this is to run OpenMC simulation with the HYLIFE-II model
# To run simulation with the small sphere model, change Model_HYLIFE_II to Model_Small_Sphere
for numproc in $(seq 1 $MAX_PROCS); do
  # Set the number of OpenMP threads accordingly
  export OMP_NUM_THREADS=$numproc
  
  # Loop through number of iterations
  for iter in $(seq 1 $MAX_ITERS); do
    echo Running OpenMC in OpenMP mode with $numproc threads, iteration $iter ...
    openmc Model_HYLIFE_II >> $LOGDIR/openmp.a5o3.moab.$numproc.$iter.out
  done
done


