from __future__ import annotations

import hashlib
import importlib
import unittest

MODULE_PREFIX = "dependency_gateway"


def _script_sha256(dotted: str) -> str:
    module = importlib.import_module(f"{MODULE_PREFIX}.{dotted}")
    return hashlib.sha256(module._RESOLVER_SCRIPT.encode("utf-8")).hexdigest()


def _asset_sha256(name: str) -> str:
    importlib.import_module(f"{MODULE_PREFIX}.ui.webui")
    from dependency_gateway.ui import webui

    return hashlib.sha256(getattr(webui, name)).hexdigest()


class ExtractedResolverScriptTest(unittest.TestCase):
    """Hash guard for the extracted resolver script resources (sha256 pinned against pre/post refactor)."""

    def test_apt_resolver_script_unchanged(self) -> None:
        self.assertEqual(
            _script_sha256(
                "harbor_tasks.preparer.providers.apt.resolver"
            ),
            "d421e1c640719958565faca9b0ace8577b8e2ecfb77f12d2efe4f9ccdd2176a3",
        )

    def test_pip_resolver_script_unchanged(self) -> None:
        self.assertEqual(
            _script_sha256(
                "harbor_tasks.preparer.providers.pip.resolver"
            ),
            "2bacf251d2dc45e0b61cb13a56b5ac01f3eae2465b49c1a96608e3cf4e373bd2",
        )

    def test_npm_resolver_script_unchanged(self) -> None:
        self.assertEqual(
            _script_sha256("harbor_tasks.preparer.providers.npm"),
            "abcc8429ce304ff3d049e9fd59b5f123393556a297f114fc8f63750b91ef693f",
        )


class ExtractedWebUIAssetTest(unittest.TestCase):
    """Hash guard for the extracted ui/static asset (sha256 pinned against pre/post refactor)."""

    def test_index_html_unchanged(self) -> None:
        self.assertEqual(
            _asset_sha256("_INDEX"),
            "7ecfea15b425c9d9ea44bb62e483105a64d48450c73d853fbec092e1c73e3acf",
        )

    def test_styles_css_unchanged(self) -> None:
        self.assertEqual(
            _asset_sha256("_STYLES"),
            "b674ad556e5061617834d7f7b9bb5073bb71166d3fbb1ae005e5aea0eaa7e0f2",
        )

    def test_app_js_unchanged(self) -> None:
        self.assertEqual(
            _asset_sha256("_APP"),
            "ebdffbaf2cf35c91ba79ff13336d2479354ec88a120c051d0b986493cf803981",
        )


if __name__ == "__main__":
    unittest.main()
