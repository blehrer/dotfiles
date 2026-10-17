import unittest
from pathlib import Path

REPO = Path(__file__).parents[1]
ZELLIJ = (REPO / "home/dot_config/zellij/config.kdl").read_text()
GHOSTTY = (REPO / "home/dot_config/ghostty/config.tmpl").read_text()

ZELLIJ_MARKER = "// keymap-ref: zellij-mode-cycle"
ZELLIJ_MODE_CYCLE_COMMENT = "// Meh PageUp/PageDown mode-cycle bindings repeat in every mode below."
ZELLIJ_BLOCK = "    normal {"
GHOSTTY_MARKER = "# keymap-ref: ghostty-f5-reload"
GHOSTTY_BINDING = "keybind = unconsumed:f5=reload_config"
AEROSPACE = (REPO / "home/dot_config/aerospace/aerospace.toml").read_text()
AEROSPACE_FAMILY_CATALOG = (
    ("# keymap-ref: aerospace-layout-cycle", "    alt-tab = 'layout horizontal vertical'"),
    (
        "# keymap-ref: aerospace-focus-cycle",
        "    ctrl-tab = 'focus --boundaries workspace --boundaries-action wrap-around-the-workspace dfs-next'",
    ),
    ("# keymap-ref: aerospace-directional-focus", "    alt-h = 'focus left'"),
    ("# keymap-ref: aerospace-directional-move", "    alt-shift-h = 'move left'"),
    ("# keymap-ref: aerospace-resize", "    alt-minus = 'resize smart -50'"),
    ("# keymap-ref: aerospace-workspaces", "    ctrl-alt-y = 'workspace 1'"),
    ("# keymap-ref: aerospace-service-mode", "    alt-shift-quote = 'mode service'"),
)


class KeymapProvenanceTest(unittest.TestCase):
    def test_zellij_marker_once_and_adjacent_to_normal_block(self):
        self.assertEqual(ZELLIJ.count(ZELLIJ_MARKER), 1)
        idx = ZELLIJ.index(ZELLIJ_MARKER)
        after_marker = ZELLIJ[idx + len(ZELLIJ_MARKER) :]
        self.assertTrue(
            after_marker.startswith("\n" + ZELLIJ_BLOCK),
            "marker must be immediately above normal { mode block",
        )

    def test_zellij_mode_cycle_comment_above_marker(self):
        self.assertEqual(ZELLIJ.count(ZELLIJ_MODE_CYCLE_COMMENT), 1)
        comment_idx = ZELLIJ.index(ZELLIJ_MODE_CYCLE_COMMENT)
        marker_idx = ZELLIJ.index(ZELLIJ_MARKER)
        self.assertLess(comment_idx, marker_idx)
        self.assertIn(
            ZELLIJ_MODE_CYCLE_COMMENT + "\n    " + ZELLIJ_MARKER,
            ZELLIJ,
        )

    def test_ghostty_marker_once_and_adjacent_to_f5_reload(self):
        self.assertEqual(GHOSTTY.count(GHOSTTY_MARKER), 1)
        idx = GHOSTTY.index(GHOSTTY_MARKER)
        after_marker = GHOSTTY[idx + len(GHOSTTY_MARKER) :]
        self.assertTrue(
            after_marker.startswith("\n" + GHOSTTY_BINDING),
            "marker must be immediately above f5 reload_config keybind",
        )

    def test_aerospace_family_markers_once_and_adjacent_to_bindings(self):
        for marker, binding in AEROSPACE_FAMILY_CATALOG:
            with self.subTest(marker=marker):
                self.assertEqual(AEROSPACE.count(marker), 1, marker)
                idx = AEROSPACE.index(marker)
                after_marker = AEROSPACE[idx + len(marker) :]
                self.assertTrue(
                    after_marker.startswith("\n" + binding),
                    f"{marker} must be immediately above binding",
                )


if __name__ == "__main__":
    unittest.main()
