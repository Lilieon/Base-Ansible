# Collections à installer
- community.mysql
- weareinteractive.vsftpd
- sansible.ssmtp

```
ansible-galaxy collection install -r requirements.yml
```

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

## certbot

## ftp

## mariadb

## nginx

## nodejs

## parefeu

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
      type: openssl
      cn: FR
      state: France
      locality: Nancy
      company: lilian
      section: IT
```