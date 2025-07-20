#
# Biostar Handbook of bubble system bootstrap.
# Micromamba
# 

# Check that the script runs using bash
if [ -z "$BASH_VERSION" ]
then
  echo "#"
  echo "# Error: The script was designed to be run using the bash shell!"
  echo "#"
  echo "# Please see the setup instructions for more information."
  echo "#"
  echo "# It is possible to use a different shell, but you need to modify the script accordingly."
  echo "#"
  exit 1
fi

# Check that bzip2 is present.
# The micromamba needs `curl` and `tar` with support for bzip2.
if ! command -v bzip2 &> /dev/null
then
    echo "#"
    echo "# Error: bzip2 command not found"
    echo "#"
    echo "# Please install bzip2 and try again:"
    echo "#"
    echo "#     sudo apt install -y  bzip2"
    exit 1
fi

# Bash strict mode.
# This will cause the script to exit on any error.
set -ue

# Check if the current directory is the home directory.
if [ "$PWD" != "$HOME" ]
then
  echo "#"
  echo "# Note: The installation must be run from your HOME directory!"
  echo "#"
  echo "# Attempted to automatically change to the HOME directory." 
  echo "#"
  cd "$HOME" || { echo "# Failed to switch to home directory."; exit 1; }
  # Check again
  if [ "$PWD" != "$HOME" ]
  then
    echo "# Still not in home directory. Exiting."
    echo "# Please move to the home directory and try again:"
    echo "#"
    echo "# cd $HOME"
    echo "#"
    exit 1
  fi
fi


echo "#"
echo "# Welcome to the Biostar Handbook of Bubble!"
echo "#"
echo "# Web: https://smileszh.com"
echo "#"
echo "# Setting up bioinformatics tools."
echo "#"

# Bioinformatics tool environment name.
ENV_BIOINFO=bioinfo

# Conda root prefix.
ROOT=~/micromamba

# Version of Python to use.
PY_VER=3.12

# Conda specification file.
CONDA_SPEC=~/.biostar.conda.txt

# We need this to avoid a superfluous warning.
mkdir -p ~/.mamba/pkgs

# Make the bin directory.
mkdir -p ~/bin

echo "# 1. Installing micromamba"
echo "#"

# Select the download based on the platform.
if [ "$(uname)" == "Darwin" ]; then
	URL=https://micro.mamba.pm/api/micromamba/osx-64/latest
else
	URL=https://micro.mamba.pm/api/micromamba/linux-64/latest
fi

# Download the latest version.
curl -Lks ${URL} | tar -xj bin/micromamba

echo "# 2. Configuring micromamba channels"
echo "#"

# Ensure the correct order in the condarc file.
~/bin/micromamba config prepend channels bioconda
~/bin/micromamba config prepend channels conda-forge

# Set strict channel priority.
~/bin/micromamba config set channel_priority strict

echo "# 3. Configuring the shell"
echo "#"

# Initialize the shell
~/bin/micromamba shell init -s bash -r ${ROOT} -q

# Download the environment setup file.
curl -s http://data.biostarhandbook.com/install/biostar.sh > ~/.biostar.sh

# Ensure that the .bashrc file exists.
touch ~/.bashrc

# Append to bashrc if necessary.
if ! grep -q ".biostar.sh" ~/.bashrc; then
  echo "" >> ~/.bashrc
  echo "source ~/.biostar.sh" >> ~/.bashrc
  echo "" >> ~/.bashrc
fi

# Ensure that the .bash_profile file exists.
touch ~/.bash_profile

# Append to .bash_profile if necessary.
if ! grep -q ".bashrc" ~/.bash_profile; then
  echo "" >> ~/.bash_profile
  echo "source ~/.bashrc" >> ~/.bash_profile
  echo "" >> ~/.bash_profile
fi

# Check that the conda environment exists
if [ ! -d "$ROOT/envs/$ENV_BIOINFO" ]; then
  echo "# 4. Creating the ${ENV_BIOINFO} environment"
  echo "#"
  ~/bin/micromamba create -q -r ${ROOT} -n $ENV_BIOINFO -y python=${PY_VER}
fi

# Install the software for the biostar handbook.
echo "# 5. Installing tools into ${ENV_BIOINFO}"
echo "#"

# Download the conda specification file.
curl -s http://data.biostarhandbook.com/install/conda.txt > ${CONDA_SPEC}

# Install the conda packages
~/bin/micromamba install -r ${ROOT} -n ${ENV_BIOINFO} -f ${CONDA_SPEC} -y -q

# Install the doctor
echo "# 6. Installing doctor.py"
echo "#"

# Install the doctor.py 
mkdir -p ~/bin
curl -s http://data.biostarhandbook.com/install/doctor.py > ~/bin/doctor.py
chmod +x ~/bin/doctor.py

# Install the bio package.
echo "# 7. Installing the bio package"
echo "#"
${ROOT}/envs/${ENV_BIOINFO}/bin/python -m pip install bio chardet -q --upgrade

# Install the Entrez toolkit
echo "# 8. Installing Entrez Direct"
echo "#"
yes no | sh -c "$(curl -fsSL ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)" > /dev/null

echo "# 9. Installing the SRA toolkit"
echo "#"
curl -s http://data.biostarhandbook.com/install/sratools.sh | bash

# Turn on strict error checking.
set -eu

# There is a "nagware" aspect to GNU parallel that interferes running it automatically.
# The commands below silences the warning messages.
(mkdir -p ~/.parallel && touch ~/.parallel/will-cite)

# Installation completed.
echo "# The Biostar Handbook software installation has completed!"
echo "#"
echo "# Restart the terminal or type: source ~/.bash_profile"
echo "#"
