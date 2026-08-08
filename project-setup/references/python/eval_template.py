# First trivial eval harness
#
# Copy this structure into tests/test_<name>_eval.py. Replace:
# - The import path to point at the function under test
# - The CASES list with real examples
# - The assertion to match the expected output shape
#
# The harness is standard pytest — CI picks it up automatically because
# pytest discovers tests/ by default. Grow CASES over time; every time the
# system gets something wrong in production, add that case here.

import pytest
from <pkg>.<module> import <function_under_test>

CASES = [
    ("<input 1>", "<expected 1>"),
    ("<input 2>", "<expected 2>"),
    ("<input 3>", "<expected 3>"),
]


@pytest.mark.parametrize("message, expected", CASES)
def test_<name>(message: str, expected: str) -> None:
    assert <function_under_test>(message) == expected
