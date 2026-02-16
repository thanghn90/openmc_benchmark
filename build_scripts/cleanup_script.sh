# Use this script to remove temporary build files and a lot of "include" files in the release directories that would not be needed to run OpenMC, in case you are running out of your file count quota limit on some HPCs.

# Set your OpenMC working directory here:
export OMCDIR=$SCRATCH/omc
mkdir -p $OMCDIR

cd $OMCDIR
rm -rf */build_* */release_*/include */release_*/examples
