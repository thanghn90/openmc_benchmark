# openmc_benchmark
This repo contains build scripts, SLURM job scripts, and datasets used in our OpenMC benchmarking project.

Common working directories:
- `$OMCDIR`: directory containing source codes and compiled executables, along with some of the scripts to set up compilers (AMD, Intel, etc...)
- `$BIGDIR`: working directory for the big HYLIFE-II model. e.g. $SCRATCH/OpenMC_HYLIFE_II
- `$SMALLDIR`: working directory for the small spherical model. e.g. $SCRATCH/OpenMC_Small_Sphere

# Building OpenMC and its dependencies
First, run [00_clone_and_checkout_source_codes.sh](build_scripts/00_clone_and_checkout_source_codes.sh) to clone and checkout the source codes for OpenMC and its dependencies used in this project.

Then, set up AMD and Intel toolchain with [01a_setup_amd_aocc.sh](build_scripts/01a_setup_amd_aocc.sh) and [01b_setup_intel_oneapi_hpc_toolkit.sh](build_scripts/01b_setup_intel_oneapi_hpc_toolkit.sh) if your HPC does not have AOCC and/or Intel toolchain.

Finally, run [02a_build_instruction_aocc_impi_imkl_gfortran.sh](build_scripts/02a_build_instruction_aocc_impi_imkl_gfortran.sh) to build OpenMC and its dependencies with AMD AOCC compilers, Intel MPI, Intel MKL, and GNU Fortran.

Avoid building directly on your `$HOME` directory. This is because some HPCs might impose file count limit on your HOME/SCRATCH/WORK/PROJECT directory, and usually `$HOME` directory have a much lower file count limit (e.g. on Launch and other TAMU HPCs, you can only have up to 10,000 file on your `$HOME` directory. If you're short on file count after building OpenMC and its dependencies, run [cleanup_script.sh](build_scripts/cleanup_script.sh). This will remove temporary build files and the includes + example files in the release directories that are not needed to run OpenMC.

# Setting up OpenMC simulations
To set up the experiment, make sure you download and extract the model 7z files to the corresponding working directories. The folder structure should look like:
* `$BIGDIR` (`$SCRATCH/OpenMC_HYLIFE_II`)
  * `Model_HYLIFE_II`
    * `model.xml`
    * `HYLIFE_II_v2_Coarse.exo`
    * `HYLIFE_II_v2_Coarse.h5m`
* `$SMALLDIR` (`$SCRATCH/OpenMC_Small_Sphere`)
  * `Model_Small_Sphere`
    * `model.xml`
  * `Meshes`
    * `test.exo`
    * `test.h5m`

You will also need to download and extract neutron/photon cross-section data from the official OpenMC data site. This is the one we used in our project:

[https://openmc.org/data/#endf-b-viii-0](https://openmc.org/data/#endf-b-viii-0)

And then make sure you set OPENMC_CROSS_SECTIONS environment variable to point to the path of the file `cross_sections.xml` in the cross-section data directory. Make sure to modify the template SLURM job script in this repo accordingly.

Ideally, you should put SLURM job scripts directly in your working directory (`$BIGDIR` and `$SMALLDIR`).

Checklist to make change to your SLURM job scripts and model.xml:
* Change `#SBATCH --ntasks` and `#SBATCH --ntasks-per-node` to the amount of total parallel threads you wish OpenMC to run on.
* Change `#SBATCH --mem` to the amount of RAM you need for your OpenMC simulation.
* Change partition name to match your HPC's configuration.
* It's good to request a whole node (`#SBATCH --exclusive`) if you are going to use entire node(s) for your OpenMC simulation. However, note that a whole node will have to be idle to pick up your job, and you may need to wait for a while. If it's quick testing, remove the `#SBATCH --exclusive` flag.
* Change the module loading lines to match your toolchain setup
* Change the build name to yours
* Define `OPENMC_CROSS_SECTIONS` as the path of your `cross_sections.xml` file.
* Change `BASE_NP` to a different number than default (200,000) if your HPC took much longer to run the job (ideally it should take about a bit more than 1 minute to finish an iteration).
* Change `Model_HYLIFE_II` to `Model_Small_Sphere` for the small sphere simulation, and also change `output` to `SimOut` output directory name.
* Look for `library=` in your `model.xml` file and change it to either `moab` or `libmesh` depending on which library you want to use for unstructured mesh tallying. We recommend `libmesh` since `moab` tallying does not scale well in OpenMP parallelization mode.

# Submitting SLURM job script and analyzing output log files
To submit a SLURM job script, type:
```
sbatch slurm_job_script_file_name.slurm
```
After the simulation is done, you can grep for just the calculation rate using the following command template:
```
for i in $(seq 1 32); do grep Rate mpi.a5o3.moab.$i.1.out; done |awk '{print $5}'
```
This will print out the calculation rates (particles/s) for each 1st iteration of the OpenMC simulations ranging from 1 to 32 MPI threads.
