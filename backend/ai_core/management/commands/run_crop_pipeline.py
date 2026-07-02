"""
Run the Egypt crop data pipeline (CROPGRIDS + GEE).

Examples:
    python manage.py run_crop_pipeline --step all
    python manage.py run_crop_pipeline --step 1 --step 2
    python manage.py run_crop_pipeline --step 5
"""

import sys
from pathlib import Path

from django.core.management.base import BaseCommand

# Add backend/scripts to path so we can import data_pipeline
_SCRIPTS_DIR = Path(__file__).resolve().parents[3] / "scripts"
if str(_SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(_SCRIPTS_DIR))

from data_pipeline import STEP_MAP, main as pipeline_main  # noqa: E402


class Command(BaseCommand):
    help = "Run the Egypt crop data pipeline (data_pipeline.py)."

    def add_arguments(self, parser):
        parser.add_argument(
            "--step",
            action="append",
            choices=list(STEP_MAP.keys()) + ["all"],
            required=True,
            help="Pipeline step to run (repeat for multiple steps).",
        )

    def handle(self, *args, **options):
        argv = ["run_crop_pipeline"]
        for step in options["step"]:
            argv.extend(["--step", step])
        exit_code = pipeline_main(argv[1:])
        if exit_code != 0:
            self.stderr.write(self.style.ERROR("Pipeline failed."))
            sys.exit(exit_code)
        self.stdout.write(self.style.SUCCESS("Pipeline completed."))
