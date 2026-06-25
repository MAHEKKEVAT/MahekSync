#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║                    MAHEKSYNC DEPLOYER v4.0                                   ║
║              Premium Deployment Dashboard                                    ║
║                        Made by Mahek                                          ║
╚══════════════════════════════════════════════════════════════════════════════╝
"""

import flet as ft
import subprocess
import threading
import time
import math
import os
import sys
from datetime import datetime
from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional, Callable, List


# ═══════════════════════════════════════════════════════════════════════════════
# DATA MODELS
# ═══════════════════════════════════════════════════════════════════════════════

class StepStatus(Enum):
    PENDING = auto()
    RUNNING = auto()
    SUCCESS = auto()
    FAILED = auto()


@dataclass
class DeployStep:
    name: str
    command: str
    description: str
    status: StepStatus = StepStatus.PENDING
    duration: float = 0.0
    output: str = ""
    exit_code: Optional[int] = None


# ═══════════════════════════════════════════════════════════════════════════════
# HARD-CODED PROJECT PATH
# ═══════════════════════════════════════════════════════════════════════════════

PROJECT_DIR = r"F:\\MahekSync\\MahekSync"


def get_resource_path(relative_path):
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)


# ═══════════════════════════════════════════════════════════════════════════════
# THEME SYSTEM - Professional Color Palette
# ═══════════════════════════════════════════════════════════════════════════════

class Theme:
    def __init__(self, is_dark: bool = True):
        self.is_dark = is_dark
        if is_dark:
            # Dark Theme - GitHub Desktop / Docker Desktop inspired
            self.bg = "#0B0F19"
            self.bg_secondary = "#111827"
            self.card = "#151D2D"
            self.card_hover = "#1A2335"
            self.border = "#273449"
            self.border_hover = "#374A64"
            self.text = "#F8FAFC"
            self.text_secondary = "#94A3B8"
            self.text_muted = "#64748B"
            self.accent = "#3B82F6"          # Blue primary
            self.accent_hover = "#2563EB"
            self.success = "#22C55E"
            self.warning = "#F59E0B"
            self.error = "#EF4444"
            self.terminal_bg = "#090B11"
            self.terminal_border = "#1E293B"
            self.button_bg = "#1E293B"
            self.button_hover = "#334155"
        else:
            # Light Theme - Notion / GitHub Desktop Light inspired
            self.bg = "#F5F7FA"
            self.bg_secondary = "#E5E7EB"
            self.card = "#FFFFFF"
            self.card_hover = "#F8FAFC"
            self.border = "#E5E7EB"
            self.border_hover = "#D1D5DB"
            self.text = "#111827"
            self.text_secondary = "#6B7280"
            self.text_muted = "#9CA3AF"
            self.accent = "#2563EB"
            self.accent_hover = "#1D4ED8"
            self.success = "#16A34A"
            self.warning = "#D97706"
            self.error = "#DC2626"
            self.terminal_bg = "#F8FAFC"
            self.terminal_border = "#E5E7EB"
            self.button_bg = "#F1F5F9"
            self.button_hover = "#E2E8F0"


# Global theme instance
current_theme = Theme(is_dark=True)


# ═══════════════════════════════════════════════════════════════════════════════
# COMPACT STEP ITEM (VSCode-style)
# ═══════════════════════════════════════════════════════════════════════════════

class StepItem(ft.Container):
    """Compact 55px height step item like VSCode"""

    def __init__(self, step: DeployStep, index: int, theme: Theme):
        self.step = step
        self.index = index
        self._theme = theme

        self.status_icon = ft.Icon(
            ft.Icons.CIRCLE_OUTLINED,
            size=16,
            color=theme.text_muted,
        )
        self.name_text = ft.Text(
            step.name,
            size=13,
            weight=ft.FontWeight.W_500,
            color=theme.text,
            font_family="Segoe UI",
        )
        self.desc_text = ft.Text(
            step.description,
            size=11,
            color=theme.text_secondary,
            font_family="Segoe UI",
        )
        self.duration_text = ft.Text(
            "",
            size=11,
            color=theme.text_muted,
            font_family="Segoe UI",
        )
        self.spinner = ft.ProgressRing(
            width=14,
            height=14,
            stroke_width=2,
            color=theme.accent,
            visible=False,
        )

        super().__init__(
            content=ft.Row([
                ft.Container(
                    content=ft.Stack([
                        self.spinner,
                        self.status_icon,
                    ]),
                    width=28,
                    height=28,
                    alignment=ft.alignment.center,
                ),
                ft.Column([
                    self.name_text,
                    self.desc_text,
                ], spacing=2, expand=True),
                ft.Container(
                    content=self.duration_text,
                    alignment=ft.alignment.center_right,
                    width=60,
                ),
            ], spacing=12, alignment=ft.MainAxisAlignment.START),
            bgcolor=theme.card,
            border=ft.border.all(1, theme.border),
            border_radius=8,
            padding=ft.padding.symmetric(horizontal=16, vertical=10),
            height=55,
            animate=ft.Animation(200, ft.AnimationCurve.EASE_OUT),
        )

    def update_status(self, status: StepStatus, duration: float = 0):
        self.step.status = status
        self.step.duration = duration

        if status == StepStatus.PENDING:
            self.status_icon.name = ft.Icons.CIRCLE_OUTLINED
            self.status_icon.color = self._theme.text_muted
            self.spinner.visible = False
            self.name_text.color = self._theme.text
        elif status == StepStatus.RUNNING:
            self.status_icon.name = ft.Icons.CIRCLE_OUTLINED
            self.status_icon.color = "transparent"
            self.spinner.visible = True
            self.name_text.color = self._theme.accent
            self.bgcolor = self._theme.card_hover
            self.border = ft.border.all(1, self._theme.accent)
        elif status == StepStatus.SUCCESS:
            self.status_icon.name = ft.Icons.CHECK_CIRCLE
            self.status_icon.color = self._theme.success
            self.spinner.visible = False
            self.name_text.color = self._theme.text
            self.bgcolor = self._theme.card
            self.border = ft.border.all(1, self._theme.border)
        elif status == StepStatus.FAILED:
            self.status_icon.name = ft.Icons.ERROR
            self.status_icon.color = self._theme.error
            self.spinner.visible = False
            self.name_text.color = self._theme.error
            self.bgcolor = self._theme.card
            self.border = ft.border.all(1, self._theme.error)

        if duration > 0:
            self.duration_text.value = f"{duration:.1f}s"

        self.update()


# ═══════════════════════════════════════════════════════════════════════════════
# MODERN TERMINAL PANEL
# ═══════════════════════════════════════════════════════════════════════════════

class ModernTerminal(ft.Column):
    """Clean, searchable terminal with modern styling"""

    def __init__(self, theme: Theme):
        self._theme = theme
        self.scroll_container = ft.ListView(
            expand=True,
            spacing=0,
            auto_scroll=True,
        )
        self.search_field = ft.TextField(
            hint_text="Search logs...",
            height=36,
            border_radius=6,
            bgcolor=theme.terminal_bg,
            border_color=theme.terminal_border,
            focused_border_color=theme.accent,
            text_size=12,
            color=theme.text,
            prefix_icon=ft.Icons.SEARCH,
            on_change=self._on_search,
        )

        super().__init__(
            controls=[
                # Terminal header with search
                ft.Container(
                    content=ft.Row([
                        ft.Row([
                            ft.Container(width=10, height=10,
                                       bgcolor=theme.error, border_radius=5),
                            ft.Container(width=10, height=10,
                                       bgcolor=theme.warning, border_radius=5),
                            ft.Container(width=10, height=10,
                                       bgcolor=theme.success, border_radius=5),
                        ], spacing=6),
                        ft.Container(width=12),
                        ft.Text("Terminal", size=12, weight=ft.FontWeight.W_600,
                               color=theme.text_secondary, font_family="Segoe UI"),
                        ft.Container(expand=True),
                        self.search_field,
                    ], spacing=0),
                    bgcolor=theme.terminal_bg,
                    padding=ft.padding.symmetric(horizontal=12, vertical=8),
                    border_radius=ft.border_radius.only(top_left=8, top_right=8),
                    border=ft.border.only(bottom=ft.BorderSide(1, theme.terminal_border)),
                ),
                # Terminal body
                ft.Container(
                    content=self.scroll_container,
                    bgcolor=theme.terminal_bg,
                    border=ft.border.all(1, theme.terminal_border),
                    border_radius=ft.border_radius.only(bottom_left=8, bottom_right=8),
                    padding=12,
                    expand=True,
                ),
            ],
            spacing=0,
            expand=True,
        )

    def _on_search(self, e):
        # Simple search highlight could be added here
        pass

    def add_line(self, text: str, color: str = None, prefix: str = "", bold: bool = False):
        if color is None:
            color = self._theme.text_secondary
        timestamp = datetime.now().strftime("%H:%M:%S")
        line = ft.Text(
            f"[{timestamp}] {prefix}{text}",
            size=12,
            color=color,
            weight=ft.FontWeight.BOLD if bold else ft.FontWeight.NORMAL,
            font_family="Consolas",
            selectable=True,
            no_wrap=False,
        )
        self.scroll_container.controls.append(line)
        if len(self.scroll_container.controls) > 500:
            self.scroll_container.controls.pop(0)

    def add_command(self, cmd: str):
        self.add_line(f"$ {cmd}", self._theme.accent, bold=True)

    def add_output(self, text: str):
        if text.strip():
            self.add_line(text, self._theme.text_secondary, "  ")

    def add_success(self, text: str):
        self.add_line(f"✓ {text}", self._theme.success, bold=True)

    def add_error(self, text: str):
        self.add_line(f"✗ {text}", self._theme.error, bold=True)

    def add_separator(self):
        self.add_line("─" * 60, self._theme.border)

    def clear(self):
        self.scroll_container.controls.clear()


# ═══════════════════════════════════════════════════════════════════════════════
# MODERN STATS PANEL
# ═══════════════════════════════════════════════════════════════════════════════

class ModernStats(ft.Row):
    """Clean metric cards like Docker Desktop"""

    def __init__(self, theme: Theme):
        self._theme = theme
        self.time_value = ft.Text("0.0s", size=24, weight=ft.FontWeight.BOLD,
                                  color=theme.text, font_family="Segoe UI")
        self.steps_value = ft.Text("0/5", size=24, weight=ft.FontWeight.BOLD,
                                   color=theme.text, font_family="Segoe UI")
        self.branch_value = ft.Text("main", size=24, weight=ft.FontWeight.BOLD,
                                    color=theme.text, font_family="Segoe UI")
        self.status_value = ft.Text("Ready", size=24, weight=ft.FontWeight.BOLD,
                                    color=theme.success, font_family="Segoe UI")

        super().__init__(
            controls=[
                self._stat_card("Deployment Time", self.time_value, theme.accent),
                self._stat_card("Completed", self.steps_value, theme.accent),
                self._stat_card("Branch", self.branch_value, theme.text_muted),
                self._stat_card("Status", self.status_value, theme.success),
            ],
            spacing=12,
            alignment=ft.MainAxisAlignment.SPACE_EVENLY,
        )

    def _stat_card(self, label: str, value: ft.Text, accent_color: str):
        return ft.Container(
            content=ft.Column([
                ft.Text(label, size=11, color=self._theme.text_muted,
                       font_family="Segoe UI", weight=ft.FontWeight.W_500),
                ft.Container(height=4),
                value,
            ], spacing=0),
            bgcolor=self._theme.card,
            border=ft.border.all(1, self._theme.border),
            border_radius=10,
            padding=16,
            expand=True,
            shadow=ft.BoxShadow(
                spread_radius=0,
                blur_radius=8,
                color="#0000001a" if self._theme.is_dark else "#0000000d",
                offset=ft.Offset(0, 2),
            ),
        )

    def update_stats(self, total_time: float, completed: int, total: int, success: bool):
        self.time_value.value = f"{total_time:.1f}s"
        self.steps_value.value = f"{completed}/{total}"
        self.status_value.value = "Success" if success else "Failed"
        self.status_value.color = self._theme.success if success else self._theme.error
        self.update()


# ═══════════════════════════════════════════════════════════════════════════════
# THEME TOGGLE BUTTON
# ═══════════════════════════════════════════════════════════════════════════════

class ThemeToggle(ft.IconButton):
    def __init__(self, on_toggle: Callable):
        self.is_dark = True
        self.on_toggle = on_toggle
        super().__init__(
            icon=ft.Icons.DARK_MODE,
            icon_color="#94A3B8",
            icon_size=20,
            tooltip="Toggle Theme",
            on_click=self._toggle,
            style=ft.ButtonStyle(
                bgcolor="transparent",
                overlay_color="#3B82F626",
            ),
        )

    def _toggle(self, e):
        self.is_dark = not self.is_dark
        self.icon = ft.Icons.LIGHT_MODE if self.is_dark else ft.Icons.DARK_MODE
        self.on_toggle(self.is_dark)
        self.update()


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN APPLICATION - Premium Dashboard
# ═══════════════════════════════════════════════════════════════════════════════

class MahekSyncDeployer:
    def __init__(self, page: ft.Page):
        self.page = page
        self.is_deploying = False
        self.start_time = 0.0
        self.step_items: List[StepItem] = []
        self.current_theme = current_theme

        self._setup_page()
        self._build_ui()

    def _setup_page(self):
        self.page.title = "MahekSync Deploy"
        self.page.theme_mode = ft.ThemeMode.DARK
        self.page.window_width = 1200
        self.page.window_height = 800
        self.page.window_min_width = 900
        self.page.window_min_height = 600
        self.page.padding = 0
        self.page.bgcolor = self.current_theme.bg
        self.page.fonts = {
            "Segoe UI": "Segoe UI",
            "Consolas": "Consolas",
        }

    def _build_ui(self):
        theme = self.current_theme

        # Profile image
        img_path = os.path.join(PROJECT_DIR, "assets", "images", "cropped_circle_image.png")
        if os.path.exists(img_path):
            avatar = ft.Container(
                content=ft.Image(
                    src=img_path,
                    width=40,
                    height=40,
                    fit=ft.ImageFit.COVER,
                    border_radius=20,
                ),
                width=40,
                height=40,
                border_radius=20,
                border=ft.border.all(2, theme.border),
            )
        else:
            avatar = ft.Container(
                content=ft.Text("M", size=18, weight=ft.FontWeight.BOLD,
                               color=theme.accent, font_family="Segoe UI"),
                width=40,
                height=40,
                border_radius=20,
                bgcolor=theme.card,
                border=ft.border.all(2, theme.border),
                alignment=ft.alignment.center,
            )

        # Theme toggle
        self.theme_toggle = ThemeToggle(self._on_theme_change)

        # Header
        header = ft.Container(
            content=ft.Row([
                ft.Row([
                    avatar,
                    ft.Container(width=12),
                    ft.Column([
                        ft.Text("MahekSync Deploy", size=18, weight=ft.FontWeight.BOLD,
                               color=theme.text, font_family="Segoe UI"),
                        ft.Text("Deploy Flutter Web to GitHub Pages", size=12,
                               color=theme.text_secondary, font_family="Segoe UI"),
                    ], spacing=2),
                ], spacing=0),
                ft.Container(expand=True),
                ft.Container(
                    content=ft.Row([
                        ft.Container(
                            width=8,
                            height=8,
                            border_radius=4,
                            bgcolor=theme.success,
                        ),
                        ft.Container(width=6),
                        ft.Text("Ready", size=12, color=theme.success,
                               font_family="Segoe UI", weight=ft.FontWeight.W_500),
                    ], spacing=0),
                    bgcolor=theme.card,
                    border_radius=20,
                    padding=ft.padding.symmetric(horizontal=12, vertical=6),
                    border=ft.border.all(1, theme.border),
                ),
                ft.Container(width=12),
                self.theme_toggle,
            ], alignment=ft.MainAxisAlignment.SPACE_BETWEEN),
            bgcolor=theme.bg_secondary,
            border=ft.border.only(bottom=ft.BorderSide(1, theme.border)),
            padding=ft.padding.symmetric(horizontal=24, vertical=14),
        )

        # Step definitions
        self.steps = [
            DeployStep("Flutter Build",
                      f'cd /d "{PROJECT_DIR}" && flutter build web --base-href "/MahekSync/"',
                      "Compile Flutter app for web"),
            DeployStep("Copy Assets",
                      f'cd /d "{PROJECT_DIR}" && xcopy "build\\web\\*" "docs\\" /E /H /Y /I',
                      "Mirror build to docs directory"),
            DeployStep("Git Stage",
                      f'cd /d "{PROJECT_DIR}" && git add .',
                      "Stage all changes"),
            DeployStep("Git Commit",
                      f'cd /d "{PROJECT_DIR}" && git commit -m "Add"',
                      "Create commit"),
            DeployStep("Git Push",
                      f'cd /d "{PROJECT_DIR}" && git push origin main',
                      "Deploy to origin/main"),
        ]

        # Progress bar
        self.progress_bar = ft.ProgressBar(
            value=0,
            bgcolor=theme.border,
            color=theme.accent,
            height=4,
            border_radius=2,
        )

        # Step items (compact)
        self.step_items = [StepItem(step, i+1, theme) for i, step in enumerate(self.steps)]
        steps_column = ft.Column(self.step_items, spacing=8)

        # Stats panel
        self.stats = ModernStats(theme)

        # Terminal
        self.terminal = ModernTerminal(theme)

        # Deploy button (floating action style)
        self.deploy_btn = ft.ElevatedButton(
            "Deploy",
            icon=ft.Icons.ROCKET_LAUNCH,
            on_click=self._on_deploy,
            style=ft.ButtonStyle(
                color="white",
                bgcolor={
                    ft.ControlState.DEFAULT: theme.accent,
                    ft.ControlState.HOVERED: theme.accent_hover,
                    ft.ControlState.DISABLED: theme.border,
                },
                padding=ft.padding.symmetric(horizontal=32, vertical=16),
                shape=ft.RoundedRectangleBorder(radius=8),
                text_style=ft.TextStyle(
                    font_family="Segoe UI",
                    weight=ft.FontWeight.W_600,
                    size=14,
                ),
                elevation={
                    ft.ControlState.DEFAULT: 2,
                    ft.ControlState.HOVERED: 4,
                },
                animation_duration=200,
            ),
            width=160,
            height=48,
        )

        # Secondary buttons
        self.stop_btn = ft.ElevatedButton(
            "Stop",
            icon=ft.Icons.STOP,
            on_click=self._on_stop,
            disabled=True,
            style=ft.ButtonStyle(
                color=theme.text,
                bgcolor=theme.button_bg,
                padding=ft.padding.symmetric(horizontal=20, vertical=14),
                shape=ft.RoundedRectangleBorder(radius=8),
                text_style=ft.TextStyle(
                    font_family="Segoe UI",
                    size=13,
                ),
            ),
            width=120,
            height=42,
        )

        self.clear_btn = ft.ElevatedButton(
            "Clear",
            icon=ft.Icons.CLEAR_ALL,
            on_click=self._on_clear,
            style=ft.ButtonStyle(
                color=theme.text_secondary,
                bgcolor=theme.button_bg,
                padding=ft.padding.symmetric(horizontal=20, vertical=14),
                shape=ft.RoundedRectangleBorder(radius=8),
                text_style=ft.TextStyle(
                    font_family="Segoe UI",
                    size=13,
                ),
            ),
            width=120,
            height=42,
        )

        button_row = ft.Row([
            self.deploy_btn,
            ft.Container(width=12),
            self.stop_btn,
            ft.Container(width=12),
            self.clear_btn,
        ], alignment=ft.MainAxisAlignment.CENTER)

        # Main content layout
        left_panel = ft.Container(
            content=ft.Column([
                ft.Text("Build Progress", size=14, weight=ft.FontWeight.W_600,
                       color=theme.text, font_family="Segoe UI"),
                ft.Container(height=8),
                self.progress_bar,
                ft.Container(height=16),
                steps_column,
            ], spacing=0),
            width=380,
            padding=24,
        )

        right_panel = ft.Container(
            content=ft.Column([
                self.stats,
                ft.Container(height=16),
                ft.Text("Logs", size=14, weight=ft.FontWeight.W_600,
                       color=theme.text, font_family="Segoe UI"),
                ft.Container(height=8),
                self.terminal,
                ft.Container(height=16),
                button_row,
            ], spacing=0),
            expand=True,
            padding=ft.padding.only(left=0, top=24, right=24, bottom=24),
        )

        main_content = ft.Row([
            left_panel,
            ft.VerticalDivider(width=1, color=theme.border),
            right_panel,
        ], expand=True, spacing=0)

        # Footer
        footer = ft.Container(
            content=ft.Row([
                ft.Text("MahekSync Deployer v4.0", size=11,
                       color=theme.text_muted, font_family="Segoe UI"),
                ft.Container(expand=True),
                ft.Text("Made by Mahek", size=11,
                       color=theme.text_muted, font_family="Segoe UI"),
            ]),
            bgcolor=theme.bg_secondary,
            border=ft.border.only(top=ft.BorderSide(1, theme.border)),
            padding=ft.padding.symmetric(horizontal=24, vertical=10),
        )

        self.page.add(
            ft.Column([
                header,
                ft.Container(content=main_content, expand=True),
                footer,
            ], spacing=0, expand=True)
        )

    def _on_theme_change(self, is_dark: bool):
        self.current_theme = Theme(is_dark=is_dark)
        self.page.theme_mode = ft.ThemeMode.DARK if is_dark else ft.ThemeMode.LIGHT
        self.page.bgcolor = self.current_theme.bg
        # Rebuild UI with new theme
        self.page.controls.clear()
        self._build_ui()
        self.page.update()

    def _on_deploy(self, e):
        if self.is_deploying:
            return

        self.is_deploying = True
        self.start_time = time.time()

        for item in self.step_items:
            item.update_status(StepStatus.PENDING)
            item.step.output = ""
            item.step.duration = 0

        self.terminal.clear()
        self.progress_bar.value = 0
        self.progress_bar.color = self.current_theme.accent

        self.deploy_btn.disabled = True
        self.deploy_btn.text = "Deploying..."
        self.stop_btn.disabled = False

        self.page.update()

        thread = threading.Thread(target=self._run_pipeline, daemon=True)
        thread.start()

    def _on_stop(self, e):
        # Stop functionality would require process termination
        self.is_deploying = False
        self.deploy_btn.disabled = False
        self.deploy_btn.text = "Deploy"
        self.stop_btn.disabled = True
        self.page.update()

    def _on_clear(self, e):
        self.terminal.clear()
        self.page.update()

    def _run_pipeline(self):
        total_steps = len(self.steps)
        completed = 0
        success_count = 0

        self._safe_terminal_call(
            lambda: (
                self.terminal.add_separator(),
                self.terminal.add_line("Starting deployment pipeline", self.current_theme.accent, bold=True),
                self.terminal.add_line(f"Project: {PROJECT_DIR}", self.current_theme.text_secondary),
                self.terminal.add_line(f"Steps: {total_steps}", self.current_theme.text_secondary),
                self.terminal.add_separator(),
            )
        )

        for i, step in enumerate(self.steps):
            if not self.is_deploying:
                break

            step_start = time.time()

            self._update_step_item(i, StepStatus.RUNNING)
            self._safe_terminal_call(
                lambda s=step: (
                    self.terminal.add_separator(),
                    self.terminal.add_line(f"Step {i+1}: {s.name}", self.current_theme.accent, bold=True),
                    self.terminal.add_command(s.command),
                )
            )

            try:
                process = subprocess.Popen(
                    step.command,
                    shell=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    bufsize=1,
                    universal_newlines=True,
                )

                output_lines = []
                for line in process.stdout:
                    line = line.rstrip()
                    output_lines.append(line)
                    self._safe_terminal_call(
                        lambda l=line: self.terminal.add_output(l)
                    )

                process.wait()
                step.exit_code = process.returncode
                step.output = "\n".join(output_lines)
                duration = time.time() - step_start

                if process.returncode == 0:
                    step.status = StepStatus.SUCCESS
                    success_count += 1
                    self._update_step_item(i, StepStatus.SUCCESS, duration)
                    self._safe_terminal_call(
                        lambda d=duration: self.terminal.add_success(
                            f"Completed in {d:.2f}s"
                        )
                    )
                else:
                    step.status = StepStatus.FAILED
                    self._update_step_item(i, StepStatus.FAILED, duration)
                    self._safe_terminal_call(
                        lambda d=duration, c=process.returncode: self.terminal.add_error(
                            f"Failed in {d:.2f}s (exit {c})"
                        )
                    )
                    break

            except Exception as ex:
                step.status = StepStatus.FAILED
                duration = time.time() - step_start
                self._update_step_item(i, StepStatus.FAILED, duration)
                self._safe_terminal_call(
                    lambda e=ex: self.terminal.add_error(f"Error: {e}")
                )
                break

            completed += 1
            self._update_progress(completed / total_steps)
            self._update_stats(completed, total_steps, success_count == total_steps)

        total_duration = time.time() - self.start_time
        self._finish_pipeline(completed == total_steps and success_count == total_steps,
                             total_duration)

    def _update_step_item(self, index: int, status: StepStatus, duration: float = 0):
        def update():
            self.step_items[index].update_status(status, duration)
        self._safe_call(update)

    def _update_progress(self, value: float):
        def update():
            self.progress_bar.value = value
            self.page.update()
        self._safe_call(update)

    def _update_stats(self, completed: int, total: int, success: bool):
        def update():
            self.stats.update_stats(
                time.time() - self.start_time,
                completed, total, success
            )
        self._safe_call(update)

    def _finish_pipeline(self, all_success: bool, duration: float):
        def finish():
            self.is_deploying = False
            self.progress_bar.value = 1.0
            self.progress_bar.color = self.current_theme.success if all_success else self.current_theme.error

            self.terminal.add_separator()
            if all_success:
                self.terminal.add_line(
                    f"Deployment successful! ({duration:.2f}s)",
                    self.current_theme.success, bold=True
                )
                self.page.snack_bar = ft.SnackBar(
                    content=ft.Text("Deployment Successful", color="white", size=14,
                                   weight=ft.FontWeight.W_600, font_family="Segoe UI"),
                    bgcolor=self.current_theme.success,
                )
            else:
                self.terminal.add_line(
                    f"Deployment failed after {duration:.2f}s",
                    self.current_theme.error, bold=True
                )
                self.page.snack_bar = ft.SnackBar(
                    content=ft.Text("Deployment Failed", color="white", size=14,
                                   weight=ft.FontWeight.W_600, font_family="Segoe UI"),
                    bgcolor=self.current_theme.error,
                )

            self.page.snack_bar.open = True

            self.deploy_btn.disabled = False
            self.deploy_btn.text = "Deploy"
            self.stop_btn.disabled = True

            self.page.update()

        self._safe_call(finish)

    def _safe_terminal_call(self, func: Callable):
        def wrapper():
            func()
            try:
                self.page.update()
            except:
                pass
        self._safe_call(wrapper)

    def _safe_call(self, func: Callable):
        try:
            if hasattr(self.page, 'run'):
                self.page.run(func)
            else:
                func()
                self.page.update()
        except Exception:
            func()
            try:
                self.page.update()
            except:
                pass


# ═══════════════════════════════════════════════════════════════════════════════
# ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════════

def main(page: ft.Page):
    MahekSyncDeployer(page)


if __name__ == "__main__":
    ft.app(target=main)