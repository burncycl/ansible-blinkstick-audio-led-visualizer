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
BSV_PLAYBOOK_YML := blinkstick-visualizer.yml 
BSVAPP_PLAYBOOK_YML := django-blinkstick-visualizer.yml 
BSV_LOCAL_PLAYBOOK_YML := blinkstick-visualizer_local.yml 
BSVAPP_LOCAL_PLAYBOOK_YML := django-blinkstick-visualizer_local.yml 
VAULTPWF := /secrets/.vaultpw

# Handle no targets specified.
all:
	$(info make viz)
	$(error No Target specified.)

viz: ansible 
vizapp: bsvapp

# Ansible
bsv:
	$(ANSIBLE_PLAYBOOK) -i ./inventory $(BSV_PLAYBOOK_YML)
#	$(ANSIBLE_PLAYBOOK) -i ./inventory $(BSV_PLAYBOOK_YML) --vault-password-file $(VAULTPWF)

bsv_local:
	$(ANSIBLE_PLAYBOOK) -i ./inventory $(BSV_LOCAL_PLAYBOOK_YML)

bsvapp:
	$(ANSIBLE_PLAYBOOK) -i ./inventory $(BSVAPP_LOCAL_PLAYBOOK_YML) --vault-password-file $(VAULTPWF)
#	$(ANSIBLE_PLAYBOOK) -i ./inventory $(BSVAPP_LOCAL_PLAYBOOK_YML) --vault-password-file $(VAULTPWF)

bsvapp_local:
	$(ANSIBLE_PLAYBOOK) -i ./inventory $(BSVAPP_LOCAL_PLAYBOOK_YML)

# Surgical # Run against specific tags 
surgical: 
#	$(ANSIBLE_PLAYBOOK) -i ./inventory $(BSV_PLAYBOOK_YML) --tags "maintenance_scripts" --vault-password-file $(VAULTPWF)
	$(ANSIBLE_PLAYBOOK) -i ./inventory $(BSVAPP_PLAYBOOK_YML) --tags "nginx_conf" --vault-password-file $(VAULTPWF)

