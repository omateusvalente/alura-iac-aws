cd /home/ubuntu
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py
sudo piyhon3 -m pip install ansible
tee -a playbook.yml > /dev/null << EOT
- hosts: localhost
  tasks:
  - name: Instalando o python e virtualenv
    apt:
      pkg: 
      - python3
      - virtualenv
      update_cache: yes
    become: yes

  - name: Git Clone
    ansible.builtin.git:
      repo: https://github.com/guilhermeonrails/clientes-leo-api
      dest: /home/ubuntu/tcc
      version: master
      force: yes

  - name: Atualizar pip e instalar dependências Python no venv 
    #instalando as bibliotecas pelo nome para pegar a versão mais atualizada
    become_user: ubuntu
    shell: |
      source /home/ubuntu/tcc/venv/bin/activate
      pip install --upgrade pip
      pip install asgiref django djangorestframework pytz sqlparse typing-extensions
      pip install setuptools
    args:
      executable: /bin/bash

## Arquivo requirements esta com versoes desatualizadas no github
#  - name: Instalando dependencias com pip
#    pip:
#      virtualenv: /home/ubuntu/tcc/venv
#      requirements: /home/ubuntu/tcc/requirements.txt

  - name: Alterando host do settings
    lineinfile: 
      path: /home/ubuntu/tcc/setup/settings.py
      regexp: 'ALLOWED_HOSTS'
      line: 'ALLOWED_HOSTS = ["*"]'
      backrefs: yes
  
  - name: Configurando banco de dados
    shell: '. /home/ubuntu/tcc/venv/bin/activate; python /home/ubuntu/tcc/manage.py migrate'
  - name: Carregando os dados iniciais
    shell: '. /home/ubuntu/tcc/venv/bin/activate; python /home/ubuntu/tcc/manage.py loaddata clientes.json'
  - name: Iniciando o servidor
    shell: '. /home/ubuntu/tcc/venv/bin/activate; nohup python /home/ubuntu/tcc/manage.py runserver 0.0.0.0:8000 &'


EOT
ansible-playbook playbook.yml