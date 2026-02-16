#!/bin/bash
#SBATCH --job-name=meia5o3l
#SBATCH --time=0-06:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --ntasks-per-node=32
#SBATCH --mem=160G
#SBATCH --output=out.mpi.a5o3.moab.%J
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
export BUILD_NAME=a5o3march
export PATH=$PATH:$OMCDIR/openmc_new/release_$BUILD_NAME/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OMCDIR/hdf5/release_$BUILD_NAME/lib:$OMCDIR/netcdf-c/release_$BUILD_NAME/lib64

# Make sure this command returns the right openmc executable
which openmc

# Some intel-MPI parameters to ensure each process is binned to a core in a compact manner, as well as printing out core binning info with debug level 5.
export I_MPI_PIN_ORDER=compact
export I_MPI_PIN_DOMAIN=core # Set to "omp" in case you wish to run in hybrid MPI-OpenMP mode
export I_MPI_DEBUG=5

# OpenMP related settings (to ensure OpenMP threads are binned as "close" to each other within a MPI process as possible)
export OMP_NUM_THREADS=1 # for hybrid MPI-OpenMP, this is the number of OpenMP threads PER EACH MPI processor
export OMP_PLACES='threads'
export OMP_PROC_BIND='close'
export OMP_WAIT_POLICY=PASSIVE

# This is where you specify the path to cross_sections.xml
export OPENMC_CROSS_SECTIONS=/path/to/your/cross_sections.xml

# Some benchmarking parameters
export MAX_PROCS=$SLURM_NTASKS_PER_NODE
export MAX_ITERS=3
export BASE_NP=200000 # You can change this to a smaller number for less-powerful HPC if it took too long to run. Ideally, each run should take about a bit more than a minute.

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
  # Change the number of particles according to the number of MPI processors
  export NP=$((numproc * BASE_NP))
  sed -i "s/<particles>[0-9]*<\/particles>/<particles>$NP<\/particles>/" Model_HYLIFE_II/model.xml
  
  # Loop through number of iterations
  for iter in $(seq 1 $MAX_ITERS); do
    echo Running OpenMC in MPI mode with $numproc threads, iteration $iter ...
    mpirun -np ${numproc} openmc Model_HYLIFE_II >> $LOGDIR/mpi.a5o3.moab.$numproc.$iter.out
  done
done

