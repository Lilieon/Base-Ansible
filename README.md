# Collections à installer
- community.mysql
- weareinteractive.vsftpd
- sansible.ssmtp

```
ansible-galaxy collection install -r requirements.yml
```

# Rôles disponible
- [base-serveur](#base-serveur)
- [user-creation](#user-creation)
- [parefeu](#parefeu)
- [certbot](#certbot)
- [nginx](#nginx)
- [ftp](#ftp)
- [mariadb](#mariadb)
- [nodejs](#nodejs)
- [pm2](#pm2)
- [git-clone](#git-clone)
- [php](#php)
- [python](#python)

- [docker](#docker)
- [mattermost](#mattermost)
- [nextcloud](#nextcloud)

# TODO
- [ ] Ajouter role de backup
- [ ] Ajouter role de restauration
- [ ] Ajouter la phase de restauration de base de données dans le rôle mariadb
- [ ] Ajouter la phase de restauration de base de données dans le tôle postgresql
- [ ] Voir role kanboard, mattermost, nextcloud et wikijs
- [x] Ajouter role user

# Commandes
## Execution du playbook
Avec le fichier d'inventaire "hosts" passé en paramètre.
Le paramètre "--ask-vault-pass" permet de déchiffrer les variables chiffrées
```
ansible-playbook -i hosts playbook.yml --vault-password-file vault.key
```

## Chiffrage des mots de passe dans un fichier de variable
```
ansible-vault encrypt_string 'LeMotDePasseAChiffrer' --vault-password-file vault.key
```

## Chiffrage et déchifrage fichier
**Chiffrer un fichier :**
```
ansible-vault decrypt --vault-password-file vault.key fichier_chiffre1.yml fichier_chiffre2.yml
```

**Déchiffrer un fichier :**
```
ansible-vault decrypt --vault-password-file vault.key fichier_chiffre1.yml fichier_chiffre2.yml
```

# Ansible role
## base-serveur
### Description
Instalation de base d'un serveur :
- Configuration ssh
- Installation des paquets nécessaire
- Installation et configuration de fail2ban
- Mise à jour host serveur
- Mise en place pare-feu iptables

### Variables
``` yml
hostname: Nom du serveur (Doit être défini)
domain: 
  - name: Voir rôle nginx pour plus de détail 
```

## user-creation
### Description

Création des utilisateurs et génération de clé rsa ou ajout de clé rsa pré-généré.

### Variables
``` yml
user_creation: Liste des utilisateurs à créer
  - name: Nom de l'utilisateur
    password: Mot de passe de l'utilisateur
    sudo: Ajout de l'utilisateur dans le groupe sudo [true, false]
    groups: Liste des groupes de l'utilisateur
      - name: Nom du groupe
    ssh_key_location_type: Emplacement de la clé [url, file, string]
    ssh_key_value: Chemin ou clé publique de l'utilisateur
```

### Détails
Pour la variable ssh_key_location_type, si le type spécifié est 'file' :
- Si le chemin commence par '/' alors le chemin est considéré comme absolu (/home/user/.ssh/id_rsa.pub)
- Si le chemin ne commence pas par '/' alors le chemin est considéré comme relatif (id_rsa.pub -> files/id_rsa.pub)

## certbot
### Description
Installation d'un certificat ssl.
Types de certificat disponible :
- certbot (letsencrypt)
- openssl (autoSigné)

### Variables
``` yml
domain: Variable commune avec nginx - Voir rôle nginx pour plus de détail
  - name: Nom du domain à certifier
    certificate: 
      type: Type de certificat [certbot, openssl]
      certbot_email: Email référencé pour la création du certificat (Doit être défini si type = certbot)
      certbot_staging: Spécifie si l'environment de staging de certbot doit être utilisé, si non défini = false [true, false]
      openssl_cn: Code Pays [FR,IT,...] (Default: FR)
      openssl_state: Pays [France, Italie, ...] (Default: France)
      openssl_locality: Ville [Paris, Milan, ...] (Default: Paris)
      openssl_company: Nom de la société (Default: .inc)
      openssl_section: Service dans la société (Default: IT)
```
## parefeu
### Description
Par défaut, on ferme tout les ports et on ouvre seulement ceux nécessaires.
En utilisant ce rôles on va pouvoir spécifier les ports à ouvrir.

### Utilisation
Exemple pour l'ouverture des ports ftps :
``` yml
- name: Ajout des rêgles au parefeu
  include_role:
    name: parefeu
  vars:
    rules:
      - -A INPUT -p tcp --dport 990 -j ACCEPT
      - -A OUTPUT -p tcp --dport 990 -j ACCEPT
      - -A INPUT -p tcp --dport 989 -j ACCEPT
      - -A OUTPUT -p tcp --dport 989 -j ACCEPT
```

## ftp
### Description
Mise en place de vsftpd sur le serveur.  
Utilise la collection partagée weareinteractive.vsftpd (Voir la documentation de la collection pour plus de détail)

## nginx
### Description
Mise en place de nginx sur le serveur.
Application de la configuration par défaut et activation des sites.  
Dans templates/etx/nginx/sites-available, on trouvera [site-configuration.conf.j2], qui contient le template de base de création des fichiers de configuration des sites pour nginx.  
Dans templates/etx/nginx/sites-available, on trouvera également pour chaque site à configurer, un dossier contenant les éléments à inclure.

### Variables
``` yml
domain: 
  - name: Nom du domaine
    http_port: Port http sur lequel le site écoutera
    https_port: Port https sur lequel le site écoutera
    certificate: Variable commune avec certbot - Voir rôle certbot pour plus de détail
    default_server: Spécifie si le site est le site par défaut [true, false]
```

## mariadb
### Description
Mise en place de mariadb sur le serveur.
Fonctionnalités :
- Installation de mariadb
- Création d'utilisateur mariadb
- Création de base de données :
  - Nouvelle base de données vide
  - Avec restauration à partir d'un script (script à joindre dans files/script)

### Variables
``` yml
mariadb_install_client: Installation du client mariadb [true, false]
mariadb_install_server: Installation du server mariadb [true, false]
mariadb_root_password: Mot de passe du compte root (Pour plus de sécurité, à chiffrer avec ansible encrypt)
mariadb_user:
  - name: Nom de l'utilisateur à créer
    password: Mot de passe de l'utilisateur à créer
    host: Le 'host' de l'utilisateur à créer
    privilege: Droit de l'utilisateur (Voir la documentation mysql) ['*.*:ALL,GRANT', ...]

mariadb_database:
  - installation_type: Type de l'installation [creation, local_script, distant_backup]
    database_name: Nom de la base de données ou du script
    backup_server: Serveur de sauvegarde
    backup_path: Chemin sur le serveur de sauvegarde du dossier de sauvegarde
```

### Détails
Si la variable "installation_type" est égale à "creation", alors database_name sera utilisé pour nommé la nouvelle base de données.
Si la variable "installation_type" est égale à "local_script", alors database_name sera utilisé pour récupérer le script de base de données. On cherchera le fichier qui porte le nom de la variable "database_name" (avec l'extension .sql) dans le dossier "files/script/database_creation".
Si la variable "installation_type" est égale à "distant_backup", alors database_name sera utilisé pour récupérer le script de base de données sur le serveur distant. Le script sera récupéré sur le serveur de sauvegarde à l'emplacement "backup_path".
**Le nom du script dans les cas "local_script" et "distant_backup" ne doit pas forcément être le même que le nom de la base de données. Mais dans ce cas là, le test d'existence de la base de données ne fonctionnera pas. (On pourra alors restaurer une base de données existante...)**

## postgresql
### Description
Mise en place de postgresql sur le serveur.
Fonctionnalités :
- Installation de postgresql
- Création d'utilisateur postgresql
- Création de base de données :
  - Nouvelle base de données vide
  - Avec restauration à partir d'un script (script à joindre dans files/script)

### Variables
``` yml
postgresql_install_client: Installation du client postgresql [true, false]
postgresql_install_server: Installation du serveur postgresql [true, false]
postgresql_root_password: Mot de passe du compte root (Pour plus de sécurité, à chiffrer avec ansible encrypt)
postgresql_version: Version de postgresql à installer [13, 12, ...]
postgresql_user:
  - name: Nom de l'utilisateur à créer
    password: Mot de passe de l'utilisateur à créer
    database: Liste des bases de données sur lesquelles affecter des droits à l'utilisateur
      - name: Nom de la base de données
        priv: Droit de l'utilisateur (Voir la documentation postgresql) [ALL, ...]
        grant_option: Privilèges de gestion de la base de données [true, false]
postgresql_database:
  - name: Nom de la base de données
    installation_type: Type de l'installation [creation, script]
    script_name: Nom du script de base de données
```

## nodejs
### Description
Installation de nodejs et compilation des applications référencé

### Variables
``` yml
node_version: Version de node a installer [lts, 18, 16, 14, ...]
node_application: 
  - path_folder: Emplacement de l'application nodejs
    build: Génération de l'application [true, false]
    build_command: Commande à utiliser pour la génération
    install_package: Installation des modules [true, false]
```

## pm2
### Description
Installation de pm2, génération de la configuration et démarrage des applications nodejs.

### Variables
``` yml
pm2:
  - destination: Dossier de l'application nodejs où sera généré le fichier ecosystem.config.js
    start_application: fDémarrage de l'application par pm2 [true, false] (Voir pm2 config)
    name: Nom de l'application (Voir pm2 config)
    cwd: Dossier où se trouve le script racine de l'application (Voir pm2 config)
    script: Nom du fichier de script racine de l'application (Voir pm2 config)
    autorestart: Redémarrage automatique "on fail" [true, false] (Voir pm2 config)
    watch: Pm2 scrute les modification dans le dossier de l'application [true, false] (Voir pm2 config) 
    env: Variable d'environnement de l'application
      - key: Clé de la variable
        value: Valeur de la variable
```

## git-clone
### Description
Clone un dépot git et gère les permissions sur le dossier de destination.

ATTENTION: Si le projet a déjà été cloné, l'execution du rôle une seconde fois ne mettra pas à jour (git pull) le dossier. Ca n'effacera pas non plus les modifications locale. Le dossier restera dans son état d'origine.

### Variables
``` yml
git_clone:
  - git_instance: Instance de git où se trouve le dépot [github.com, gitlab.com, ...]
    git_repository: Chemin du dépot dans l'instance [dossier/projet.git]
    destination_folder: Dossier de destination
    auth_methode: Méthode d'authentification [http,ssh]
    owner: Proprietaire à définir pour le dossier de destination (Peut-être indéfini)
    group: Groupe à définir pour le dossier de destination (Peut-être indéfini)
    mode: Permission à définir sur le dossier de destination (Peut-être indéfini)
    http_secure: Défini si la connexion http doit être sécurisé (https)[true, false]
    http_login: Login de connexion
    http_password: Mot de passe de connexion
    http_token: Token de connexion (Si mot de passe indéfini)
```

## php
### Description
Installation de php sur le serveur.

### Variables
``` yml
php_version: Version de php à installer ["8.2.1", "7.4.33", ...]
php_package: Liste des packages php à installer
  [- php-fpm
  - php-curl
  - php-gd
  - ...]
```

## python
### Description
Installation de python sur le serveur. 

### Variables
``` yml
python_version: Version de python à installer [3.9.7, 3.8.12, ...]
```
## docker
### Description

Installation de Docker sur un serveur :
- Installation des paquets pré-requis
- Ajout du repo docker dans apt 
- Installation de docker 
- Ajout de l'utilisateur ubuntu dans le groupe docker

## mattermost
### Description

Mise en place de mattermost sur le serveur.
Fonctionnalités :
- Differenciation du type d'installation [creation/restauration] :
  - Création:
    - création des groupes et utilisateurs
    - téléchargement du service
    - implémentation des fichiers de configuration
    - démarrage du service
  - Restauration  :
    - récupère le répertoire de sauvegarde
    - copie le répertoire au bon endroit
    - attribution du prop + groupe
    - démarrage du service

### Variables
``` yml
    installation_type: installe le service de 0 ou depuis des données sauvegardés (creation,script,restauration)
    user: propriétaire des répertoires Mattermost [mattermost]
    group: groupe des répertoires Mattermost [www-data]
    server_backup: serveur de sauvegarde
    ssh_key_file_path: chemin de la clé ssh permettant la connexion [/.../id_air_consulting_default2]
```

## nextcloud
### Description

Mise en place de mattermost sur le serveur.
Fonctionnalités :
- Differenciation du type d'installation [creation/restauration] :
  - Création:
    - installation de nextcloud
    - définition du propriétaire
    - installation de Nextcloud depuis la ligne de commande
    - copie du fichier config.php
    - attribution des privilèges
    - démarrage du service
  - Restauration  :
    - récupère le répertoire de sauvegarde
    - copie le répertoire au bon endroit
    - attribution du prop + groupe
    - démarrage du service

### Variables
``` yml
    installation_type: installe le service de 0 ou depuis des données sauvegardés (creation,script,restauration)
    user: propriétaire des répertoires Mattermost [mattermost]
    server_backup: serveur de sauvegarde
    ssh_key_file_path: chemin de la clé ssh permettant la connexion [/.../id_air_consulting_default2]
```


# Exemple de fichier de variable
## Exemple 1
TODO : Qu'est-ce que je fait ?
Est-ce que je crée un playbook pour chaque exemple ?

[site-configuration.conf.j2]: roles/nginx/templates/etc/nginx/sites-available/site-configuration.conf.j2