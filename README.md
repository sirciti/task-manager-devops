# task-manager-devops

### Étape 0 : Installation de Terraform

#### Objectifs atteints :
- Installation réussie de Terraform sur Windows.
- Configuration du PATH pour exécuter Terraform depuis n'importe quel répertoire.

#### Difficultés rencontrées :
- Problème avec les permissions administratives lors de l'installation manuelle.
- Solution : Utilisation de Chocolatey pour simplifier le processus.

#### Résultats :
- Terraform installé et fonctionnel : `terraform --version` retourne v1.11.1(de nos jours)


étape suivante : 
Activer le volume pour la persistance
Décommentez la section volumes dans votre configuration main.tf

Problème rencontré et solution :
Lors de la mise en place d'une infrastructure Docker avec Terraform, plusieurs erreurs ont été rencontrées :

Erreur de syntaxe dans le fichier main.tf :

Une virgule manquante ou mal placée dans la liste des variables d'environnement.

Message d'erreur :

text
Error: Missing item separator
Conflit de port avec PostgreSQL :

Le port 5432 était déjà utilisé par un autre processus ou conteneur.

Message d'erreur :

text
Bind for 0.0.0.0:5432 failed: port is already allocated
Problème avec le provider Docker :

La version verrouillée du provider ne correspondait pas à la version spécifiée dans provider.tf.

Message d'erreur :

text
Failed to query available provider packages
Étapes de résolution :
1. Correction de la syntaxe dans main.tf
Problème : Une virgule manquante dans la liste des variables d'environnement.

Solution : Ajout de la virgule manquante après "POSTGRES_DB=mydatabase".

Commandes utilisées pour diagnostiquer et appliquer les corrections :

bash
terraform validate  # Vérifie la syntaxe du fichier Terraform
terraform apply     # Applique les modifications
2. Résolution du conflit de port
Problème : Le port 5432 était déjà utilisé.

Solution : Libération du port en identifiant et supprimant le processus ou conteneur bloquant.

Commandes utilisées :

bash
docker ps -a                     # Liste tous les conteneurs
docker stop postgres_test        # Arrête le conteneur problématique
docker rm postgres_test          # Supprime le conteneur problématique
netstat -ano | findstr :5432     # Identifie les processus utilisant le port
taskkill /PID <PID> /F           # Termine le processus bloquant (Windows)
3. Mise à jour du provider Docker
Problème : Version verrouillée incompatible avec la configuration.

Solution : Mise à jour du provider avec la commande suivante :

bash
terraform init -upgrade          # Met à jour les providers Terraform
terraform apply                  # Applique les modifications
Commandes utilisées pour vérifier le bon fonctionnement
Vérification des conteneurs actifs :

bash
docker ps                       # Liste les conteneurs actifs
Connexion à PostgreSQL :

bash
docker exec -it postgres_server psql -U admin -d mydatabase
Test de Nginx :
Ouvrez http://localhost:8080 dans votre navigateur.

Leçons apprises
Toujours lire attentivement les messages d'erreur pour identifier rapidement la source du problème.

Utiliser des commandes comme terraform validate, docker ps, et netstat pour diagnostiquer efficacement.

Documenter chaque étape pour faciliter la résolution future.

***

## Redémarrage des conteneurs

Pour redémarrer proprement les conteneurs et libérer les ports, exécutez le script suivant :

./restart_containers.sh

Cela garantit que les conteneurs sont arrêtés proprement avant d'être relancés.
Avantages :
Automatisation simple et efficace.

Évite les conflits de ports.

Préserve la persistance des données grâce aux volumes Docker.

pour la phase de mise en place et de test, ce script est pratique et adapté.

Mise à jour du README.md pour documenter la vérification de PostgreSQL :

## Vérification des données PostgreSQL

Pour vérifier que les données sont bien persistées après le redémarrage des conteneurs :

1. Connectez-vous à PostgreSQL :
docker exec -it task-manager-devops-postgres-1 psql -U admin -d mydatabase


2. Exécutez la commande SQL suivante pour afficher les données de la table `test_table` :
SELECT * FROM test_table;


Vous devriez voir les données suivantes si tout fonctionne correctement :
id | name
----+---------
1 | Alice
2 | Bob
3 | Charlie
(3 rows)

Étapes de test pour confirmer que tout fonctionne avec la nouvelle commande down && up et la persistance des données :
Redémarrer les conteneurs avec la commande :


./restart_containers.sh
Vérifier l'état des conteneurs :


docker ps
Assurez-vous que les conteneurs PostgreSQL et Nginx sont actifs et que les ports sont correctement mappés.

Tester la persistance des données PostgreSQL :

Connectez-vous à PostgreSQL :


docker exec -it task-manager-devops-postgres-1 psql -U admin -d mydatabase
Exécutez la commande SQL pour vérifier les données :


SELECT * FROM test_table;
Vous devriez voir les données précédemment insérées (Alice, Bob, Charlie).

Tester l'accès à Nginx :

Accédez à http://localhost:8080 dans votre navigateur.

Vérifiez que la page personnalisée s'affiche correctement.

Confirmer les logs et erreurs (optionnel) :

Vérifiez les logs de PostgreSQL et Nginx pour vous assurer qu'il n'y a pas d'erreurs :


docker logs task-manager-devops-postgres-1
docker logs task-manager-devops-nginx-1
Résultat attendu :
Les données dans PostgreSQL sont persistantes après le redémarrage.

La page Nginx est accessible sans erreur.

à ce niveau 
Si tout est correct, vous pouvez considérer votre configuration comme validée !


Documentation des étapes et résolution des problèmes
1. Mise en place initiale
Configuration des services Docker avec docker-compose.yml :

Nginx : Pour servir du contenu statique.

PostgreSQL : Pour la base de données.

Création des volumes pour la persistance des données.

2. Problèmes rencontrés
Problème 1 : Permissions sur le volume PostgreSQL sous Windows
Message d'erreur :

chmod: changing permissions of '/var/lib/postgresql/data/pgdata': Operation not permitted
Cause : Conflit de permissions entre le système de fichiers Windows et Docker.

Solution :

Remplacement du montage local par un volume nommé dans docker-compose.yml :


volumes:
  - postgres_data:/var/lib/postgresql/data
Problème 2 : Table manquante dans PostgreSQL
Message d'erreur :


ERROR: relation "test_table" does not exist
Cause : La table test_table n'avait pas encore été créée.

Solution : Création manuelle de la table et insertion des données :


docker exec -it task-manager-devops-postgres-1 psql -U admin -d mydatabase
Dans la console PostgreSQL :


CREATE TABLE test_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);
INSERT INTO test_table (name) VALUES ('Alice'), ('Bob'), ('Charlie');
3. Commandes utilisées pour diagnostiquer et résoudre les problèmes
Vérification des conteneurs actifs :

docker ps
Logs des conteneurs pour identifier les erreurs :

docker logs <container_name>
Accès à PostgreSQL pour exécuter des commandes SQL :

docker exec -it task-manager-devops-postgres-1 psql -U admin -d mydatabase
Suppression des volumes problématiques :

rm -rf ./data/postgres/*
docker-compose down -v && docker-compose up -d
4. Automatisation et sécurisation
Ajout d'un pipeline CI/CD avec GitHub Actions pour automatiser les tests et le déploiement.

Sécurisation des variables sensibles avec un fichier .env :


POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123
POSTGRES_DB=mydatabase


changement pour GCP

# Configuration Terraform sur Google Cloud Platform (GCP)

Ce document décrit les étapes suivies pour configurer Terraform sur Google Cloud Platform (GCP), ainsi que les problèmes rencontrés et les solutions mises en œuvre.

## Étapes initiales

1.  **Authentification avec le compte Google Cloud :**

    *   Assurez-vous que le compte `account.discovery@dev.devoteam.com` est authentifié avec la Google Cloud CLI :

        ```
        gcloud auth login account.discovery@dev.devoteam.com
        ```
    *   Définissez le projet actif :

        ```
        gcloud config set project discovery-452411
        ```

2.  **Configuration du projet Terraform :**

    *   Créez ou modifiez le fichier `main.tf` avec la configuration de votre infrastructure.
    *   Définissez les variables nécessaires dans un fichier `terraform.tfvars` ou `variables.tf`.

## Configuration du backend GCS (Google Cloud Storage)

1.  **Création du bucket GCS :**

    *   Si aucun bucket n'existe, créez-en un pour stocker l'état Terraform :

        *   Via la console GCP ou via la CLI :

            ```
            gsutil mb -l <REGION> gs://<YOUR_BUCKET_NAME>
            ```

            Remplacez `<REGION>` par la région souhaitée (par exemple, `us-central1`) et `<YOUR_BUCKET_NAME>` par un nom de bucket unique (par exemple, `my-terraform-bucket-state`).
    *   Assurez-vous que la **Prévention de l'accès public** est **activée** pour plus de sécurité.

2.  **Configuration du backend dans `backend.tf` :**

    *   Ajoutez ou modifiez le fichier `backend.tf` pour configurer le backend GCS :

        ```
        terraform {
          backend "gcs" {
            bucket = "my-terraform-bucket-state"
            prefix = "terraform/state"
          }
        }
        ```

        Remplacez `"my-terraform-bucket-state"` par le nom de votre bucket.

## Problèmes rencontrés et solutions

1.  **Erreur d'autorisation : `... does not have storage.objects.list access to the Google Cloud Storage bucket`**

    *   **Problème :** Terraform utilise un compte incorrect ou n'a pas les permissions nécessaires pour accéder au bucket GCS.
    *   **Solutions :**
        *   Vérifiez et configurez les **Application Default Credentials (ADC)** :

            ```
            gcloud auth list
            gcloud config set account account.discovery@dev.devoteam.com
            gcloud auth application-default login
            ```
        *   Assurez-vous que le compte a le rôle **`roles/storage.objectAdmin`** sur le bucket :

            ```
            gcloud storage buckets add-iam-policy-binding gs://my-terraform-bucket-state --member="user:account.discovery@dev.devoteam.com" --role="roles/storage.objectAdmin"
            ```
        *   Définissez la variable d'environnement `GOOGLE_APPLICATION_CREDENTIALS` :

            ```
            $env:GOOGLE_APPLICATION_CREDENTIALS = "C:\Users\lmaum\AppData\Roaming\gcloud\application_default_credentials.json"
            ```

2.  **Erreur d'URI GCS incorrect : `"gcloud storage buckets ..."` only accepts Google Cloud Storage URLs.**

    *   **Problème :** Les commandes `gcloud storage buckets` nécessitent l'utilisation de l'URI GCS complet (`gs://<bucket_name>`).
    *   **Solution :** Utilisez l'URI GCS complet dans les commandes :

        ```
        gcloud storage buckets add-iam-policy-binding gs://my-terraform-bucket-state ...
        ```

## Initialisation de Terraform

1.  Exécutez la commande `terraform init` pour initialiser le backend et télécharger les plugins nécessaires :

    ```
    terraform init
    ```

    Répondez `"yes"` lorsque Terraform vous demande si vous souhaitez migrer l'état local vers le backend GCS.

## Prochaines étapes

*   Exécutez `terraform plan` pour vérifier les changements à appliquer.
*   Exécutez `terraform apply` pour provisionner les ressources sur GCP.


## Copier un fichier local vers un bucket GCS

1. Assurez-vous que le fichier à copier existe dans le répertoire actuel ou spécifiez son chemin complet.
2. Utilisez la commande suivante pour copier un fichier local vers un bucket GCS :
    ```
    gsutil cp <fichier_local> gs://<nom_du_bucket>/
    ```
    Exemple :
    ```
    gsutil cp test-file.txt gs://my-terraform-bucket-state/
    ```

3. Si vous rencontrez une erreur comme :
    ```
    CommandException: No URLs matched: test-file.txt
    ```
    Cela signifie que le fichier n'existe pas dans le répertoire actuel. Naviguez vers le bon répertoire ou spécifiez le chemin complet du fichier.

4. Une fois la commande réussie, vous verrez une confirmation comme :
    ```
    Copying file://test-file.txt [Content-Type=text/plain]...
    - [1 files][   28.0 B/   28.0 B]
    Operation completed over 1 objects/28.0 B.
    ```

5. Vérifiez que le fichier est bien présent dans votre bucket via la console GCP ou avec :
    ```
    gsutil ls gs://<nom_du_bucket>/
    ```


# Déploiement Terraform sur Google Cloud Platform (GCP)

Ce document décrit les étapes suivies pour configurer et déployer une infrastructure avec Terraform sur GCP, ainsi que les problèmes rencontrés et leurs solutions.

---

## Étapes de configuration

### 1. Initialisation du projet
- Assurez-vous que le projet Google Cloud est correctement configuré.
- Identifiez le **Project ID** : `discovery-452411`.

### 2. Création d'un compte de service
- Créez un compte de service nommé `service_account_manager`.
- Attribuez-lui le rôle **Storage Object Admin** pour accéder au bucket GCS utilisé par Terraform.

### 3. Téléchargement de la clé JSON
- Téléchargez la clé JSON associée au compte de service :
  - Accédez à **IAM & Admin > Comptes de service** dans la console GCP.
  - Ajoutez une clé JSON via l'onglet **Clés**.
  - Placez cette clé dans le répertoire suivant :  
    `I:\task-manager-devops\infra\terraform\service-account-key.json`.

---

## Problèmes rencontrés et solutions

### Erreur : Fichier de clé JSON manquant
- **Problème :** Terraform ne trouvait pas le fichier JSON (`path/to/your/service-account-key.json`).
- **Solution :** Téléchargez la clé JSON, placez-la dans le répertoire Terraform, puis mettez à jour `provider.tf` :
provider "google" {
credentials = file("I:/task-manager-devops/infra/terraform/service-account-key.json")
project = var.project_id
region = var.region
zone = var.zone
}


### Erreur : Variable `ssh_user` non déclarée
- **Problème :** Une variable non déclarée était référencée dans `terraform.tfvars`.
- **Solution :** Ajoutez la déclaration suivante dans `variables.tf` :
variable "ssh_user" {
description = "Nom de l'utilisateur SSH pour les VMs"
type = string
}


### Erreur : Référence à une ressource non définie (`docker_container.nginx`)
- **Problème :** Une sortie faisait référence à une ressource Docker inexistante.
- **Solution :** Supprimez ou corrigez l'entrée correspondante dans `outputs.tf` :
Supprimer ou corriger cette ligne si Docker n'est pas utilisé
output "nginx_container_id" {
value = docker_container.nginx.id
}


---

## Commandes clés utilisées

### Initialisation de Terraform
terraform init


### Planification des modifications
terraform plan


### Application des modifications
terraform apply


### Vérification des ressources sur GCP
- Listez les instances créées :
gcloud compute instances list

- Testez l'accès SSH à une VM :
gcloud compute ssh <nom_instance> --zone=<zone>


---

## Bonnes pratiques

1. **Exclusion des fichiers sensibles :**
 - Ajoutez le fichier `service-account-key.json` au `.gitignore` pour éviter qu'il ne soit versionné.
 - Exemple d'entrée `.gitignore` :
   ```
   service-account-key.json
   terraform.tfstate*
   ```

2. **Validation des ressources :**
 - Vérifiez que toutes les ressources sont correctement créées dans la console GCP.

---

## Prochaines étapes

1. Ajouter des tests pour valider les services (VMs, bases de données, etc.).
2. Automatiser les déploiements avec un pipeline CI/CD.
3. Optimiser la sécurité en utilisant des outils comme HashiCorp Vault pour gérer les secrets.


Documentation des étapes et résolution des problèmes

Problème rencontré
Lors de l'exécution de terraform plan, nous avons rencontré des erreurs d'autorisation (403 Forbidden) indiquant que le compte de service utilisé par Terraform n'avait pas les permissions nécessaires pour accéder ou gérer certaines ressources sur Google Cloud Platform (GCP).

Diagnostic
Les erreurs spécifiques incluaient :

Manque de permission storage.buckets.get sur le bucket GCS

Manque de permission compute.instances.get sur l'instance Compute Engine

Manque de permission compute.firewalls.get sur la règle de pare-feu

Erreur notAuthorized sur l'instance Cloud SQL

Solution
Nous avons ajouté les rôles IAM nécessaires au compte de service utilisé par Terraform :

PowerShell admin:

gcloud projects add-iam-policy-binding discovery-452411 `
    --member="serviceAccount:1099497021022-compute@developer.gserviceaccount.com" `
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding discovery-452411 `
    --member="serviceAccount:1099497021022-compute@developer.gserviceaccount.com" `
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding discovery-452411 `
    --member="serviceAccount:1099497021022-compute@developer.gserviceaccount.com" `
    --role="roles/cloudsql.admin"
Vérification
Nous avons vérifié l'attribution des rôles avec :

gcloud projects get-iam-policy discovery-452411
Résultat
Après avoir ajouté les permissions nécessaires, terraform plan et terraform apply ont fonctionné correctement, permettant la mise à jour de l'instance Cloud SQL.

Leçons apprises
Importance de bien comprendre les messages d'erreur pour un diagnostic précis.

Nécessité d'attribuer les bonnes permissions IAM pour le bon fonctionnement de Terraform avec GCP.

Avantage de GCP : gestion fine des permissions IAM pour un contrôle précis des accès.


##  Implémentation de Terraform pour la création d'infrastructure : ✅ Réalisée avec succès.

# Documentation des étapes et résolution des problèmes

## Étape réalisée : Implémentation de Terraform pour la création d'infrastructure

### Objectif
Configurer une infrastructure Google Cloud à l'aide de Terraform, incluant :
- Une instance Compute Engine avec Docker préinstallé.
- Une base de données Cloud SQL PostgreSQL.
- Un réseau VPC avec peering.


### Problèmes rencontrés et solutions

#### **1. Activation des APIs nécessaires**
**Problème :** Certaines APIs Google Cloud (comme Service Networking) n'étaient pas activées, ce qui a généré des erreurs lors de l'exécution de `terraform apply`.

**Solution :**
Commandes utilisées pour activer les APIs :

gcloud services enable servicenetworking.googleapis.com --project=discovery-452411
gcloud services enable cloudresourcemanager.googleapis.com --project=discovery-452411


#### **2. Permissions insuffisantes pour le compte de service**
**Problème :** Le compte de service utilisé n'avait pas les permissions nécessaires pour effectuer le peering réseau.

**Solution :**
Commandes utilisées pour attribuer les rôles nécessaires :

gcloud projects add-iam-policy-binding discovery-452411
--member="serviceAccount:1099497021022-compute@developer.gserviceaccount.com"
--role="roles/compute.networkAdmin"
gcloud projects add-iam-policy-binding discovery-452411
--member="serviceAccount:1099497021022-compute@developer.gserviceaccount.com"
--role="roles/servicenetworking.serviceAgent"

#### **3. Messages d'erreur interprétés et résolus**
**Exemple d'erreur :**

Error: googleapi: Error 403: Permission denied to add peering for service 'servicenetworking.googleapis.com'.


**Interprétation :** Le compte de service n'avait pas les permissions `servicenetworking.services.addPeering`.

**Solution appliquée :** Attribution du rôle `roles/servicenetworking.serviceAgent` au compte de service.

### Commandes clés utilisées
Voici un résumé des commandes exécutées pour diagnostiquer et résoudre les problèmes :
1. **Initialisation Terraform :**

terraform init -migrate-state

2. **Planification des modifications :**

terraform plan

3. **Application des modifications :**

### Résultat final
L'infrastructure a été déployée avec succès :
- Instance Compute Engine opérationnelle avec Docker.
- Base de données PostgreSQL configurée.
- Peering réseau activé via Service Networking API.

### Remarque importante
Pour éviter les erreurs, il est essentiel de bien comprendre les messages d'erreur et de vérifier les permissions IAM ainsi que l'état des APIs activées sur Google Cloud.
