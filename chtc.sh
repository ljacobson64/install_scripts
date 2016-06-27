#!/bin/bash

jobs=`grep -c processor /proc/cpuinfo`
orig_dir=$PWD
dist_dir=$orig_dir/dist
build_dir=$orig_dir/build
install_dir=$orig_dir/opt
TMPDIR=$orig_dir/tmp
TEMP=$TMPDIR
TMP=$TMPDIR
mkdir -p $dist_dir $build_dir
cd $dist_dir

# Download all the tarballs
wget https://gmplib.org/download/gmp/gmp-6.1.1.tar.bz2 \
     http://www.mpfr.org/mpfr-current/mpfr-3.1.4.tar.gz \
     ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz \
     http://www.netgull.com/gcc/releases/gcc-5.4.0/gcc-5.4.0.tar.gz \
     https://cmake.org/files/v3.5/cmake-3.5.2.tar.gz \
     https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tgz \
     https://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.13/src/hdf5-1.8.13.tar.gz \
     http://www.netlib.org/lapack/lapack-3.6.1.tgz \
     https://pypi.python.org/packages/9f/7c/0a33c528164f1b7ff8cf0684cf88c2e733c8ae0119ceca4a3955c7fc059d/setuptools-23.1.0.tar.gz \
     https://pypi.python.org/packages/b1/51/bd5ef7dff3ae02a2c6047aa18d3d06df2fb8a40b00e938e7ea2f75544cac/Cython-0.24.tar.gz \
     https://sourceforge.net/projects/numpy/files/NumPy/1.11.1/numpy-1.11.1.tar.gz \
     https://sourceforge.net/projects/scipy/files/scipy/0.16.1/scipy-0.16.1.tar.gz \
     https://pypi.python.org/packages/05/cd/8dbb09b835539234bafc6c5fa02452186da9869e44e7489037ef3994471e/numexpr-2.6.0.tar.gz \
     https://sourceforge.net/projects/pytables/files/pytables/3.2.0/tables-3.2.0.tar.gz \
     https://pypi.python.org/packages/58/a5/0dc93c3ec33f4e281849523a5a913fa1eea9a3068acfa754d44d88107a44/nose-1.3.7.tar.gz

# GMP
name=gmp
cd $build_dir
mkdir $name && cd $name
tar -xjvf $dist_dir/gmp-6.1.1.tar.bz2
ln -s gmp-6.1.1 src
mkdir bld && cd bld
../src/configure --prefix=$install_dir/$name
make -j $jobs install
export LD_LIBRARY_PATH=$install_dir/$name/lib:$LD_LIBRARY_PATH

# MPFR
name=mpfr
cd $build_dir
mkdir $name && cd $name
tar -xzvf $dist_dir/mpfr-3.1.4.tar.gz
ln -s mpfr-3.1.4 src
mkdir bld && cd bld
../src/configure --with-gmp=$install_dir/gmp \
                 --prefix=$install_dir/$name
make -j $jobs install
export LD_LIBRARY_PATH=$install_dir/$name/lib:$LD_LIBRARY_PATH

# MPC
name=mpc
cd $build_dir
mkdir $name && cd $name
tar -xzvf $dist_dir/mpc-1.0.3.tar.gz
ln -s mpc-1.0.3 src
mkdir bld && cd bld
../src/configure --with-gmp=$install_dir/gmp \
                 --with-mpfr=$install_dir/mpfr \
                 --prefix=$install_dir/$name
make -j $jobs install
export LD_LIBRARY_PATH=$install_dir/$name/lib:$LD_LIBRARY_PATH

# GCC
name=gcc
cd $build_dir
mkdir $name && cd $name
tar -xzvf $dist_dir/gcc-5.4.0.tar.gz
ln -s gcc-5.4.0 src
mkdir bld && cd bld
../src/configure --enable-languages=c,c++,fortran \
                 --with-gmp=$install_dir/gmp \
                 --with-mpfr=$install_dir/mpfr \
                 --with-mpc=$install_dir/mpc \
                 --prefix=$install_dir/$name
make -j $jobs
make install
export PATH=$install_dir/$name/bin:$PATH
export LD_LIBRARY_PATH=$install_dir/$name/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$install_dir/$name/lib64:$LD_LIBRARY_PATH

# CMake
name=cmake
cd $build_dir
mkdir $name && cd $name
tar -xzvf $dist_dir/cmake-3.5.2.tar.gz
ln -s cmake-3.5.2 src
mkdir bld && cd bld
../src/configure --prefix=$install_dir/$name
make -j $jobs install
export PATH=$install_dir/$name/bin:$PATH
export LD_LIBRARY_PATH=$install_dir/$name/lib:$LD_LIBRARY_PATH

# Python
name=python
cd $build_dir
mkdir $name && cd $name
tar -xzvf $dist_dir/Python-2.7.11.tgz
ln -s Python-2.7.11 src
mkdir bld && cd bld
../src/configure --enable-shared \
                 --prefix=$install_dir/$name
make -j $jobs install
export PATH=$install_dir/$name/bin:$PATH
export LD_LIBRARY_PATH=$install_dir/$name/lib:$LD_LIBRARY_PATH

# HDF5
name=hdf5
cd $build_dir
mkdir $name && cd $name
tar -xzvf $dist_dir/hdf5-1.8.13.tar.gz
ln -s hdf5-1.8.13 src
mkdir bld && cd bld
../src/configure --enable-shared \
                 --disable-debug \
                 --prefix=$install_dir/$name
make -j $jobs install
export PATH=$install_dir/$name/bin:$PATH
export LD_LIBRARY_PATH=$install_dir/$name/lib:$LD_LIBRARY_PATH

# LAPACK
name=lapack
cd $build_dir
mkdir $name && cd $name
tar -xzvf $dist_dir/lapack-3.6.1.tgz
ln -s lapack-3.6.1 src
mkdir bld && cd bld
cmake ../src -DCMAKE_Fortran_COMPILER=$install_dir/gcc/bin/gfortran \
             -DCMAKE_INSTALL_PREFIX=$install_dir/$name
make -j $jobs install
export LD_LIBRARY_PATH=$install_dir/$name/lib:$LD_LIBRARY_PATH

# Setuptools
name=setuptools
cd $build_dir
mkdir $name && cd $name
tar -xzvf $dist_dir/setuptools-23.1.0.tar.gz
cd setuptools-23.1.0
mkdir -p $install_dir/$name/lib/python2.7/site-packages
export PATH=$install_dir/$name/bin:$PATH
export PYTHONPATH=$install_dir/$name/lib/python2.7/site-packages:$PYTHONPATH
python setup.py install --prefix=$install_dir/$name

# Cython
name=cython
cd $build_dir
mkdir $name && cd $name
tar -xzvf $dist_dir/Cython-0.24.tar.gz
cd Cython-0.24
mkdir -p $install_dir/$name/lib/python2.7/site-packages
export PATH=$install_dir/$name/bin:$PATH
export PYTHONPATH=$install_dir/$name/lib/python2.7/site-packages:$PYTHONPATH
python setup.py install --prefix=$install_dir/$name

# NumPy
name=numpy
cd $build_dir
mkdir $name && cd $name
tar -xzvf $dist_dir/numpy-1.11.1.tar.gz
cd numpy-1.11.1
mkdir -p $install_dir/$name/lib/python2.7/site-packages
export PATH=$install_dir/$name/bin:$PATH
export PYTHONPATH=$install_dir/$name/lib/python2.7/site-packages:$PYTHONPATH
python setup.py build -j $jobs install --prefix=$install_dir/$name

# SciPy
name=scipy
cd $build_dir
mkdir $name && cd $name
tar -xzvf $dist_dir/scipy-0.16.1.tar.gz
cd scipy-0.16.1
mkdir -p $install_dir/$name/lib/python2.7/site-packages
export PATH=$install_dir/$name/bin:$PATH
export PYTHONPATH=$install_dir/$name/lib/python2.7/site-packages:$PYTHONPATH
python setup.py build -j $jobs install --prefix=$install_dir/$name

# NumExpr
name=numexpr
cd $build_dir
mkdir $name && cd $name
tar -xzvf $dist_dir/numexpr-2.6.0.tar.gz
cd numexpr-2.6.0
mkdir -p $install_dir/$name/lib/python2.7/site-packages
export PYTHONPATH=$install_dir/$name/lib/python2.7/site-packages:$PYTHONPATH
python setup.py install --prefix=$install_dir/$name

# PyTables
name=pytables
cd $build_dir
mkdir $name && cd $name
tar -xzvf $dist_dir/tables-3.2.0.tar.gz
cd tables-3.2.0
mkdir -p $install_dir/$name/lib/python2.7/site-packages
export PYTHONPATH=$install_dir/$name/lib/python2.7/site-packages:$PYTHONPATH
python setup.py install --prefix=$install_dir/$name

# Nose
name=nose
cd $build_dir
mkdir $name && cd $name
tar -xzvf $dist_dir/nose-1.3.7.tar.gz
cd nose-1.3.7
mkdir -p $install_dir/$name/lib/python2.7/site-packages
export PATH=$install_dir/$name/bin:$PATH
export PYTHONPATH=$install_dir/$name/lib/python2.7/site-packages:$PYTHONPATH
python setup.py install --prefix=$install_dir/$name

# MOAB
name=moab
cd $build_dir
mkdir $name && cd $name
git clone https://bitbucket.org/fathomteam/moab moab-4.9.1 -b Version4.9.1 --single-branch
cd moab-4.9.1
autoreconf -fi
cd ..
ln -s moab-4.9.1 src
mkdir bld && cd bld
../src/configure --enable-dagmc \
                 --enable-optimize \
                 --enable-shared \
                 --disable-debug \
                 --with-hdf5=$install_dir/hdf5 \
                 --prefix=$install_dir/$name
make -j $jobs install
export PATH=$install_dir/$name/bin:$PATH
export LD_LIBRARY_PATH=$install_dir/$name/lib:$LD_LIBRARY_PATH

# PyTAPS
name=pytaps
cd $build_dir
mkdir $name && cd $name
git clone https://bitbucket.org/fathomteam/pytaps pytaps-master -b master --single-branch
cd pytaps-master
mkdir -p $install_dir/$name/lib/python2.7/site-packages
export PATH=$install_dir/$name/bin:$PATH
export PYTHONPATH=$install_dir/$name/lib/python2.7/site-packages:$PYTHONPATH
python setup.py --iMesh-path=$install_dir/moab \
                install --prefix=$install_dir/$name

# PyNE
name=pyne
cd $build_dir
mkdir $name && cd $name
git clone https://github.com/pyne/pyne pyne-dev -b develop --single-branch
cd pyne-dev
mkdir -p $install_dir/$name/lib/python2.7/site-packages
export PATH=$install_dir/$name/bin:$PATH
export PYTHONPATH=$install_dir/$name/lib/python2.7/site-packages:$PYTHONPATH
python setup.py -DMOAB_INCLUDE_DIR=$install_dir/moab/include \
                -DCMAKE_CXX_COMPILER=$install_dir/gcc/bin/g++ \
                -DCMAKE_Fortran_COMPILER=$install_dir/gcc/bin/gfortran \
                install --prefix=$install_dir/$name -j $jobs
nuc_data_make

# Make the tarball
cd $install_dir
tar -czvf pyne_chtc.tar.gz gmp mpfr mpc gcc \
                           cmake python hdf5 lapack \
                           setuptools cython numpy scipy numexpr pytables nose \
                           moab pytaps pyne
mv pyne_chtc.tar.gz $orig_dir

# Cleanup
rm -rf $dist_dir $build_dir $install_dir
