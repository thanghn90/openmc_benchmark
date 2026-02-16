# openmc_benchmark
This repo contains build scripts, SLURM job scripts, and datasets used in our OpenMC benchmarking project.

Common working directory:
- `$OMCDIR`: directory containing source codes and compiled executables, along with some of the scripts to set up compilers (AMD, Intel, etc...)
- `$BIGDIR`: working directory for the big HYLIFE-II model. e.g. $SCRATCH/OpenMC_HYLIFE_II
- `$SMALLDIR`: working directory for the small spherical model. e.g. $SCRATCH/OpenMC_Small_Sphere

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
