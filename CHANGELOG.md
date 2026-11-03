# Changelog

## v1.2.0

- Ported to SPT 4.1.x (built and tested against SPT 4.1.6 / EFT 0.16.9.5.40743, .NET 10).
- `AbstractModMetadata` -> `IModMetadata`, `IsBundleMod` dropped (bundles are declared by `bundles.json`).
- `IOnLoad.OnLoad` -> `OnLoadAsync(CancellationToken)`; runs at `OnLoadOrder.Preload + 1` because SPT 4.1.3+ refuses to add items once profiles have loaded.
- `DatabaseService` -> `TemplateTable` / `TradersTable`.
- `CustomItemService.CreateItemFromClone` takes the calling `Assembly`; `NewItemName` is required.
- Namespace moves: `Services.Locales.LocaleService`, `Services.Modding.Custom.CustomItemService`, `Common.Models.Logging.ISptLogger<T>`.
- Mod files live in `SPT_Runtime/user/mods/DPX-ElectronicsCase` on SPT 4.1.x.

## v1.1.0

- Added config/config.json.
- Added configurable external case size.
- Added configurable internal grid size.
- Added configurable price.
- Added configurable accepted categories and items.
- Added configurable trader and loyalty level.
- Kept Electronics category as default filter.
- Icon/model are not configurable.

## v1.0.1

- Added the full Electronics category to the internal case whitelist.
- Kept the existing explicit electronics item IDs as fallback entries.

## v1.0.0

- Initial release.
- Added DPX Electronics Case.
- Added custom graphite/PCB texture.
- Added Skier LL1 offer.
- Added strict electronics whitelist.
