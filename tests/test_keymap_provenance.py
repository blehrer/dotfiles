import unittest
from pathlib import Path

REPO = Path(__file__).parents[1]
ZELLIJ = (REPO / "home/dot_config/zellij/config.kdl").read_text()
GHOSTTY = (REPO / "home/dot_config/ghostty/config.tmpl").read_text()

ZELLIJ_MARKER = "// keymap-ref: zellij-mode-cycle"
ZELLIJ_BLOCK = "    normal {"
GHOSTTY_MARKER = "# keymap-ref: ghostty-f5-reload"
GHOSTTY_BINDING = "keybind = unconsumed:f5=reload_config"


class KeymapProvenanceTest(unittest.TestCase):
    def test_zellij_marker_once_and_adjacent_to_normal_block(self):
        self.assertEqual(ZELLIJ.count(ZELLIJ_MARKER), 1)
        idx = ZELLIJ.index(ZELLIJ_MARKER)
        after_marker = ZELLIJ[idx + len(ZELLIJ_MARKER) :]
        self.assertTrue(
            after_marker.startswith("\n" + ZELLIJ_BLOCK),
            "marker must be immediately above normal { mode block",
        )

    def test_ghostty_marker_once_and_adjacent_to_f5_reload(self):
        self.assertEqual(GHOSTTY.count(GHOSTTY_MARKER), 1)
        idx = GHOSTTY.index(GHOSTTY_MARKER)
        after_marker = GHOSTTY[idx + len(GHOSTTY_MARKER) :]
        self.assertTrue(
            after_marker.startswith("\n" + GHOSTTY_BINDING),
            "marker must be immediately above f5 reload_config keybind",
        )


if __name__ == "__main__":
    unittest.main()
