"""Shared engine package definitions (single home for `_HIT_RATE_LOGGER`)."""

from __future__ import annotations

import logging


_HIT_RATE_LOGGER = logging.getLogger("dependency_gateway.hit_rate")
