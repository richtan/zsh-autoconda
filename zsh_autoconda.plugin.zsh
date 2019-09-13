# This is fork of https://github.com/sharonzhou/conda-autoenv for zsh

function zsh_autoconda() {
  if [ -e "environment.yml" ]; then
    ENV=$(head -n 1 environment.yml | cut -f2 -d ' ')
    # Check if you are already in the environment
    if [[ $PATH != *$ENV* ]]; then
      # Check if the environment exists
      if conda activate $ENV && [[ $? -eq 0 ]]; then
        # Set root directory of active environment
        CONDA_ENV_ROOT="$(pwd)"
      else
        echo "Creating conda environment '$ENV' from environment.yml ('$ENV' was not found using 'conda env list')"
        conda env create -q -f environment.yml
        echo "'$ENV' successfully created and will automatically activate in this directory"
        conda activate $ENV
        if [ -e "requirements.txt" ]; then
          echo "Installing pip requirements from requirements.txt"
          pip install -q -r requirements.txt
          echo "Pip requirements successfully installed"
        fi
      fi
    fi
  elif [[ $PATH = */envs/* ]]\
    && [[ $(pwd) != $CONDA_ENV_ROOT ]]\
    && [[ $(pwd) != $CONDA_ENV_ROOT/* ]]
  then
    echo "Deactivating conda environment"
    export PIP_FORMAT=columns
    echo "Updating conda environment.yml (and pip requirements.txt)"
    conda env export > $CONDA_ENV_ROOT/environment.yml
    pip freeze > $CONDA_ENV_ROOT/requirements.txt
    CONDA_ENV_ROOT=""
    echo "Successfully updated environment.yml and requirements.txt"
    conda deactivate
    echo "Deactivated successfully"
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd zsh_autoconda
