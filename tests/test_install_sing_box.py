from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path


INSTALLER = Path(__file__).resolve().parents[1] / "scripts" / "install_ci_sing_box.sh"


class SingBoxInstallerTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.commands = self.root / "commands"
        self.commands.mkdir()
        self.downloads = self.root / "downloads"
        self.downloads.mkdir()
        self.install = self.root / "install"
        self.install.mkdir()
        self.existing = self.install / "sing-box"
        self.existing.write_text("existing installation", encoding="utf-8")
        self.environment = {
            **os.environ,
            "PATH": str(self.commands) + os.pathsep + os.environ["PATH"],
            "RUNNER_TEMP": str(self.downloads),
        }

    def command(self, name: str, source: str) -> None:
        path = self.commands / name
        path.write_text("#!/bin/sh\n" + source, encoding="utf-8")
        path.chmod(0o755)

    def run_installer(self) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["bash", str(INSTALLER), str(self.install)],
            env=self.environment,
            capture_output=True,
            text=True,
        )

    def test_corrupt_download_preserves_installation_and_cleans_temporary_files(self) -> None:
        download_marker = self.root / "download-attempted"
        unpack_marker = self.root / "unpack-attempted"
        self.command(
            "curl",
            'while [ "$#" -gt 0 ]; do\n'
            '  if [ "$1" = "-o" ]; then\n'
            '    printf "corrupt archive" > "$2"\n'
            f'    touch "{download_marker}"\n'
            '    exit 0\n'
            '  fi\n'
            '  shift\n'
            'done\n'
            'exit 1\n',
        )
        self.command("tar", f'touch "{unpack_marker}"\n')
        result = self.run_installer()
        self.assertNotEqual(0, result.returncode)
        self.assertTrue(download_marker.exists())
        self.assertFalse(unpack_marker.exists())
        self.assertEqual("existing installation", self.existing.read_text(encoding="utf-8"))
        self.assertEqual([], list(self.downloads.iterdir()))

    def test_unsupported_platform_stops_before_download(self) -> None:
        self.command("uname", 'printf "unsupported\\n"\n')
        marker = self.root / "download-attempted"
        self.command("curl", f'touch "{marker}"\n')
        result = self.run_installer()
        self.assertNotEqual(0, result.returncode)
        self.assertIn("unsupported platform", result.stderr)
        self.assertFalse(marker.exists())
        self.assertEqual("existing installation", self.existing.read_text(encoding="utf-8"))
        self.assertEqual([], list(self.downloads.iterdir()))


if __name__ == "__main__":
    unittest.main()
