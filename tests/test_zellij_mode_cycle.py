import re
import unittest
from pathlib import Path


CONFIG = (
    Path(__file__).parents[1] / "home/dot_config/zellij/config.kdl"
).read_text()

# Meh PageDown walks this ring; tmux wraps to locked (not normal) so normal
# does not bookend the cycler strip.
MODES = [
    "normal",
    "locked",
    "resize",
    "scroll",
    "entersearch",
    "search",
    "tab",
    "renametab",
    "pane",
    "renamepane",
    "session",
    "move",
    "prompt",
    "tmux",
]


def page_down_target(mode: str) -> str:
    if mode == "tmux":
        return "locked"
    index = MODES.index(mode)
    return MODES[index + 1]


def page_up_target(mode: str) -> str:
    if mode == "normal":
        return "tmux"
    index = MODES.index(mode)
    return MODES[index - 1]


class ZellijModeCycleTest(unittest.TestCase):
    def test_meh_page_up_cycles_backwards_through_modes(self):
        for mode in MODES:
            previous = page_up_target(mode)
            mode_block = re.search(
                rf"(?ms)^    {mode} \{{(.*?)(?=^    \}})",
                CONFIG,
            )
            self.assertIsNotNone(mode_block, f"missing {mode} mode block")
            self.assertIn(
                f'bind "Ctrl Alt Shift PageUp" {{ SwitchToMode "{previous}"; }}',
                mode_block.group(1),
                f"{mode} should cycle back to {previous}",
            )

    def test_meh_page_down_cycles_forwards_through_modes(self):
        for mode in MODES:
            following = page_down_target(mode)
            mode_block = re.search(
                rf"(?ms)^    {mode} \{{(.*?)(?=^    \}})",
                CONFIG,
            )
            self.assertIsNotNone(mode_block, f"missing {mode} mode block")
            self.assertIn(
                f'bind "Ctrl Alt Shift PageDown" {{ SwitchToMode "{following}"; }}',
                mode_block.group(1),
                f"{mode} should cycle forward to {following}",
            )


if __name__ == "__main__":
    unittest.main()
