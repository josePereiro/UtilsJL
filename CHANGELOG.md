# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- `PlotsUtils`: rename `mysavefig` to `sfig`.

- `ProjAssistant`: Redefined save/load cache functions. Use a `Vector{AbstractString}` argument for
signaling a directory to join. Move away from [DrWatson] `tagsave`, `tag!` is now the only remaining dep.
Add proj generator macros.

- `GeneralUtils`: [WIP] add `IterChunck` iterator implementation.
`get_chunks` was reimplemented and renamed to `chuncks(iter::Vector)`. Move `DictTree` from `ProjAssistant`.

### Added

- `ProjAssistant`: Project generator functions now includes project specific save/load general and cache data functions.

- `ProjAssistant`: Project generator functions tests added.

## [0.8.0] - 2021-06-24 [YANKED]

This versions had several bugs at `ProjAssistant` module.
### Added

- Added `channel_utils` into `DistributedUtils`.

### Changed

- Move from [DrWatson] `savename` functionality to [DataFileNames].
- Major API renaming into `ProjAssistant` save/load and `gen_proj_utils`, make all [DataFileNames] API compliance.
- Separate code into modules. Such modules might resemble a future package.
- Use [Requires.jl] for preventing `PlotUtils` and `DistributedUtils`
from loading unnecessarily.
- `DistributedUtils`'s `set_MASTERW` now works for many workers (default all)

## [0.7.1]

- Start the `CHANGELOG`

<!-- LINKS -->
[Unreleased]: https://github.com/josePereiro/UtilsJL/compare/v0.8.0...HEAD
<!-- [0.8.0]: https://github.com/josePereiro/UtilsJL/releases/tag/v0.8.0 -->
[0.8.0]: https://github.com/josePereiro/UtilsJL/compare/v0.7.1...v0.8.0
[0.7.1]: https://github.com/josePereiro/UtilsJL/compare/v0.2.0...v0.7.1
[Requires.jl]: https://github.com/JuliaPackaging/Requires.jl
[DrWatson]: https://github.com/JuliaDynamics/DrWatson.jl
[DataFileNames]: https://github.com/josePereiro/DataFileNames.jl
[UtilsJL]: https://github.com/josePereiro/UtilsJL