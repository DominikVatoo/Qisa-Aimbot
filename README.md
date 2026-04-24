# FiveM Aimbot Script

Standalone Aimbot für FiveM mit optionaler ESX/QBCore Unterstützung.

## Wichtig

**Cheaten ist nicht cool.** Dieses Script ist ausschließlich für private Testserver gedacht, um Mechaniken zu testen oder Bugs zu finden. Nutze es nicht auf öffentlichen Servern - das ruiniert anderen Spielern den Spaß und führt zu Bans. Respektiere die Regeln der Server auf denen du spielst.

## Installation

1. Ordner in deinen resources Ordner packen
2. `config.lua` nach deinen Wünschen anpassen
3. In `server.cfg` eintragen:
   ```
   ensure qisa_aimbot
   ```
4. Server neustarten

## Config anpassen

In der `config.lua` kannst du alles einstellen:

```lua
Config.Framework = "esx"              -- "esx", "qbcore" oder "standalone"
Config.UsePermissions = true          -- false = jeder kann es nutzen
Config.AdminGroups = {"admin"}  -- welche Gruppen Zugriff haben
Config.MenuCommand = "ab"             -- Command fürs Menü
Config.MaxDistance = 250.0            -- maximale Reichweite
Config.CheckLineOfSight = true        -- nur sichtbare Ziele
```

## Commands

**Menü öffnen:**
- `/ab`

**Chat Commands (wenn kein ESX Menü):**
- `/aimbot toggle` - An/Aus
- `/aimbot smooth [0.0-1.0]` - Smoothness einstellen
- `/aimbot fov [5-180]` - FOV einstellen

## Dependencies

Keine zwingend nötig. Optional:
- `es_extended` für ESX Menü
- `qb-core` für QBCore
- `hex_2_hud` für Notifications (oder eigenes in config eintragen)

## Lizenz

Nur für privaten Gebrauch auf Testservern.
