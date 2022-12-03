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
mariadb_root_password: Mot de passe du compte root (Pour plus de sécurité, à chiffrer avec ansible encrypt)
mariadb_user:
  - name: Nom de l'utilisateur à créer
    password: Mot de passe de l'utilisateur à créer
    host: [TODO]
    privilege: Droit de l'utilisateur (Voir la documentation mysql) ['*.*:ALL,GRANT', ...]

mariadb_database:
  - installation_type: Type de l'installation [creation, script]
    database_name: Nom de la base de données
    script_name: Nom du script de base de données (sans l'extension .sql)
```

## nodejs

## pm2

### Description des variables
``` yml
hostname: Nom du serveur
domain:
  - name: Nom de domaine
    certificate: 
      type: Type du certificat [certbot, openssl]
      email: email associé à la demande de certificat
  - name: lilian-test.ddns.net
    certificate: 
      # type: openssl
      type: openssl
      cn: FR
      state: France
      locality: Nancy
      company: lilian
      section: IT
      # type: certbot
      type: certbot
      email: myemail@pm.me 
```

[site-configuration.conf.j2]: roles/nginx/templates/etc/nginx/sites-available/site-configuration.conf.j2