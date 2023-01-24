# Collections à installer
- community.mysql
- weareinteractive.vsftpd
- sansible.ssmtp

```
ansible-galaxy collection install -r requirements.yml
```

# Rôles disponible
- [base-serveur](#base-serveur)
- [parefeu](#parefeu)
- [certbot](#certbot)
- [nginx](#nginx)
- [ftp](#ftp)
- [mariadb](#mariadb)
- [nodejs](#nodejs)
- [pm2](#pm2)
- [git-clone](#git-clone)
- [php](#php)

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
mariadb_install_server: Installation du serveur mariadb [true, false]
mariadb_root_password: Mot de passe du compte root (Pour plus de sécurité, à chiffrer avec ansible encrypt)
mariadb_user:
  - name: Nom de l'utilisateur à créer
    password: Mot de passe de l'utilisateur à créer
    host: Le 'host' de l'utilisateur à créer
    privilege: Droit de l'utilisateur (Voir la documentation mysql) ['*.*:ALL,GRANT', ...]

mariadb_database:
  - installation_type: Type de l'installation [creation, script]
    database_name: Nom de la base de données
    script_name: Nom du script de base de données (sans l'extension .sql)
```

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
```

# Exemple de fichier de variable
## Exemple 1
TODO : Qu'est-ce que je fait ?
Est-ce que je crée un playbook pour chaque exemple ?

[site-configuration.conf.j2]: roles/nginx/templates/etc/nginx/sites-available/site-configuration.conf.j2