#!/bin/bash
#PBS -l walltime=0:30:00
#PBS -A datascience
#PBS -l nodes=2:ppn=4
#PBS -l filesystems=home:eagle
module restore
cd $PBS_O_WORKDIR

export PBS_JOBSIZE=$(cat $PBS_NODEFILE | uniq | sed -n $=)
export DATE_TAG=$(date +"%Y-%m-%d-%H-%M-%S")
read system b <<<$(echo $PBS_O_HOST | tr - "\n")
OUTPUT=results_${system}/n$PBS_JOBSIZE.g4/$DATE_TAG/
mkdir -p $OUTPUT/
env >& $OUTPUT/env.dat
module list >& $OUTPUT/modules.dat
export ALLREDUCE_EXE=./osu-micro-benchmarks/mpi/collective/osu_allreduce
export ALLGATHER_EXE=./osu-micro-benchmarks/mpi/collective/osu_allgather
export ALLTOALL_EXE=./osu-micro-benchmarks/mpi/collective/osu_alltoall
ldd $ALLREDUCE_EXE >& $OUTPUT/ldd.dat
cat $PBS_NODEFILE | uniq >& $OUTPUT/nodes.dat
export LAUNCHER=./launcher.sh
#-d cuda -m 2:1024 
MPICH_GPU_SUPPORT_ENABLED=1 aprun -n $((PBS_JOBSIZE*4)) -N 4 --cc depth -d 16 ${LAUNCHER} ${ALLREDUCE_EXE} -d cuda -m 4:1073741824 >& $OUTPUT/all_reduce_output.dat.1
sleep 10
MPICH_GPU_SUPPORT_ENABLED=1 aprun -n $((PBS_JOBSIZE*4)) -N 4 --cc depth -d 16 ${LAUNCHER} ${ALLTOALL_EXE} -d cuda -m 4:1073741824 >& $OUTPUT/alltoall_output.dat.1
sleep 10
MPICH_GPU_SUPPORT_ENABLED=1 aprun -n $((PBS_JOBSIZE*4)) -N 4 --cc depth -d 16 ${LAUNCHER} ${ALLGATHER_EXE} -d cuda -m 4:1073741824 >& $OUTPUT/all_gather_output.dat.1
sleep 10

aprun -n $((PBS_JOBSIZE*4)) -N 4 --cc depth -d 16 ${LAUNCHER} ${ALLREDUCE_EXE}  -m 4:1073741824 >& $OUTPUT/all_reduce_output.dat.0
sleep 10
aprun -n $((PBS_JOBSIZE*4)) -N 4 --cc depth -d 16 ${LAUNCHER} ${ALLTOALL_EXE}  -m 4:1073741824 >& $OUTPUT/alltoall_output.dat.0
sleep 10
aprun -n $((PBS_JOBSIZE*4)) -N 4 --cc depth -d 16 ${LAUNCHER} ${ALLGATHER_EXE}  -m 4:1073741824 >& $OUTPUT/all_gather_output.dat.0
sleep 10

