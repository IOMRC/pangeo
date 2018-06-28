#!/bin/bash

##SBATCH --partition=workq
#SBATCH --partition=debugq
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=01:00:00
#SBATCH --account=pawsey0106
#SBATCH --export=NONE
##SBATCH --mail-type=ALL
##SBATCH --mail-user=matt.rayson@uwa.edu.au
#SBATCH -J  dask-sched    # name
#SBATCH -o /home/mrayson/group/mrayson/log/dask-%J.out


# Writes ~/scheduler.json file in home directory
# Connect with
# >>> from dask.distributed import Client
# >>> client = Client(scheduler_file='~/scheduler.json')

# Setup Environment
#source mod_env_setup.sh
#source ~/setPython.sh # or module load python - this just setup up my python dist 
module use ~/code/modulefiles
module load anaconda-python/2.0.0

###
# Start a notebook

let ipnport=8888

echo ipnport=$ipnport

ipnip=$(hostname -i)

echo ipnip=$ipnip

export XDG_RUNTIME_DIR="" 


jupyter notebook --ip=$ipnip --port=$ipnport --no-browser &> $HOME/notebook.out &

echo '
Check /home/mrayson/notebook.out for the IP address.

Then run the following command from your local PC:

>>ssh -N -L 8888:<IP Address in logfile>:8888 -l mrayson zeus.pawsey.org.au
'


###
# Launch the scheduler
LDIR=/scratch/pawsey0106/$USER/tmp_dask
echo $LDIR
rm -rf $LDIR
mkdir $LDIR

NUMTHREADS=1 

SCHEDULER=$HOME/scheduler.json
#SCHEDULER=/scratch/pawsey0106/$USER/scheduler.json
#rm -f $SCHEDULER
srun -u --export=all -n ${SLURM_NPROCS} dask-mpi \
    --nthreads $NUMTHREADS \
    --memory-limit 0.55 \
    --local-directory $LDIR \
    --scheduler-file=$SCHEDULER
    # this makes the bokeh not work
    #--interface ib0 \

## wait for scheduler to start
#while [ ! -f $SCHEDULER ]; do 
#    sleep 1
#done


