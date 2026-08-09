# Environment-based config with pydantic-settings
#
# Copy this structure into src/<pkg>/config.py. Replace the fields with
# the project's actual config keys.
#
# Key rules:
# - Required keys: no default — crashes at startup if missing
# - Optional keys: provide a default
# - Module-level singleton: `settings = Settings()`
# - Every other module imports `settings`, never calls os.getenv() directly
#
# If the Settings class gains a required field (a key with no default),
# reinstate `# type: ignore[call-arg]` on the `settings = Settings()` line.

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application configuration, loaded from environment variables.

    Values are read from real environment variables first, then from a
    local .env file. A missing required field raises an error at startup.
    """

    model_config = SettingsConfigDict(env_file=".env")

    # Required — no default, crashes at startup if missing
    <PRIMARY_API_KEY>: str

    # Optional — has a default, safe to omit
    <OPTIONAL_KEY>: str = ""


settings = Settings()