# 2019/03 BuRnCycL 

# Setup Python virtual envrionment.
ifeq (, $(shell which python3))
$(error Python3 Installation Not Found!)
else
export PYTHON3_LOCAL := $(shell which python3)
endif
ifeq (, $(shell which virtualenv))
$(error Python Virtual Environment Installation Not Found!)
else
export VENV := $(shell which virtualenv)
endif
$(info Creating Virtual Environment...)
VENV_NAME := venv
CREATE_VENV3 := $(shell ${VENV} -p python3 ./${VENV_NAME})
VENV_ACTIVATE := ./${VENV_NAME}/bin/activate
PYTHON3 := ./${VENV_NAME}/bin/python3
PIP3 := ./${VENV_NAME}/bin/pip3
REQUIREMENTS := $(shell ${PIP3} install -r ./requirements.txt)
ANSIBLE_PLAYBOOK := ./${VENV_NAME}/bin/ansible-playbook
$(info Virtual Environment Created.)

# Verify we have what we need.
ifeq (, $(shell which make))
$(error Make Installation Not Found!)
else
export MAKE := $(shell which make)
endif
ifeq (, $(shell which git))
$(error Git Installation Not Found!)
else
export GIT := $(shell which git)
endif

# Declare variables, not war.
ROLES_DIR := ./roles
PLAYBOOK_YML := blinkstick-visualizer.yml 
VAULTPWF := /secrets/.vaultpw

# Handle no targets specified.
all:
	$(info make viz)
	$(error No Target specified.)

viz: ansible 

# Ansible
ansible:
	$(ANSIBLE_PLAYBOOK) -i ./inventory $(PLAYBOOK_YML) --vault-password-file $(VAULTPWF)

# Surgical # Run against specific tags 
surgical: 
	$(ANSIBLE_PLAYBOOK) -i ./inventory $(PLAYBOOK_YML) --tags "python" --vault-password-file $(VAULTPWF)

