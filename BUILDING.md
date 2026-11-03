# Building DPX-ElectronicsCase against a local SPT 4.1.x server

Server mod only: one SDK-style project (`net10.0`) compiled against the SPT
server assemblies. SPT 4.1.x runs on .NET 10.

## Requirements

* .NET 10 SDK (`winget install Microsoft.DotNet.SDK.10`)
* SPT 4.1.x installation with `SPT_Runtime\SPTarkov.Server.Core.dll`

The AssetBundle, `bundles.json` and the default `config/config.json` are part of
this repository, so a clone builds a complete, installable mod.

## Path configuration

`$(SptRoot)` must point at the folder holding `SPTarkov.Server.Core.dll`:

```
dotnet build DPX-ElectronicsCase.csproj -c Release /p:SptRoot="D:\Games\SPT 4.1.6 essential\SPT_Runtime"
```

## Build and install

```
powershell -ExecutionPolicy Bypass -File build-spt.ps1
```

Options: `-SptRoot`, `-Package` (writes `build\DPX-ElectronicsCase-v<version>.zip`),
`-SkipDeploy`. Refuses to deploy while `SPT.Server` is running and never
overwrites an existing `config\config.json`.

## Install layout (SPT 4.1.x)

```
SPT_Runtime\user\mods\DPX-ElectronicsCase\
├── DPX-ElectronicsCase.dll
├── bundles.json
├── package.json
├── bundles\dpx\electronics_case.bundle
└── config\config.json      (defaults; edit for size/grid/price/trader/filter)
```

## SPT 4.1 API notes for this port

| 4.0 | 4.1 |
| --- | --- |
| `AbstractModMetadata` (+ `IsBundleMod`) | `IModMetadata`; bundles via `bundles.json` |
| `Task OnLoad()` | `Task OnLoadAsync(CancellationToken)` |
| `OnLoadOrder.PostDBModLoader` | `OnLoadOrder.Preload` for item/trader data — 4.1.3+ throws if items are added after profiles load |
| `DatabaseService.GetItems()` | `templateTable.Items` |
| `DatabaseService.GetHandbook()` | `templateTable.Handbook` |
| `DatabaseService.GetTrader(id)` | `tradersTable.GetTrader(id)` |
| `CustomItemService.CreateItemFromClone(details)` | `(details, Assembly)`; `NewItemName` is required |
| `Services.Mod.CustomItemService` | `Services.Modding.Custom.CustomItemService` |
| `Services.LocaleService` | `Services.Locales.LocaleService` |
| `Models.Utils.ISptLogger<T>` | `SPTarkov.Common.Models.Logging.ISptLogger<T>` (needs a `SPTarkov.Common` reference) |

Target framework `net9.0` → `net10.0`: the 4.1.6 server assemblies reference
`System.Runtime` 10.
