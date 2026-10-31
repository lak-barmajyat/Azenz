SET FOREIGN_KEY_CHECKS = 0;

-- create azenz_commercial database

CREATE DATABASE IF NOT EXISTS azenz_commercial CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE azenz_commercial;

-- azenz_commercial.p_types_documents definition

CREATE TABLE `p_types_documents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code_type_document` varchar(50) NOT NULL,
  `nom_type_document` varchar(100) NOT NULL,
  `domaine` enum('VENTE','ACHAT','STOCK','INTERNE') NOT NULL,
  `sens_stock` enum('AUCUN','ENTREE','SORTIE') NOT NULL DEFAULT 'AUCUN',
  `impacte_stock` tinyint(1) NOT NULL DEFAULT 0,
  `impacte_reglement` tinyint(1) NOT NULL DEFAULT 0,
  `actif` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_type_document` (`code_type_document`)
) ENGINE=InnoDB;

-- azenz_commercial.p_numerotation_documents definition

CREATE TABLE `p_numerotation_documents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `type_document_id` bigint(20) unsigned NOT NULL,
  `prefixe` varchar(20) NOT NULL,
  `annee` int(10) unsigned NOT NULL,
  `dernier_numero` varchar(20) NOT NULL,
  `longueur_numero` int(10) unsigned NOT NULL DEFAULT 4,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_numerotation_type_annee` (`type_document_id`,`annee`),
  KEY `idx_type_document` (`type_document_id`),
  CONSTRAINT `fk_numerotation_type_document` FOREIGN KEY (`type_document_id`) REFERENCES `p_types_documents` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- azenz_commercial.p_utilisateurs definition

CREATE TABLE `p_utilisateurs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nom_utilisateur` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `telephone` varchar(30) DEFAULT NULL,
  `mot_de_passe_hash` varchar(255) NOT NULL,
  `role` enum('MANAGER','MERCHANT') NOT NULL,
  `date_derniere_connexion` datetime DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nom_utilisateur` (`nom_utilisateur`),
  KEY `idx_nom_utilisateur` (`nom_utilisateur`)
) ENGINE=InnoDB;

-- azenz_commercial.p_tvas definition

CREATE TABLE `p_tvas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code_tva` varchar(50) NOT NULL,
  `nom_tva` varchar(100) NOT NULL,
  `taux` decimal(6,3) NOT NULL DEFAULT 0.000,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_tva` (`code_tva`)
) ENGINE=InnoDB;

-- azenz_commercial.d_familles definition

CREATE TABLE `d_familles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code_famille` varchar(100) NOT NULL,
  `nom_famille` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `type_famille` enum('PRODUIT','SERVICE','NUMERIQUE','MATIERE_PREMIERE') NOT NULL,
  `suivi_stock` tinyint(1) NOT NULL DEFAULT 1,
  `tva_id` bigint(20) unsigned DEFAULT NULL,
  `cree_par` bigint(20) unsigned DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_famille` (`code_famille`),
  KEY `fk_familles_createur` (`cree_par`),
  KEY `idx_tva` (`tva_id`),
  CONSTRAINT `fk_familles_createur` FOREIGN KEY (`cree_par`) REFERENCES `p_utilisateurs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_familles_tva` FOREIGN KEY (`tva_id`) REFERENCES `p_tvas` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- azenz_commercial.d_tiers definition

CREATE TABLE `d_tiers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code_tiers` varchar(50) NOT NULL,
  `raison_sociale` varchar(255) NOT NULL,
  `nom_commercial` varchar(255) DEFAULT NULL,
  `type_tiers` enum('CLIENT','FOURNISSEUR','AUTRE') NOT NULL,
  `contact_principal` varchar(255) DEFAULT NULL,
  `telephone` varchar(30) DEFAULT NULL,
  `telephone_secondaire` varchar(30) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `adresse` varchar(500) DEFAULT NULL,
  `code_postal` varchar(20) DEFAULT NULL,
  `ville` varchar(100) DEFAULT NULL,
  `identifiant_fiscal` varchar(100) DEFAULT NULL,
  `ice` varchar(50) DEFAULT NULL,
  `rc` varchar(100) DEFAULT NULL,
  `patente` varchar(100) DEFAULT NULL,
  `cnss` varchar(100) DEFAULT NULL,
  `commentaire` text DEFAULT NULL,
  `cree_par` bigint(20) unsigned DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_tiers` (`code_tiers`),
  KEY `fk_tiers_createur` (`cree_par`),
  KEY `idx_type_tiers` (`type_tiers`),
  KEY `idx_raison_sociale` (`raison_sociale`),
  CONSTRAINT `fk_tiers_createur` FOREIGN KEY (`cree_par`) REFERENCES `p_utilisateurs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- azenz_commercial.p_informations_societe definition

CREATE TABLE `p_informations_societe` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `raison_sociale` varchar(255) NOT NULL,
  `nom_commercial` varchar(255) DEFAULT NULL,
  `activite` varchar(255) DEFAULT NULL,
  `identifiant_fiscal` varchar(100) DEFAULT NULL,
  `ice` varchar(50) DEFAULT NULL,
  `rc` varchar(100) DEFAULT NULL,
  `patente` varchar(100) DEFAULT NULL,
  `cnss` varchar(100) DEFAULT NULL,
  `adresse` varchar(500) DEFAULT NULL,
  `code_postal` varchar(20) DEFAULT NULL,
  `ville` varchar(100) DEFAULT NULL,
  `region` varchar(100) DEFAULT NULL,
  `pays` varchar(100) NOT NULL DEFAULT 'Maroc',
  `devise` CHAR(3) DEFAULT 'MAD',
  `telephone` varchar(30) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `site_web` varchar(255) DEFAULT NULL,
  `logo_url` varchar(500) DEFAULT NULL,
  `tva_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tva` (`tva_id`),
  CONSTRAINT `fk_infos_societe_tva` FOREIGN KEY (`tva_id`) REFERENCES `p_tvas` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- azenz_commercial.d_articles definition

CREATE TABLE `d_articles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code_article` varchar(100) NOT NULL,
  `designation` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `famille_id` bigint(20) unsigned DEFAULT NULL,
  `type_article` enum('PRODUIT','SERVICE','NUMERIQUE','MATIERE_PREMIERE') NOT NULL,
  `unite` varchar(30) DEFAULT NULL,
  `prix_achat_ht` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `prix_achat_ttc` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `prix_vente_ht` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `prix_vente_ttc` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `tva_id` bigint(20) unsigned DEFAULT NULL,
  `suivi_stock` tinyint(1) NOT NULL DEFAULT 1,
  `quantite_min_stock` decimal(18,4) NOT NULL DEFAULT 0.0000,
  `image_url` varchar(500) DEFAULT NULL,
  `cree_par` bigint(20) unsigned DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_article` (`code_article`),
  KEY `idx_designation` (`designation`),
  KEY `idx_code_article` (`code_article`),
  KEY `fk_articles_createur` (`cree_par`),
  KEY `idx_famille` (`famille_id`),
  KEY `idx_tva` (`tva_id`),
  CONSTRAINT `fk_articles_createur` FOREIGN KEY (`cree_par`) REFERENCES `p_utilisateurs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_articles_famille` FOREIGN KEY (`famille_id`) REFERENCES `d_familles` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_articles_tva` FOREIGN KEY (`tva_id`) REFERENCES `p_tvas` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- azenz_commercial.d_documents definition

CREATE TABLE `d_documents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `type_document_id` bigint(20) unsigned NOT NULL,
  `code_document` varchar(50) NOT NULL,
  `tier_id` bigint(20) unsigned DEFAULT NULL,
  `utilisateur_id` bigint(20) unsigned DEFAULT NULL,
  `montant_ht` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `montant_remise` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `montant_net_ht` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `montant_tva` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `montant_ttc` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `montant_net_ttc` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `montant_paye` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `montant_restant` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `status` varchar(30) NOT NULL,
  `date_document` datetime NOT NULL,
  `commentaire` text DEFAULT NULL,
  `supprime` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_document_reference` (`type_document_id`,`code_document`),
  KEY `fk_documents_utilisateur` (`utilisateur_id`),
  KEY `idx_type_document` (`type_document_id`),
  KEY `idx_tier` (`tier_id`),
  KEY `idx_statut` (`status`),
  KEY `idx_date_document` (`date_document`),
  CONSTRAINT `fk_documents_tier` FOREIGN KEY (`tier_id`) REFERENCES `d_tiers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_documents_type` FOREIGN KEY (`type_document_id`) REFERENCES `p_types_documents` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_documents_utilisateur` FOREIGN KEY (`utilisateur_id`) REFERENCES `p_utilisateurs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- azenz_commercial.d_reglements definition

CREATE TABLE `d_reglements` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `code_reglement` varchar(100) NOT NULL,
  `utilisateur_id` bigint(20) unsigned DEFAULT NULL,
  `tier_id` bigint(20) unsigned NOT NULL,
  `date_reglement` datetime NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `sens_reglement` enum('ENTREE','SORTIE') NOT NULL,
  `mode_reglement` varchar(50) DEFAULT NULL,
  `montant_total` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `montant_affecte` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `montant_restant` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `reference_piece` varchar(100) DEFAULT NULL,
  `statut_reglement` enum('BROUILLON','VALIDE','IMPUTE_PARTIEL','IMPUTE_TOTAL','ANNULE','IMPAYE') NOT NULL DEFAULT 'BROUILLON',
  `cree_par` bigint(20) unsigned DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_reglement` (`code_reglement`),
  KEY `fk_reglements_createur` (`cree_par`),
  KEY `idx_tier` (`tier_id`),
  KEY `idx_utilisateur` (`utilisateur_id`),
  KEY `idx_date_reglement` (`date_reglement`),
  KEY `idx_statut_reglement` (`statut_reglement`),
  CONSTRAINT `fk_reglements_createur` FOREIGN KEY (`cree_par`) REFERENCES `p_utilisateurs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_reglements_tier` FOREIGN KEY (`tier_id`) REFERENCES `d_tiers` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_reglements_utilisateur` FOREIGN KEY (`utilisateur_id`) REFERENCES `p_utilisateurs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- azenz_commercial.d_stock definition

CREATE TABLE `d_stock` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `article_id` bigint(20) unsigned NOT NULL,
  `quantite_stock` decimal(18,4) NOT NULL DEFAULT 0.0000,
  `date_dernier_mouvement` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_stock_article` (`article_id`),
  KEY `idx_article` (`article_id`),
  CONSTRAINT `fk_stock_article` FOREIGN KEY (`article_id`) REFERENCES `d_articles` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB;

-- azenz_commercial.d_document_lignes definition

CREATE TABLE `d_document_lignes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `document_id` bigint(20) unsigned NOT NULL,
  `numero_ligne` int(10) unsigned NOT NULL,
  `article_id` bigint(20) unsigned DEFAULT NULL,
  `code_article` varchar(100) DEFAULT NULL,
  `designation` varchar(500) DEFAULT NULL,
  `quantite` decimal(18,4) NOT NULL DEFAULT 0.0000,
  `tva_id` bigint(20) unsigned DEFAULT NULL,
  `code_tva` varchar(20) NOT NULL,
  `tva_percentage` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `prix_unitaire_ht` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `prix_unitaire_ttc` decimal(18,6) GENERATED ALWAYS AS (`prix_unitaire_ht` * (1 + `tva_percentage` / 100)) STORED,
  `unitaire_tva` decimal(18,6) GENERATED ALWAYS AS (`prix_unitaire_ht` * `tva_percentage` / 100) STORED,
  `montant_ht` decimal(18,6) GENERATED ALWAYS AS (`quantite` * `prix_unitaire_ht`) STORED,
  `montant_ttc` decimal(18,6) GENERATED ALWAYS AS (`quantite` * `prix_unitaire_ttc`) STORED,
  `montant_tva` decimal(18,6) GENERATED ALWAYS AS (`quantite` * `unitaire_tva`) STORED,
  `impact_stock` tinyint(1) NOT NULL DEFAULT 1,
  `commentaire` text DEFAULT NULL,
  `cree_par` bigint(20) unsigned DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT current_timestamp(),
  `supprime` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_document_numero_ligne` (`document_id`,`numero_ligne`),
  KEY `fk_lignes_tva` (`tva_id`),
  KEY `fk_lignes_createur` (`cree_par`),
  KEY `idx_document` (`document_id`),
  KEY `idx_article` (`article_id`),
  KEY `idx_supprime` (`supprime`),
  CONSTRAINT `fk_lignes_article` FOREIGN KEY (`article_id`) REFERENCES `d_articles` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_lignes_createur` FOREIGN KEY (`cree_par`) REFERENCES `p_utilisateurs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
   CONSTRAINT `fk_lignes_document` FOREIGN KEY (`document_id`) REFERENCES `d_documents` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_lignes_tva` FOREIGN KEY (`tva_id`) REFERENCES `p_tvas` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- azenz_commercial.d_document_reglements definition

CREATE TABLE `d_document_reglements` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `document_id` bigint(20) unsigned NOT NULL,
  `reglement_id` bigint(20) unsigned NOT NULL,
  `date_liaison` timestamp NOT NULL DEFAULT current_timestamp(),
  `montant_affecte` decimal(18,6) NOT NULL DEFAULT 0.000000,
  `type_affectation` enum('REGLEMENT','ACOMPTE','AVANCE','AVOIR') NOT NULL DEFAULT 'REGLEMENT',
  `cree_par` bigint(20) unsigned DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_document_reglement` (`document_id`,`reglement_id`),
  KEY `fk_document_reglements_createur` (`cree_par`),
  KEY `idx_document` (`document_id`),
  KEY `idx_reglement` (`reglement_id`),
  KEY `idx_date_liaison` (`date_liaison`),
  KEY `idx_type_affectation` (`type_affectation`),
  CONSTRAINT `fk_document_reglements_createur` FOREIGN KEY (`cree_par`) REFERENCES `p_utilisateurs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_document_reglements_document` FOREIGN KEY (`document_id`) REFERENCES `d_documents` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_document_reglements_reglement` FOREIGN KEY (`reglement_id`) REFERENCES `d_reglements` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- azenz_commercial.d_mouvements_stock definition

CREATE TABLE `d_mouvements_stock` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `article_id` bigint(20) unsigned NOT NULL,
  `document_id` bigint(20) unsigned DEFAULT NULL,
  `document_ligne_id` bigint(20) unsigned DEFAULT NULL,
  `type_mouvement` enum('ENTREE','SORTIE','AJUSTEMENT','INVENTAIRE') NOT NULL,
  `sens_mouvement` enum('IN','OUT') NOT NULL,
  `quantite` decimal(18,4) NOT NULL,
  `date_mouvement` datetime NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `cree_par` bigint(20) unsigned DEFAULT NULL,
  `date_creation` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_mouvements_createur` (`cree_par`),
  KEY `idx_article` (`article_id`),
  KEY `idx_document` (`document_id`),
  KEY `idx_document_ligne` (`document_ligne_id`),
  KEY `idx_type_mouvement` (`type_mouvement`),
  KEY `idx_date_mouvement` (`date_mouvement`),
  CONSTRAINT `fk_mouvements_article` FOREIGN KEY (`article_id`) REFERENCES `d_articles` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_mouvements_createur` FOREIGN KEY (`cree_par`) REFERENCES `p_utilisateurs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_mouvements_document` FOREIGN KEY (`document_id`) REFERENCES `d_documents` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_mouvements_document_ligne` FOREIGN KEY (`document_ligne_id`) REFERENCES `d_document_lignes` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;