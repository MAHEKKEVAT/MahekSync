#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║                    MAHEKSYNC DEPLOYER v2.0                                   ║
║           Professional Flutter Deployment Pipeline GUI                        ║
╚══════════════════════════════════════════════════════════════════════════════╝
"""

import flet as ft
import subprocess
import threading
import time
from datetime import datetime
from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional, Callable, List


# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION & CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════

class StepStatus(Enum):
    PENDING = auto()
    RUNNING = auto()
    SUCCESS = auto()
    FAILED = auto()
    SKIPPED = auto()


@dataclass
class DeployStep:
    name: str
    command: str
    description: str
    status: StepStatus = StepStatus.PENDING
    duration: float = 0.0
    output: str = ""
    exit_code: Optional[int] = None


# Color Palette - Professional Dark Theme
BG_PRIMARY = "#0D1117"
BG_SECONDARY = "#161B22"
BG_TERTIARY = "#21262D"
BG_CARD = "#1C2128"
BORDER = "#30363D"
TEXT_PRIMARY = "#E6EDF3"
TEXT_SECONDARY = "#8B949E"
TEXT_MUTED = "#6E7681"
ACCENT_BLUE = "#58A6FF"
ACCENT_GREEN = "#3FB950"
ACCENT_RED = "#F85149"
ACCENT_YELLOW = "#D29922"
ACCENT_PURPLE = "#A371F7"
ACCENT_CYAN = "#39C5CF"


# ═══════════════════════════════════════════════════════════════════════════════
# CUSTOM WIDGETS
# ═══════════════════════════════════════════════════════════════════════════════

class StepCard(ft.Container):
    """Step indicator card"""
    
    def __init__(self, step: DeployStep, index: int):
        self.step = step
        self.index = index
        self.status_icon = ft.Text("○", size=20, color=TEXT_MUTED)
        self.status_ring = ft.ProgressRing(
            width=24, height=24, stroke_width=2,
            color=ACCENT_BLUE, visible=False
        )
        self.duration_text = ft.Text("", size=11, color=TEXT_MUTED)
        self.output_preview = ft.Text(
            "", size=11, color=TEXT_SECONDARY,
            max_lines=2, overflow=ft.TextOverflow.ELLIPSIS
        )
        
        super().__init__(
            content=ft.Row([
                ft.Container(
                    content=ft.Stack([
                        self.status_ring,
                        ft.Container(
                            content=self.status_icon,
                            alignment=ft.alignment.center,
                            width=24, height=24,
                        )
                    ]),
                    width=40, height=40,
                ),
                ft.Column([
                    ft.Row([
                        ft.Text(
                            f"STEP {index}", 
                            size=10, 
                            weight=ft.FontWeight.BOLD,
                            color=TEXT_MUTED
                        ),
                        ft.Container(width=8),
                        ft.Text(
                            step.name, 
                            size=14, 
                            weight=ft.FontWeight.W_600,
                            color=TEXT_PRIMARY
                        ),
                    ], spacing=0),
                    ft.Text(
                        step.description, 
                        size=12, 
                        color=TEXT_SECONDARY
                    ),
                    ft.Row([
                        self.duration_text,
                        ft.Container(width=10),
                        self.output_preview,
                    ], spacing=0),
                ], spacing=4, expand=True),
                ft.Container(
                    content=ft.Text(
                        step.command[:30] + "..." if len(step.command) > 30 else step.command,
                        size=10, 
                        color=ACCENT_CYAN,
                        font_family="Consolas"
                    ),
                    bgcolor=BG_TERTIARY,
                    border_radius=4,
                    padding=ft.padding.symmetric(horizontal=8, vertical=4),
                ),
            ], spacing=12),
            bgcolor=BG_CARD,
            border=ft.border.all(1, BORDER),
            border_radius=12,
            padding=16,
        )
    
    def update_status(self, status: StepStatus, duration: float = 0, output: str = ""):
        self.step.status = status
        self.step.duration = duration
        self.step.output = output
        
        icons_map = {
            StepStatus.PENDING: ("○", TEXT_MUTED),
            StepStatus.RUNNING: ("", ACCENT_BLUE),
            StepStatus.SUCCESS: ("✓", ACCENT_GREEN),
            StepStatus.FAILED: ("✕", ACCENT_RED),
            StepStatus.SKIPPED: ("⊘", TEXT_MUTED),
        }
        
        icon, color = icons_map[status]
        self.status_icon.value = icon
        self.status_icon.color = color
        self.status_ring.visible = (status == StepStatus.RUNNING)
        
        if duration > 0:
            self.duration_text.value = f"⏱ {duration:.1f}s"
        
        if output:
            preview = output.strip().split('\n')[-1]
            self.output_preview.value = preview[:60]
        
        border_colors = {
            StepStatus.PENDING: BORDER,
            StepStatus.RUNNING: ACCENT_BLUE,
            StepStatus.SUCCESS: ACCENT_GREEN,
            StepStatus.FAILED: ACCENT_RED,
            StepStatus.SKIPPED: TEXT_MUTED,
        }
        self.border = ft.border.all(2, border_colors[status])
        
        if status == StepStatus.RUNNING:
            self.bgcolor = BG_SECONDARY
        elif status == StepStatus.SUCCESS:
            self.bgcolor = BG_CARD
        elif status == StepStatus.FAILED:
            self.bgcolor = "#3D1F1F"
        
        self.update()


class TerminalOutput(ft.Column):
    """Terminal-like output panel"""
    
    def __init__(self):
        self.scroll_container = ft.Column(
            scroll=ft.ScrollMode.AUTO,
            spacing=2,
            expand=True,
        )
        
        super().__init__(
            controls=[
                ft.Container(
                    content=ft.Row([
                        ft.Text("TERMINAL", size=10, weight=ft.FontWeight.BOLD, 
                               color=TEXT_MUTED),
                        ft.Container(expand=True),
                        ft.Text("●", size=8, color=ACCENT_GREEN),
                        ft.Text("LIVE", size=10, color=TEXT_MUTED),
                    ], spacing=6),
                    bgcolor=BG_TERTIARY,
                    padding=ft.padding.symmetric(horizontal=12, vertical=8),
                    border_radius=ft.border_radius.only(top_left=8, top_right=8),
                ),
                ft.Container(
                    content=self.scroll_container,
                    bgcolor="#0D1117",
                    border=ft.border.all(1, BORDER),
                    border_radius=ft.border_radius.only(bottom_left=8, bottom_right=8),
                    padding=12,
                    expand=True,
                ),
            ],
            spacing=0,
            expand=True,
        )
    
    def add_line(self, text: str, color: str = TEXT_SECONDARY, 
                 prefix: str = "", bold: bool = False):
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
        if len(self.scroll_container.controls) > 100:
            self.scroll_container.controls.pop(0)
    
    def add_command(self, cmd: str):
        self.add_line(f"$ {cmd}", ACCENT_CYAN, bold=True)
    
    def add_output(self, text: str):
        if text.strip():
            self.add_line(text, TEXT_SECONDARY, "  ")
    
    def add_success(self, text: str):
        self.add_line(f"✓ {text}", ACCENT_GREEN, bold=True)
    
    def add_error(self, text: str):
        self.add_line(f"✗ {text}", ACCENT_RED, bold=True)
    
    def add_separator(self):
        self.add_line("─" * 60, BORDER)
    
    def clear(self):
        self.scroll_container.controls.clear()


class StatsPanel(ft.Container):
    """Deployment statistics panel"""
    
    def __init__(self):
        self.total_time = ft.Text("0.0s", size=24, weight=ft.FontWeight.BOLD, 
                                  color=TEXT_PRIMARY)
        self.steps_completed = ft.Text("0/5", size=24, weight=ft.FontWeight.BOLD,
                                       color=ACCENT_BLUE)
        self.success_rate = ft.Text("0%", size=24, weight=ft.FontWeight.BOLD,
                                    color=ACCENT_GREEN)
        
        super().__init__(
            content=ft.Row([
                self._stat_box("⏱ TOTAL TIME", self.total_time, ACCENT_BLUE),
                ft.VerticalDivider(color=BORDER, width=1),
                self._stat_box("STEPS DONE", self.steps_completed, ACCENT_PURPLE),
                ft.VerticalDivider(color=BORDER, width=1),
                self._stat_box("SUCCESS RATE", self.success_rate, ACCENT_GREEN),
            ], spacing=20, alignment=ft.MainAxisAlignment.SPACE_EVENLY),
            bgcolor=BG_CARD,
            border=ft.border.all(1, BORDER),
            border_radius=12,
            padding=20,
        )
    
    def _stat_box(self, label: str, value: ft.Text, color: str):
        return ft.Column([
            ft.Text(label, size=10, weight=ft.FontWeight.BOLD, color=TEXT_MUTED),
            value,
        ], horizontal_alignment=ft.CrossAxisAlignment.CENTER, spacing=4)
    
    def update_stats(self, total_time: float, completed: int, total: int, success: int):
        self.total_time.value = f"{total_time:.1f}s"
        self.steps_completed.value = f"{completed}/{total}"
        rate = (success / total * 100) if total > 0 else 0
        self.success_rate.value = f"{rate:.0f}%"
        self.success_rate.color = ACCENT_GREEN if rate == 100 else ACCENT_YELLOW
        self.update()


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN APPLICATION
# ═══════════════════════════════════════════════════════════════════════════════

class MahekSyncDeployer:
    def __init__(self, page: ft.Page):
        self.page = page
        self.is_deploying = False
        self.start_time = 0.0
        self.step_cards: List[StepCard] = []
        self.current_step_index = 0
        
        self._setup_page()
        self._build_ui()
    
    def _setup_page(self):
        self.page.title = "MahekSync Deployer v2.0"
        self.page.theme_mode = ft.ThemeMode.DARK
        self.page.window_width = 1100
        self.page.window_height = 800
        self.page.window_min_width = 900
        self.page.window_min_height = 600
        self.page.padding = 0
        self.page.bgcolor = BG_PRIMARY
    
    def _build_ui(self):
        # HEADER
        header = ft.Container(
            content=ft.Row([
                ft.Row([
                    ft.Icon(ft.Icons.ROCKET_LAUNCH, size=32, color=ACCENT_BLUE),
                    ft.Column([
                        ft.Text("MahekSync", size=22, weight=ft.FontWeight.BOLD,
                               color=TEXT_PRIMARY),
                        ft.Text("DEPLOYMENT PIPELINE", size=10, weight=ft.FontWeight.BOLD,
                               color=ACCENT_BLUE),
                    ], spacing=0),
                ], spacing=12),
                ft.Container(expand=True),
                ft.Container(
                    content=ft.Row([
                        ft.Icon(ft.Icons.CIRCLE, size=8, color=ACCENT_GREEN),
                        ft.Text("READY", size=11, weight=ft.FontWeight.BOLD,
                               color=ACCENT_GREEN),
                    ], spacing=6),
                    bgcolor=BG_TERTIARY,
                    border_radius=20,
                    padding=ft.padding.symmetric(horizontal=16, vertical=8),
                ),
            ], alignment=ft.MainAxisAlignment.SPACE_BETWEEN),
            bgcolor=BG_SECONDARY,
            border=ft.border.only(bottom=ft.BorderSide(1, BORDER)),
            padding=ft.padding.symmetric(horizontal=24, vertical=16),
        )
        
        # STEP DEFINITIONS
        self.steps = [
            DeployStep(
                "Flutter Build",
                'flutter build web --base-href "/MahekSync/"',
                "Compile Flutter app for web with custom base-href"
            ),
            DeployStep(
                "Copy Assets",
                "xcopy build\\web\\* docs\\ /E /H /Y",
                "Copy build output to docs directory recursively"
            ),
            DeployStep(
                "Git Stage",
                "git add .",
                "Stage all changes for commit"
            ),
            DeployStep(
                "Git Commit",
                'git commit -m "Add"',
                "Commit changes with message"
            ),
            DeployStep(
                "Git Push",
                "git push origin main",
                "Push committed changes to origin main"
            ),
        ]
        
        # STEP CARDS
        self.step_cards = [StepCard(step, i+1) for i, step in enumerate(self.steps)]
        steps_column = ft.Column(self.step_cards, spacing=8)
        
        # PROGRESS BAR
        self.progress_bar = ft.ProgressBar(
            value=0,
            bgcolor=BG_TERTIARY,
            color=ACCENT_BLUE,
            height=6,
            border_radius=3,
        )
        
        # TERMINAL
        self.terminal = TerminalOutput()
        
        # STATS PANEL
        self.stats = StatsPanel()
        
        # CONTROL BUTTONS
        self.deploy_btn = ft.ElevatedButton(
            "START DEPLOYMENT",
            icon=ft.Icons.PLAY_ARROW,
            on_click=self._on_deploy,
            style=ft.ButtonStyle(
                color="white",
                bgcolor=ACCENT_GREEN,
                padding=ft.padding.symmetric(horizontal=24, vertical=16),
                shape=ft.RoundedRectangleBorder(radius=10),
            ),
            width=220,
            height=50,
        )
        
        self.clear_btn = ft.ElevatedButton(
            "Clear Terminal",
            icon=ft.Icons.DELETE_SWEEP,
            on_click=self._on_clear,
            style=ft.ButtonStyle(
                color=TEXT_SECONDARY,
                bgcolor=BG_TERTIARY,
                padding=ft.padding.symmetric(horizontal=20, vertical=16),
                shape=ft.RoundedRectangleBorder(radius=10),
            ),
        )
        
        self.save_log_btn = ft.ElevatedButton(
            "Save Log",
            icon=ft.Icons.SAVE,
            on_click=self._on_save_log,
            style=ft.ButtonStyle(
                color=TEXT_SECONDARY,
                bgcolor=BG_TERTIARY,
                padding=ft.padding.symmetric(horizontal=20, vertical=16),
                shape=ft.RoundedRectangleBorder(radius=10),
            ),
        )
        
        button_row = ft.Row([
            self.deploy_btn,
            ft.Container(width=12),
            self.clear_btn,
            ft.Container(width=12),
            self.save_log_btn,
        ], alignment=ft.MainAxisAlignment.CENTER)
        
        # LEFT PANEL
        left_panel = ft.Container(
            content=ft.Column([
                ft.Text("PIPELINE STEPS", size=12, weight=ft.FontWeight.BOLD,
                       color=TEXT_MUTED),
                ft.Container(height=8),
                steps_column,
                ft.Container(height=16),
                self.progress_bar,
            ], spacing=0),
            width=480,
            padding=24,
        )
        
        # RIGHT PANEL
        right_panel = ft.Container(
            content=ft.Column([
                self.stats,
                ft.Container(height=16),
                ft.Text("LIVE OUTPUT", size=12, weight=ft.FontWeight.BOLD,
                       color=TEXT_MUTED),
                ft.Container(height=8),
                self.terminal,
                ft.Container(height=16),
                button_row,
            ], spacing=0),
            expand=True,
            padding=ft.padding.only(left=0, top=24, right=24, bottom=24),
        )
        
        # MAIN LAYOUT
        main_content = ft.Row([
            left_panel,
            ft.VerticalDivider(width=1, color=BORDER),
            right_panel,
        ], expand=True, spacing=0)
        
        # FOOTER
        footer = ft.Container(
            content=ft.Row([
                ft.Text("MahekSync Deployer v2.0", size=11, color=TEXT_MUTED),
                ft.Container(expand=True),
                ft.Text("Made with ❤️ for Flutter Developers", size=11, color=TEXT_MUTED),
            ]),
            bgcolor=BG_SECONDARY,
            border=ft.border.only(top=ft.BorderSide(1, BORDER)),
            padding=ft.padding.symmetric(horizontal=24, vertical=12),
        )
        
        # ASSEMBLE
        self.page.add(
            ft.Column([
                header,
                ft.Container(content=main_content, expand=True),
                footer,
            ], spacing=0, expand=True)
        )
    
    # EVENT HANDLERS
    def _on_deploy(self, e):
        if self.is_deploying:
            return
        
        self.is_deploying = True
        self.start_time = time.time()
        self.current_step_index = 0
        
        for card in self.step_cards:
            card.update_status(StepStatus.PENDING)
            card.step.output = ""
            card.step.duration = 0
        
        self.terminal.clear()
        self.progress_bar.value = 0
        self.progress_bar.color = ACCENT_BLUE
        self.deploy_btn.disabled = True
        self.deploy_btn.text = "DEPLOYING..."
        self.deploy_btn.icon = ft.Icons.HOURGLASS_TOP
        self.page.update()
        
        thread = threading.Thread(target=self._run_pipeline, daemon=True)
        thread.start()
    
    def _on_clear(self, e):
        self.terminal.clear()
        self.terminal.add_line("Terminal cleared. Ready for new deployment.", TEXT_MUTED)
        self.terminal.update()
    
    def _on_save_log(self, e):
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"deploy_log_{timestamp}.txt"
            
            log_content = []
            for line in self.terminal.scroll_container.controls:
                if isinstance(line, ft.Text):
                    log_content.append(line.value)
            
            with open(filename, "w", encoding="utf-8") as f:
                f.write(f"MahekSync Deployer Log\n")
                f.write(f"Generated: {datetime.now()}\n")
                f.write("=" * 60 + "\n\n")
                f.write("\n".join(log_content))
            
            self.terminal.add_success(f"Log saved to: {filename}")
            self.terminal.update()
        except Exception as ex:
            self.terminal.add_error(f"Failed to save log: {ex}")
            self.terminal.update()
    
    # PIPELINE EXECUTION
    def _run_pipeline(self):
        total_steps = len(self.steps)
        completed = 0
        success_count = 0
        
        self._safe_terminal_call(
            lambda: (
                self.terminal.add_separator(),
                self.terminal.add_line("🚀 DEPLOYMENT PIPELINE STARTED", ACCENT_BLUE, bold=True),
                self.terminal.add_line(f"Total Steps: {total_steps} | Time: {datetime.now()}"),
                self.terminal.add_separator(),
            )
        )
        
        for i, step in enumerate(self.steps):
            self.current_step_index = i
            step_start = time.time()
            
            self._update_step_card(i, StepStatus.RUNNING)
            self._safe_terminal_call(
                lambda s=step: (
                    self.terminal.add_separator(),
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
                    self._update_step_card(i, StepStatus.SUCCESS, duration, step.output)
                    self._safe_terminal_call(
                        lambda d=duration: self.terminal.add_success(
                            f"Step completed in {d:.2f}s (exit: 0)"
                        )
                    )
                else:
                    step.status = StepStatus.FAILED
                    self._update_step_card(i, StepStatus.FAILED, duration, step.output)
                    self._safe_terminal_call(
                        lambda d=duration, c=process.returncode: self.terminal.add_error(
                            f"Step failed in {d:.2f}s (exit: {c})"
                        )
                    )
                    break
                    
            except Exception as ex:
                step.status = StepStatus.FAILED
                duration = time.time() - step_start
                self._update_step_card(i, StepStatus.FAILED, duration, str(ex))
                self._safe_terminal_call(
                    lambda e=ex: self.terminal.add_error(f"Exception: {e}")
                )
                break
            
            completed += 1
            self._update_progress(completed / total_steps)
            self._update_stats(completed, total_steps, success_count)
        
        total_duration = time.time() - self.start_time
        self._finish_pipeline(completed == total_steps and success_count == total_steps, 
                             total_duration)
    
    def _update_step_card(self, index: int, status: StepStatus, duration: float = 0, 
                          output: str = ""):
        def update():
            self.step_cards[index].update_status(status, duration, output)
        self._safe_call(update)
    
    def _update_progress(self, value: float):
        def update():
            self.progress_bar.value = value
            self.page.update()
        self._safe_call(update)
    
    def _update_stats(self, completed: int, total: int, success: int):
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
            self.progress_bar.color = ACCENT_GREEN if all_success else ACCENT_RED
            
            self.terminal.add_separator()
            if all_success:
                self.terminal.add_line(
                    f"🎉 ALL STEPS COMPLETED SUCCESSFULLY! ({duration:.2f}s)",
                    ACCENT_GREEN, bold=True
                )
                self.page.snack_bar = ft.SnackBar(
                    content=ft.Text("🚀 Deployment Successful!", color="white", size=14),
                    bgcolor=ACCENT_GREEN,
                    action="Dismiss",
                )
            else:
                self.terminal.add_line(
                    f"💥 PIPELINE FAILED after {duration:.2f}s",
                    ACCENT_RED, bold=True
                )
                self.page.snack_bar = ft.SnackBar(
                    content=ft.Text("❌ Deployment Failed!", color="white", size=14),
                    bgcolor=ACCENT_RED,
                    action="Dismiss",
                )
            
            self.page.snack_bar.open = True
            
            self.deploy_btn.disabled = False
            self.deploy_btn.text = "START DEPLOYMENT"
            self.deploy_btn.icon = ft.Icons.PLAY_ARROW
            
            self.page.update()
        
        self._safe_call(finish)
    
    def _safe_terminal_call(self, func: Callable):
        """Thread-safe terminal update"""
        def wrapper():
            func()
            try:
                self.terminal.update()
            except:
                pass
        self._safe_call(wrapper)
    
    def _safe_call(self, func: Callable):
        """Thread-safe UI update for Flet 0.28+"""
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