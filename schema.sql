-- ══════════════════════════════════════════
-- SCHEMA — Médecine du Sport DIU
-- À exécuter dans Supabase > SQL Editor
-- ══════════════════════════════════════════

-- Table des régions anatomiques
CREATE TABLE IF NOT EXISTS regions (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE,
  icon        TEXT NOT NULL DEFAULT '📁',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Table des fiches pathologies
CREATE TABLE IF NOT EXISTS fiches (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  region_name  TEXT NOT NULL REFERENCES regions(name) ON UPDATE CASCADE ON DELETE CASCADE,
  name         TEXT NOT NULL,
  subtitle     TEXT DEFAULT '',
  epidemio     TEXT DEFAULT '',
  clinique     TEXT DEFAULT '',
  imagerie     TEXT DEFAULT '',
  pec          TEXT DEFAULT '',
  notes        TEXT DEFAULT '',
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour les recherches par région
CREATE INDEX IF NOT EXISTS idx_fiches_region ON fiches(region_name);

-- Trigger pour updated_at automatique
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER fiches_updated_at
  BEFORE UPDATE ON fiches
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ══════════════════════════════════════════
-- SÉCURITÉ : accès public lecture/écriture
-- (pour usage personnel — pas de compte utilisateur)
-- Si tu veux sécuriser plus tard, active l'auth Supabase
-- ══════════════════════════════════════════
ALTER TABLE regions ENABLE ROW LEVEL SECURITY;
ALTER TABLE fiches  ENABLE ROW LEVEL SECURITY;

-- Politique : accès total via la clé anon (usage personnel)
CREATE POLICY "Accès total regions" ON regions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Accès total fiches"  ON fiches  FOR ALL USING (true) WITH CHECK (true);
