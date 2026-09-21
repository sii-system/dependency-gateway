# cli/

Entry point CLI funnel (`__main__.py` and the console_scripts point here).
Dependency direction: cli → all other layers.

- `main.py`: the `dependency-gateway` / `python -m dependency_gateway` server entry
  point (formerly `cli.py`).
- `inventory.py`: `dependency-gateway-inventory` (formerly `inventory_cli.py`).
- `stats.py`: `dependency-gateway-stats` (formerly `stats_cli.py`).

The `dependency-gateway-prepare` entry point lives in `harbor_tasks/preparer/cli.py` (the preparation
tooling belongs to harbor_tasks).
