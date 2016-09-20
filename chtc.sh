#!/bin/bash

jobs=`grep -c processor /proc/cpuinfo`
orig_dir=${PWD}
dist_dir=${orig_dir}/dist
build_dir=${orig_dir}/build
install_dir=${orig_dir}/opt
TMPDIR=${orig_dir}/tmp
TEMP=${TMPDIR}
TMP=${TMPDIR}
mkdir -p ${dist_dir} ${build_dir}

# Versions
gmp_version=6.1.1
mpfr_version=3.1.4
mpc_version=1.0.3
gcc_version=5.4.0
cmake_version=3.6.1
python_version=2.7.12
hdf5_version=1.8.13
lapack_version=3.6.1
setuptools_version=26.1.1
cython_version=0.24.1
numpy_version=1.11.1
scipy_version=0.16.1
numexpr_version=2.6.1
pytables_version=3.2.0
nose_version=1.3.7
moab_version=4.9.2
pytaps_version=master
pyne_version=dev

# Download all the tarballs
cd ${dist_dir}
wget https://gmplib.org/download/gmp/gmp-${gmp_version}.tar.bz2 \
     http://www.mpfr.org/mpfr-current/mpfr-${mpfr_version}.tar.gz \
     ftp://ftp.gnu.org/gnu/mpc/mpc-${mpc_version}.tar.gz \
     http://www.netgull.com/gcc/releases/gcc-${gcc_version}/gcc-${gcc_version}.tar.gz \
     https://cmake.org/files/v${version:0:3}/cmake-${cmake_version}.tar.gz \
     https://www.python.org/ftp/python/${python_version}/Python-${python_version}.tgz \
     https://www.hdfgroup.org/ftp/HDF5/releases/hdf5-${hdf5_version}/src/hdf5-${hdf5_version}.tar.gz \
     http://www.netlib.org/lapack/lapack-${lapack_version}.tgz \
     https://pypi.python.org/packages/32/3c/e853a68b703f347f5ed86585c2dd2828a83252e1216c1201fa6f81270578/setuptools-${setuptools_version}.tar.gz \
     https://pypi.python.org/packages/c6/fe/97319581905de40f1be7015a0ea1bd336a756f6249914b148a17eefa75dc/Cython-${cython_version}.tar.gz \
     http://downloads.sourceforge.net/project/numpy/NumPy/${numpy_version}/numpy-${numpy_version}.tar.gz \
     http://downloads.sourceforge.net/project/scipy/scipy/${scipy_version}/scipy-${scipy_version}.tar.gz \
     https://pypi.python.org/packages/c6/f0/11628fa4d332d8fe9ab0ba8e9bfe0e065fb6b5324859171ee72d84e079c0/numexpr-${numexpr_version}.tar.gz \
     http://downloads.sourceforge.net/project/pytables/pytables/${pytables_version}/tables-${pytables_version}.tar.gz \
     https://pypi.python.org/packages/58/a5/0dc93c3ec33f4e281849523a5a913fa1eea9a3068acfa754d44d88107a44/nose-${nose_version}.tar.gz

# GCC
name=gcc
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
tar -xzvf ${dist_dir}/${name}-${version}.tar.gz
ln -s ${name}-${version} src
cd src
tar -xjvf ${dist_dir}/gmp-${gmp_version}.tar.bz2
tar -xzvf ${dist_dir}/mpfr-${gmp_version}.tar.gz
tar -xzvf ${dist_dir}/mpc-${gmp_version}.tar.gz
ln -s gmp-${gmp_version} gmp
ln -s mpfr-${gmp_version} mpfr
ln -s mpc-${gmp_version} mpc
cd ..
mkdir bld && cd bld
../src/configure --enable-languages=c,c++,fortran \
                 --prefix=${install_dir}/${name}
make -j ${jobs}
make install
export PATH=${install_dir}/${name}/bin:${PATH}
export LD_LIBRARY_PATH=${install_dir}/${name}/lib:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${install_dir}/${name}/lib64:${LD_LIBRARY_PATH}

# CMake
name=cmake
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
tar -xzvf ${dist_dir}/${name}-${version}.tar.gz
ln -s ${name}-${version} src
mkdir bld && cd bld
../src/configure --prefix=${install_dir}/${name}
make -j ${jobs} install
export PATH=${install_dir}/${name}/bin:${PATH}
export LD_LIBRARY_PATH=${install_dir}/${name}/lib:${LD_LIBRARY_PATH}

# Python
name=python
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
tar -xzvf ${dist_dir}/Python-${version}.tgz
ln -s Python-${version} src
mkdir bld && cd bld
../src/configure --enable-shared \
                 --prefix=${install_dir}/${name}
make -j ${jobs} install
export PATH=${install_dir}/${name}/bin:${PATH}
export LD_LIBRARY_PATH=${install_dir}/${name}/lib:${LD_LIBRARY_PATH}

# HDF5
name=hdf5
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
tar -xzvf ${dist_dir}/${name}-${version}.tar.gz
ln -s ${name}-${version} src
mkdir bld && cd bld
../src/configure --enable-shared \
                 --disable-debug \
                 --prefix=${install_dir}/${name}
make -j ${jobs} install
export PATH=${install_dir}/${name}/bin:${PATH}
export LD_LIBRARY_PATH=${install_dir}/${name}/lib:${LD_LIBRARY_PATH}

# LAPACK
name=lapack
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
tar -xzvf ${dist_dir}/${name}-${version}.tgz
ln -s ${name}-${version} src
mkdir bld && cd bld
cmake ../src -DCMAKE_Fortran_COMPILER=${install_dir}/gcc/bin/gfortran \
             -DCMAKE_INSTALL_PREFIX=${install_dir}/${name}
make -j ${jobs} install
export LD_LIBRARY_PATH=${install_dir}/${name}/lib:${LD_LIBRARY_PATH}

# Setuptools
name=setuptools
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
tar -xzvf ${dist_dir}/${name}-${version}.tar.gz
cd ${name}-${version}
mkdir -p ${install_dir}/${name}/lib/python2.7/site-packages
export PATH=${install_dir}/${name}/bin:${PATH}
export PYTHONPATH=${install_dir}/${name}/lib/python2.7/site-packages:${PYTHONPATH}
python setup.py install --prefix=${install_dir}/${name}

# Cython
name=cython
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
tar -xzvf ${dist_dir}/Cython-${version}.tar.gz
cd Cython-${version}
mkdir -p ${install_dir}/${name}/lib/python2.7/site-packages
export PATH=${install_dir}/${name}/bin:${PATH}
export PYTHONPATH=${install_dir}/${name}/lib/python2.7/site-packages:${PYTHONPATH}
python setup.py install --prefix=${install_dir}/${name}

# NumPy
name=numpy
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
tar -xzvf ${dist_dir}/${name}-${version}.tar.gz
cd ${name}-${version}
mkdir -p ${install_dir}/${name}/lib/python2.7/site-packages
export PATH=${install_dir}/${name}/bin:${PATH}
export PYTHONPATH=${install_dir}/${name}/lib/python2.7/site-packages:${PYTHONPATH}
python setup.py build -j ${jobs} install --prefix=${install_dir}/${name}

# SciPy
name=scipy
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
tar -xzvf ${dist_dir}/${name}-${version}.tar.gz
cd ${name}-${version}
mkdir -p ${install_dir}/${name}/lib/python2.7/site-packages
export PATH=${install_dir}/${name}/bin:${PATH}
export PYTHONPATH=${install_dir}/${name}/lib/python2.7/site-packages:${PYTHONPATH}
python setup.py build -j ${jobs} install --prefix=${install_dir}/${name}

# NumExpr
name=numexpr
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
tar -xzvf ${dist_dir}/${name}-${version}.tar.gz
cd ${name}-${version}
mkdir -p ${install_dir}/${name}/lib/python2.7/site-packages
export PYTHONPATH=${install_dir}/${name}/lib/python2.7/site-packages:${PYTHONPATH}
python setup.py install --prefix=${install_dir}/${name}

# PyTables
name=pytables
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
tar -xzvf ${dist_dir}/tables-${version}.tar.gz
cd tables-${version}
mkdir -p ${install_dir}/${name}/lib/python2.7/site-packages
export PYTHONPATH=${install_dir}/${name}/lib/python2.7/site-packages:${PYTHONPATH}
python setup.py install --prefix=${install_dir}/${name}

# Nose
name=nose
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
tar -xzvf ${dist_dir}/${name}-${version}.tar.gz
cd ${name}-${version}
mkdir -p ${install_dir}/${name}/lib/python2.7/site-packages
export PATH=${install_dir}/${name}/bin:${PATH}
export PYTHONPATH=${install_dir}/${name}/lib/python2.7/site-packages:${PYTHONPATH}
python setup.py install --prefix=${install_dir}/${name}

# MOAB
name=moab
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
git clone https://bitbucket.org/fathomteam/${name} ${name}-${version} -b Version${version} --single-branch
cd ${name}-${version}
autoreconf -fi
cd ..
ln -s ${name}-${version} src
mkdir bld && cd bld
../src/configure --enable-dagmc \
                 --enable-optimize \
                 --enable-shared \
                 --disable-debug \
                 --with-hdf5=${install_dir}/hdf5 \
                 --prefix=${install_dir}/${name}
make -j ${jobs} install
export PATH=${install_dir}/${name}/bin:${PATH}
export LD_LIBRARY_PATH=${install_dir}/${name}/lib:${LD_LIBRARY_PATH}

# PyTAPS
name=pytaps
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
git clone https://bitbucket.org/fathomteam/${name} ${name}-${version} -b ${version} --single-branch
cd ${name}-${version}
mkdir -p ${install_dir}/${name}/lib/python2.7/site-packages
export PATH=${install_dir}/${name}/bin:${PATH}
export PYTHONPATH=${install_dir}/${name}/lib/python2.7/site-packages:${PYTHONPATH}
python setup.py --iMesh-path=${install_dir}/moab \
                install --prefix=${install_dir}/${name}

# PyNE
name=pyne
eval version=\$"$name"_version
cd ${build_dir}
mkdir ${name} && cd ${name}
git clone https://github.com/pyne/${name} ${name}-${version} -b develop --single-branch
cd ${name}-${version}
mkdir -p ${install_dir}/${name}/lib/python2.7/site-packages
export PATH=${install_dir}/${name}/bin:${PATH}
export PYTHONPATH=${install_dir}/${name}/lib/python2.7/site-packages:${PYTHONPATH}
python setup.py -DMOAB_INCLUDE_DIR=${install_dir}/moab/include \
                -DCMAKE_CXX_COMPILER=${install_dir}/gcc/bin/g++ \
                -DCMAKE_Fortran_COMPILER=${install_dir}/gcc/bin/gfortran \
                install --prefix=${install_dir}/${name} -j ${jobs}
nuc_data_make

# Make the tarball
cd ${install_dir}
tar -czvf pyne_chtc.tar.gz gcc cmake python hdf5 lapack \
                           setuptools cython numpy scipy numexpr pytables nose \
                           moab pytaps pyne
mv pyne_chtc.tar.gz ${orig_dir}

# Cleanup
rm -rf ${dist_dir} ${build_dir} ${install_dir}
