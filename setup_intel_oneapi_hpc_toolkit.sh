# Set your OpenMC working directory here:
export OMCDIR=$SCRATCH/omc
mkdir -p $OMCDIR
cd $OMCDIR

wget https://registrationcenter-download.intel.com/akdlm/IRC_NAS/66021d90-934d-41f4-bedf-b8c00bbe98bc/intel-oneapi-hpc-toolkit-2025.3.0.381_offline.sh

sh ./intel-oneapi-hpc-toolkit-2025.3.0.381_offline.sh -a --silent --cli --eula accept --install-dir=./intel

rm -rf ~/intel

# To activate intel oneAPI environment later, type:
# . $OMCDIR/intel/setvars.sh