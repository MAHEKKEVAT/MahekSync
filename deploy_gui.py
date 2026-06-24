#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║                    MAHEKSYNC DEPLOYER v3.0                                   ║
║              ⚡ HACKER-STYLE DEPLOYMENT PIPELINE ⚡                           ║
║                        Made by Mahek                                          ║
╚══════════════════════════════════════════════════════════════════════════════╝
"""

import flet as ft
import subprocess
import threading
import time
import math
from datetime import datetime
from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional, Callable, List


# ═══════════════════════════════════════════════════════════════════════════════
# DATA MODELS (Must be defined BEFORE widgets that use them)
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


# ═══════════════════════════════════════════════════════════════════════════════
# CYBERPUNK COLOR PALETTE
# ═══════════════════════════════════════════════════════════════════════════════

BG_PRIMARY = "#050505"
BG_SECONDARY = "#0a0a0f"
BG_TERTIARY = "#111118"
BG_CARD = "#0d1117"
BORDER = "#1a1a2e"
BORDER_GLOW = "#00ff41"
TEXT_PRIMARY = "#e0e0e0"
TEXT_SECONDARY = "#8b949e"
TEXT_MUTED = "#484f58"
ACCENT_GREEN = "#00ff41"      # Matrix green
ACCENT_CYAN = "#00f0ff"       # Cyan glow
ACCENT_RED = "#ff0040"        # Error red
ACCENT_YELLOW = "#ffee00"     # Warning yellow
ACCENT_PURPLE = "#bd00ff"     # Purple accent
ACCENT_BLUE = "#0080ff"       # Blue glow


# ═══════════════════════════════════════════════════════════════════════════════
# GLITCH TEXT EFFECT
# ═══════════════════════════════════════════════════════════════════════════════

class GlitchText(ft.Text):
    def __init__(self, text: str, size: int = 20, color: str = ACCENT_GREEN, 
                 weight=ft.FontWeight.BOLD):
        self._original_text = text
        self._glitch_chars = "!@#$%^&*()_+-=[]{}|;:,.<>?"
        super().__init__(
            value=text,
            size=size,
            color=color,
            weight=weight,
            font_family="Consolas",
        )
        self._running = False
    
    def start_glitch(self):
        self._running = True
        self._glitch_thread = threading.Thread(target=self._glitch_loop, daemon=True)
        self._glitch_thread.start()
    
    def _glitch_loop(self):
        while self._running:
            if random.random() < 0.3:
                glitched = list(self._original_text)
                for _ in range(random.randint(1, 3)):
                    idx = random.randint(0, len(glitched)-1)
                    glitched[idx] = random.choice(self._glitch_chars)
                self.value = "".join(glitched)
                try:
                    self.update()
                except:
                    pass
                time.sleep(0.1)
                self.value = self._original_text
                try:
                    self.update()
                except:
                    pass
            time.sleep(random.uniform(0.5, 2.0))
    
    def stop(self):
        self._running = False


# ═══════════════════════════════════════════════════════════════════════════════
# CUSTOM WIDGETS
# ═══════════════════════════════════════════════════════════════════════════════

class StepCard(ft.Container):
    """Cyberpunk step card with glow effects"""
    
    def __init__(self, step: DeployStep, index: int):
        self.step = step
        self.index = index
        self.status_icon = ft.Text("○", size=24, color=TEXT_MUTED, 
                                   weight=ft.FontWeight.BOLD)
        self.status_ring = ft.ProgressRing(
            width=28, height=28, stroke_width=2,
            color=ACCENT_GREEN, visible=False
        )
        self.duration_text = ft.Text("", size=11, color=TEXT_MUTED, 
                                     font_family="Consolas")
        self.output_preview = ft.Text(
            "", size=10, color=TEXT_SECONDARY,
            max_lines=1, overflow=ft.TextOverflow.ELLIPSIS,
            font_family="Consolas"
        )
        
        super().__init__(
            content=ft.Row([
                ft.Container(
                    content=ft.Stack([
                        self.status_ring,
                        ft.Container(
                            content=self.status_icon,
                            alignment=ft.alignment.center,
                            width=28, height=28,
                        )
                    ]),
                    width=44, height=44,
                ),
                ft.Column([
                    ft.Row([
                        ft.Text(
                            f"[{index:02d}]", 
                            size=11, 
                            weight=ft.FontWeight.BOLD,
                            color=ACCENT_CYAN,
                            font_family="Consolas"
                        ),
                        ft.Container(width=8),
                        ft.Text(
                            step.name.upper(), 
                            size=13, 
                            weight=ft.FontWeight.W_600,
                            color=TEXT_PRIMARY,
                            font_family="Consolas"
                        ),
                    ], spacing=0),
                    ft.Text(
                        step.description, 
                        size=11, 
                        color=TEXT_SECONDARY,
                        font_family="Consolas"
                    ),
                    ft.Row([
                        self.duration_text,
                        ft.Container(width=10),
                        self.output_preview,
                    ], spacing=0),
                ], spacing=3, expand=True),
                ft.Container(
                    content=ft.Text(
                        f"> {step.command[:25]}..." if len(step.command) > 25 else f"> {step.command}",
                        size=9, 
                        color=ACCENT_GREEN,
                        font_family="Consolas",
                        opacity=0.7
                    ),
                    bgcolor=BG_TERTIARY,
                    border_radius=4,
                    padding=ft.padding.symmetric(horizontal=10, vertical=4),
                    border=ft.border.all(1, BORDER),
                ),
            ], spacing=12),
            bgcolor=BG_CARD,
            border=ft.border.all(1, BORDER),
            border_radius=12,
            padding=16,
            shadow=ft.BoxShadow(
                spread_radius=0,
                blur_radius=20,
                color="transparent",
                offset=ft.Offset(0, 0),
            ),
        )
    
    def update_status(self, status: StepStatus, duration: float = 0, output: str = ""):
        self.step.status = status
        self.step.duration = duration
        self.step.output = output
        
        icons_map = {
            StepStatus.PENDING: ("○", TEXT_MUTED),
            StepStatus.RUNNING: ("▶", ACCENT_CYAN),
            StepStatus.SUCCESS: ("◉", ACCENT_GREEN),
            StepStatus.FAILED: ("✖", ACCENT_RED),
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
            self.output_preview.value = preview[:50]
        
        border_colors = {
            StepStatus.PENDING: BORDER,
            StepStatus.RUNNING: ACCENT_CYAN,
            StepStatus.SUCCESS: ACCENT_GREEN,
            StepStatus.FAILED: ACCENT_RED,
            StepStatus.SKIPPED: TEXT_MUTED,
        }
        
        glow_colors = {
            StepStatus.PENDING: "transparent",
            StepStatus.RUNNING: "rgba(0,240,255,0.1)",
            StepStatus.SUCCESS: "rgba(0,255,65,0.15)",
            StepStatus.FAILED: "rgba(255,0,64,0.15)",
            StepStatus.SKIPPED: "transparent",
        }
        
        self.border = ft.border.all(1, border_colors[status])
        self.shadow = ft.BoxShadow(
            spread_radius=0,
            blur_radius=30 if status == StepStatus.RUNNING else 15,
            color=glow_colors[status],
            offset=ft.Offset(0, 0),
        )
        
        if status == StepStatus.RUNNING:
            self.bgcolor = "#0a1f1a"
        elif status == StepStatus.SUCCESS:
            self.bgcolor = "#0a1a0f"
        elif status == StepStatus.FAILED:
            self.bgcolor = "#1a0a0f"
        else:
            self.bgcolor = BG_CARD
        
        self.update()


class TerminalOutput(ft.Column):
    """Hacker-style terminal with auto-scroll"""
    
    def __init__(self):
        self.scroll_container = ft.ListView(
            expand=True,
            spacing=1,
            auto_scroll=True,
        )
        self._line_count = 0
        
        super().__init__(
            controls=[
                ft.Container(
                    content=ft.Row([
                        ft.Row([
                            ft.Container(width=12, height=12, 
                                       bgcolor=ACCENT_RED, border_radius=6),
                            ft.Container(width=12, height=12, 
                                       bgcolor=ACCENT_YELLOW, border_radius=6),
                            ft.Container(width=12, height=12, 
                                       bgcolor=ACCENT_GREEN, border_radius=6),
                        ], spacing=8),
                        ft.Container(width=20),
                        ft.Text("root@mahek-sync:~# deploy_pipeline", 
                               size=11, color=TEXT_MUTED, font_family="Consolas"),
                        ft.Container(expand=True),
                        ft.Text("● LIVE", size=10, color=ACCENT_GREEN, 
                               weight=ft.FontWeight.BOLD, font_family="Consolas"),
                    ], spacing=6),
                    bgcolor=BG_TERTIARY,
                    padding=ft.padding.symmetric(horizontal=16, vertical=10),
                    border_radius=ft.border_radius.only(top_left=10, top_right=10),
                    border=ft.border.only(bottom=ft.BorderSide(1, BORDER)),
                ),
                ft.Container(
                    content=self.scroll_container,
                    bgcolor="#000000",
                    border=ft.border.all(1, BORDER),
                    border_radius=ft.border_radius.only(bottom_left=10, bottom_right=10),
                    padding=ft.padding.symmetric(horizontal=12, vertical=8),
                    expand=True,
                    shadow=ft.BoxShadow(
                        spread_radius=0,
                        blur_radius=30,
                        color="rgba(0,255,65,0.05)",
                        offset=ft.Offset(0, 0),
                    ),
                ),
            ],
            spacing=0,
            expand=True,
        )
    
    def _create_line(self, text: str, color: str = TEXT_SECONDARY, 
                    prefix: str = "", bold: bool = False):
        self._line_count += 1
        return ft.Text(
            f"{prefix}{text}",
            size=12,
            color=color,
            weight=ft.FontWeight.BOLD if bold else ft.FontWeight.NORMAL,
            font_family="Consolas",
            selectable=True,
            no_wrap=False,
        )
    
    def add_line(self, text: str, color: str = TEXT_SECONDARY, 
                 prefix: str = "", bold: bool = False):
        line = self._create_line(text, color, prefix, bold)
        self.scroll_container.controls.append(line)
        if len(self.scroll_container.controls) > 500:
            self.scroll_container.controls.pop(0)
        if hasattr(self.scroll_container, 'scroll_to'):
            try:
                self.scroll_container.scroll_to(offset=-1, duration=100)
            except:
                pass
    
    def add_command(self, cmd: str):
        self.add_line(f"$ {cmd}", ACCENT_CYAN, bold=True)
    
    def add_output(self, text: str):
        if text.strip():
            self.add_line(text, TEXT_SECONDARY, "  ")
    
    def add_success(self, text: str):
        self.add_line(f"[OK] {text}", ACCENT_GREEN, bold=True)
    
    def add_error(self, text: str):
        self.add_line(f"[ERR] {text}", ACCENT_RED, bold=True)
    
    def add_warning(self, text: str):
        self.add_line(f"[WARN] {text}", ACCENT_YELLOW, bold=True)
    
    def add_separator(self):
        self.add_line("═" * 70, BORDER)
    
    def add_hacker_banner(self, text: str):
        self.add_line("", BORDER)
        self.add_line(f"  >>> {text} <<<", ACCENT_GREEN, bold=True)
        self.add_line("", BORDER)
    
    def clear(self):
        self.scroll_container.controls.clear()
        self._line_count = 0


class StatsPanel(ft.Container):
    """Cyberpunk stats dashboard"""
    
    def __init__(self):
        self.total_time = ft.Text("00.0s", size=28, weight=ft.FontWeight.BOLD, 
                                  color=ACCENT_CYAN, font_family="Consolas")
        self.steps_completed = ft.Text("00/05", size=28, weight=ft.FontWeight.BOLD,
                                       color=ACCENT_PURPLE, font_family="Consolas")
        self.success_rate = ft.Text("000%", size=28, weight=ft.FontWeight.BOLD,
                                    color=ACCENT_GREEN, font_family="Consolas")
        
        super().__init__(
            content=ft.Row([
                self._stat_box("◉ TOTAL TIME", self.total_time, ACCENT_CYAN),
                ft.VerticalDivider(color=BORDER, width=1, thickness=1),
                self._stat_box("◉ STEPS DONE", self.steps_completed, ACCENT_PURPLE),
                ft.VerticalDivider(color=BORDER, width=1, thickness=1),
                self._stat_box("◉ SUCCESS", self.success_rate, ACCENT_GREEN),
            ], spacing=20, alignment=ft.MainAxisAlignment.SPACE_EVENLY),
            bgcolor=BG_CARD,
            border=ft.border.all(1, BORDER),
            border_radius=12,
            padding=20,
            shadow=ft.BoxShadow(
                spread_radius=0,
                blur_radius=20,
                color="rgba(0,240,255,0.05)",
                offset=ft.Offset(0, 0),
            ),
        )
    
    def _stat_box(self, label: str, value: ft.Text, color: str):
        return ft.Column([
            ft.Text(label, size=9, weight=ft.FontWeight.BOLD, 
                   color=TEXT_MUTED, font_family="Consolas"),
            ft.Container(height=4),
            value,
        ], horizontal_alignment=ft.CrossAxisAlignment.CENTER, spacing=0)
    
    def update_stats(self, total_time: float, completed: int, total: int, success: int):
        self.total_time.value = f"{total_time:05.1f}s"
        self.steps_completed.value = f"{completed:02d}/{total:02d}"
        rate = int(success / total * 100) if total > 0 else 0
        self.success_rate.value = f"{rate:03d}%"
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
        self.page.title = "⚡ MahekSync Deployer v3.0 // HACKER MODE"
        self.page.theme_mode = ft.ThemeMode.DARK
        self.page.window_maximized = True
        self.page.padding = 0
        self.page.bgcolor = BG_PRIMARY
    
    def _build_ui(self):
        # HEADER - Hacker style
        self.title_glitch = GlitchText("MAHEKSYNC", size=26, color=ACCENT_GREEN)
        self.title_glitch.start_glitch()
        
        header = ft.Container(
            content=ft.Row([
                ft.Row([
                    ft.Text("◈", size=30, color=ACCENT_GREEN, 
                           weight=ft.FontWeight.BOLD),
                    ft.Column([
                        self.title_glitch,
                        ft.Text("DEPLOYMENT_PROTOCOL_v3.0", 
                               size=9, color=ACCENT_CYAN, 
                               font_family="Consolas",
                               weight=ft.FontWeight.BOLD),
                    ], spacing=0),
                ], spacing=12),
                ft.Container(expand=True),
                ft.Container(
                    content=ft.Row([
                        ft.Text("◉", size=10, color=ACCENT_GREEN),
                        ft.Text("SYSTEM_READY", size=10, 
                               color=ACCENT_GREEN,
                               font_family="Consolas",
                               weight=ft.FontWeight.BOLD),
                    ], spacing=6),
                    bgcolor=BG_TERTIARY,
                    border_radius=4,
                    padding=ft.padding.symmetric(horizontal=16, vertical=8),
                    border=ft.border.all(1, ACCENT_GREEN),
                    shadow=ft.BoxShadow(
                        spread_radius=0,
                        blur_radius=15,
                        color="rgba(0,255,65,0.2)",
                        offset=ft.Offset(0, 0),
                    ),
                ),
            ], alignment=ft.MainAxisAlignment.SPACE_BETWEEN),
            bgcolor=BG_SECONDARY,
            border=ft.border.only(bottom=ft.BorderSide(1, BORDER)),
            padding=ft.padding.symmetric(horizontal=24, vertical=14),
        )
        
        # STEP DEFINITIONS
        self.steps = [
            DeployStep(
                "FLUTTER_BUILD",
                'flutter build web --base-href "/MahekSync/"',
                "Compile Flutter app for web deployment"
            ),
            DeployStep(
                "COPY_ASSETS",
                "xcopy build\\web\\* docs\\ /E /H /Y",
                "Mirror build output to docs directory"
            ),
            DeployStep(
                "GIT_STAGE",
                "git add .",
                "Stage all modified files for commit"
            ),
            DeployStep(
                "GIT_COMMIT",
                'git commit -m "Add"',
                "Create commit with message"
            ),
            DeployStep(
                "GIT_PUSH",
                "git push origin main",
                "Deploy to origin/main branch"
            ),
        ]
        
        # STEP CARDS
        self.step_cards = [StepCard(step, i+1) for i, step in enumerate(self.steps)]
        steps_column = ft.Column(self.step_cards, spacing=10)
        
        # PROGRESS BAR - Cyber style
        self.progress_bar = ft.ProgressBar(
            value=0,
            bgcolor="#001100",
            color=ACCENT_GREEN,
            height=4,
            border_radius=2,
        )
        
        # PROGRESS LABEL
        self.progress_label = ft.Text(
            "IDLE // WAITING FOR INPUT", 
            size=10, 
            color=TEXT_MUTED,
            font_family="Consolas",
            weight=ft.FontWeight.BOLD
        )
        
        # TERMINAL
        self.terminal = TerminalOutput()
        
        # STATS PANEL
        self.stats = StatsPanel()
        
        # CONTROL BUTTONS - Hacker style
        self.deploy_btn = ft.ElevatedButton(
            "▶ EXECUTE_PIPELINE",
            icon=ft.Icons.PLAY_ARROW,
            on_click=self._on_deploy,
            style=ft.ButtonStyle(
                color="black",
                bgcolor=ACCENT_GREEN,
                padding=ft.padding.symmetric(horizontal=30, vertical=18),
                shape=ft.RoundedRectangleBorder(radius=6),
                text_style=ft.TextStyle(
                    font_family="Consolas",
                    weight=ft.FontWeight.BOLD,
                    size=13,
                ),
            ),
            width=260,
            height=52,
        )
        
        self.clear_btn = ft.ElevatedButton(
            "⊘ CLEAR_LOGS",
            icon=ft.Icons.DELETE_SWEEP,
            on_click=self._on_clear,
            style=ft.ButtonStyle(
                color=TEXT_SECONDARY,
                bgcolor=BG_TERTIARY,
                padding=ft.padding.symmetric(horizontal=20, vertical=18),
                shape=ft.RoundedRectangleBorder(radius=6),
                text_style=ft.TextStyle(
                    font_family="Consolas",
                    size=12,
                ),
            ),
        )
        
        self.save_log_btn = ft.ElevatedButton(
            "💾 EXPORT_LOG",
            icon=ft.Icons.SAVE,
            on_click=self._on_save_log,
            style=ft.ButtonStyle(
                color=TEXT_SECONDARY,
                bgcolor=BG_TERTIARY,
                padding=ft.padding.symmetric(horizontal=20, vertical=18),
                shape=ft.RoundedRectangleBorder(radius=6),
                text_style=ft.TextStyle(
                    font_family="Consolas",
                    size=12,
                ),
            ),
        )
        
        button_row = ft.Row([
            self.deploy_btn,
            ft.Container(width=16),
            self.clear_btn,
            ft.Container(width=16),
            self.save_log_btn,
        ], alignment=ft.MainAxisAlignment.CENTER)
        
        # LEFT PANEL
        left_header = ft.Container(
            content=ft.Text("◈ PIPELINE_STEPS", size=11, weight=ft.FontWeight.BOLD,
                           color=ACCENT_CYAN, font_family="Consolas"),
            padding=ft.padding.only(bottom=12),
        )
        
        left_panel = ft.Container(
            content=ft.Column([
                left_header,
                steps_column,
                ft.Container(height=12),
                self.progress_label,
                ft.Container(height=6),
                self.progress_bar,
            ], spacing=0),
            width=420,
            padding=24,
        )
        
        # RIGHT PANEL
        right_panel = ft.Container(
            content=ft.Column([
                self.stats,
                ft.Container(height=16),
                ft.Text("◈ LIVE_OUTPUT_STREAM", size=11, weight=ft.FontWeight.BOLD,
                       color=ACCENT_CYAN, font_family="Consolas"),
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
            ft.Container(
                content=left_panel,
                border=ft.border.only(right=ft.BorderSide(1, BORDER)),
            ),
            right_panel,
        ], expand=True, spacing=0)
        
        # FOOTER
        footer = ft.Container(
            content=ft.Row([
                ft.Text("MahekSync Deployer v3.0 // Made by Mahek", 
                       size=10, color=TEXT_MUTED, font_family="Consolas"),
                ft.Container(expand=True),
                ft.Text("⚡ HACKER_MODE_ENABLED", 
                       size=10, color=ACCENT_GREEN, 
                       font_family="Consolas",
                       weight=ft.FontWeight.BOLD),
            ]),
            bgcolor=BG_SECONDARY,
            border=ft.border.only(top=ft.BorderSide(1, BORDER)),
            padding=ft.padding.symmetric(horizontal=24, vertical=10),
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
        self.progress_bar.color = ACCENT_GREEN
        self.progress_label.value = "EXECUTING // IN PROGRESS"
        self.progress_label.color = ACCENT_CYAN
        self.deploy_btn.disabled = True
        self.deploy_btn.text = "◉ EXECUTING..."
        self.deploy_btn.icon = ft.Icons.HOURGLASS_TOP
        self.page.update()
        
        thread = threading.Thread(target=self._run_pipeline, daemon=True)
        thread.start()
    
    def _on_clear(self, e):
        self.terminal.clear()
        self.terminal.add_line("> Logs cleared. System ready.", TEXT_MUTED)
        self.terminal.update()
    
    def _on_save_log(self, e):
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"mahek_deploy_log_{timestamp}.txt"
            
            log_content = []
            for line in self.terminal.scroll_container.controls:
                if isinstance(line, ft.Text):
                    log_content.append(line.value)
            
            with open(filename, "w", encoding="utf-8") as f:
                f.write("╔══════════════════════════════════════════════════════════════╗\n")
                f.write("║        MAHEKSYNC DEPLOYER v3.0 - DEPLOYMENT LOG              ║\n")
                f.write("╚══════════════════════════════════════════════════════════════╝\n")
                f.write(f"Generated: {datetime.now()}\n")
                f.write(f"Made by: Mahek\n")
                f.write("═" * 70 + "\n\n")
                f.write("\n".join(log_content))
            
            self.terminal.add_success(f"Log exported: {filename}")
            self.terminal.update()
        except Exception as ex:
            self.terminal.add_error(f"Export failed: {ex}")
            self.terminal.update()
    
    # PIPELINE EXECUTION
    def _run_pipeline(self):
        total_steps = len(self.steps)
        completed = 0
        success_count = 0
        
        self._safe_terminal_call(
            lambda: (
                self.terminal.add_hacker_banner("INITIATING DEPLOYMENT SEQUENCE"),
                self.terminal.add_line(f"Target: MahekSync Repository", ACCENT_CYAN, bold=True),
                self.terminal.add_line(f"Total Steps: {total_steps}", TEXT_SECONDARY),
                self.terminal.add_line(f"Timestamp: {datetime.now()}", TEXT_SECONDARY),
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
                    self.terminal.add_line(f"[EXEC] {s.name}", ACCENT_CYAN, bold=True),
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
                            f"Completed in {d:.2f}s | Exit: 0"
                        )
                    )
                else:
                    step.status = StepStatus.FAILED
                    self._update_step_card(i, StepStatus.FAILED, duration, step.output)
                    self._safe_terminal_call(
                        lambda d=duration, c=process.returncode: self.terminal.add_error(
                            f"Failed in {d:.2f}s | Exit: {c}"
                        )
                    )
                    break
                    
            except Exception as ex:
                step.status = StepStatus.FAILED
                duration = time.time() - step_start
                self._update_step_card(i, StepStatus.FAILED, duration, str(ex))
                self._safe_terminal_call(
                    lambda e=ex: self.terminal.add_error(f"System Error: {e}")
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
            self.progress_label.value = "COMPLETED" if all_success else "FAILED"
            self.progress_label.color = ACCENT_GREEN if all_success else ACCENT_RED
            
            self.terminal.add_separator()
            if all_success:
                self.terminal.add_hacker_banner("DEPLOYMENT SUCCESSFUL")
                self.terminal.add_line(
                    f"All systems operational. Deployed in {duration:.2f}s",
                    ACCENT_GREEN, bold=True
                )
                self.page.snack_bar = ft.SnackBar(
                    content=ft.Text("◉ DEPLOYMENT SUCCESSFUL", 
                                   color="black", size=14,
                                   weight=ft.FontWeight.BOLD,
                                   font_family="Consolas"),
                    bgcolor=ACCENT_GREEN,
                    action="DISMISS",
                )
            else:
                self.terminal.add_hacker_banner("DEPLOYMENT FAILED")
                self.terminal.add_line(
                    f"Pipeline terminated after {duration:.2f}s",
                    ACCENT_RED, bold=True
                )
                self.page.snack_bar = ft.SnackBar(
                    content=ft.Text("◉ DEPLOYMENT FAILED", 
                                   color="white", size=14,
                                   weight=ft.FontWeight.BOLD,
                                   font_family="Consolas"),
                    bgcolor=ACCENT_RED,
                    action="DISMISS",
                )
            
            self.page.snack_bar.open = True
            
            self.deploy_btn.disabled = False
            self.deploy_btn.text = "▶ EXECUTE_PIPELINE"
            self.deploy_btn.icon = ft.Icons.PLAY_ARROW
            self.deploy_btn.bgcolor = ACCENT_GREEN
            
            self.page.update()
        
        self._safe_call(finish)
    
    def _safe_terminal_call(self, func: Callable):
        def wrapper():
            func()
            try:
                self.terminal.update()
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