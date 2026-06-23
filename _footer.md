<!-- TODO (before publishing to Terraform Registry): Replace the relative links below
     with absolute GitHub URLs, e.g.:
       See [CONTRIBUTING.md](https://github.com/<OWNER>/<REPO>/blob/main/CONTRIBUTING.md)
     Relative paths work on GitHub but 404 on the Terraform Registry. -->

## AVM Alignment Deviations

This module is AVM-aligned but not AVM-certified. Known deviations:

| ID | AVM Requirement | Deviation | Rationale |
|---|---|---|---|
| D1 | TFFR3 — `azurerm`/`azapi` as primary providers | `microsoft/power-platform` is the primary provider; `azurerm` and `azapi` are co-required for Azure networking | Power Platform resources are not available in `azurerm` |
| D2 | TFFR1 — `Azure/` registry namespace | Published under `rpothin/` namespace | Not eligible for AVM certification outside the `Azure/` org |
| D7 | TELEM1 — telemetry beacon | No telemetry beacon | Module is not published under `Azure/` namespace; adding `azurerm` solely for telemetry would impose an unnecessary dependency |

## Provider Version Strategy

This module uses latest-major pessimistic constraints (`~> 4.0`, `~> 2.0`) to receive non-breaking
updates automatically. Pin to a specific version in consuming configurations for full reproducibility.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## Code of Conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Support

See [SUPPORT.md](SUPPORT.md) for support information.

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
