use std::{
    env, fs, io,
    path::PathBuf,
    time::{Duration, Instant},
};

use ratatui::{
    TerminalOptions, Viewport,
    prelude::*,
    widgets::{Block, Borders, Paragraph},
};

use tachyonfx::{Effect, EffectManager, Interpolation, dsl::EffectDsl, fx};

#[derive(Clone, Copy)]
enum Preset {
    Boot,
    Reveal,
    Success,
    Warning,
    Critical,
    Shutdown,
    ModeChange,
    Galaxy,
}

impl Preset {
    fn parse(value: &str) -> Self {
        match value {
            "boot" => Self::Boot,
            "reveal" => Self::Reveal,
            "success" => Self::Success,
            "warn" | "warning" => Self::Warning,
            "critical" | "error" => Self::Critical,
            "shutdown" => Self::Shutdown,
            "mode" | "mode-change" => Self::ModeChange,
            "galaxy" => Self::Galaxy,
            _ => Self::Galaxy,
        }
    }

    fn name(self) -> &'static str {
        match self {
            Self::Boot => "boot",
            Self::Reveal => "reveal",
            Self::Success => "success",
            Self::Warning => "warning",
            Self::Critical => "critical",
            Self::Shutdown => "shutdown",
            Self::ModeChange => "mode-change",
            Self::Galaxy => "galaxy",
        }
    }

    fn default_message(self) -> &'static str {
        match self {
            Self::Boot => "ARCHMAC // GALAXY INITIALISING",
            Self::Reveal => "GALAXY ONLINE",
            Self::Success => "SYSTEM NOMINAL",
            Self::Warning => "ATTENTION REQUIRED",
            Self::Critical => "CRITICAL CONDITION",
            Self::Shutdown => "GALAXY OFFLINE",
            Self::ModeChange => "OPERATING MODE RESOLVED",
            Self::Galaxy => "A R C H M A C\n\nGALAXY SHELL",
        }
    }

    fn colour(self) -> Color {
        match self {
            Self::Boot => Color::Cyan,
            Self::Reveal => Color::Cyan,
            Self::Success => Color::Green,
            Self::Warning => Color::Yellow,
            Self::Critical => Color::Red,
            Self::Shutdown => Color::DarkGray,
            Self::ModeChange => Color::Magenta,
            Self::Galaxy => Color::Cyan,
        }
    }
}

fn fallback_effect(preset: Preset) -> Effect {
    match preset {
        Preset::Boot => fx::parallel(&[
            fx::coalesce((700, Interpolation::QuadOut)),
            fx::fade_from_fg(Color::DarkGray, (700, Interpolation::SineOut)),
        ]),

        Preset::Reveal => fx::parallel(&[
            fx::coalesce((550, Interpolation::QuadOut)),
            fx::fade_from_fg(Color::DarkGray, (600, Interpolation::SineOut)),
        ]),

        Preset::Success => fx::sequence(&[
            fx::coalesce((350, Interpolation::QuadOut)),
            fx::fade_from_fg(Color::DarkGray, (300, Interpolation::SineOut)),
        ]),

        Preset::Warning => fx::sequence(&[
            fx::coalesce((300, Interpolation::QuadOut)),
            fx::fade_from_fg(Color::Red, (400, Interpolation::SineOut)),
        ]),

        Preset::Critical => fx::sequence(&[
            fx::coalesce((250, Interpolation::QuadOut)),
            fx::fade_from_fg(Color::White, (250, Interpolation::SineOut)),
            fx::fade_to_fg(Color::Red, (350, Interpolation::SineInOut)),
        ]),

        Preset::Shutdown => fx::sequence(&[
            fx::fade_to_fg(Color::DarkGray, (350, Interpolation::SineIn)),
            fx::dissolve((600, Interpolation::QuadIn)),
        ]),

        Preset::ModeChange => fx::parallel(&[
            fx::coalesce((450, Interpolation::QuadOut)),
            fx::fade_from_fg(Color::DarkGray, (500, Interpolation::SineOut)),
        ]),

        Preset::Galaxy => {
            // ARCHMAC signature "Galaxy Resolve":
            // noisy cell-resolution + phosphor-like colour settle.
            fx::parallel(&[
                fx::coalesce((850, Interpolation::QuadOut)),
                fx::fade_from_fg(Color::DarkGray, (900, Interpolation::SineOut)),
            ])
        }
    }
}

fn config_path(preset: Preset) -> Option<PathBuf> {
    let home = env::var_os("HOME")?;

    Some(
        PathBuf::from(home)
            .join(".config")
            .join("archmac")
            .join("effects")
            .join(format!("{}.fx", preset.name())),
    )
}

fn effect_for(preset: Preset) -> Effect {
    let Some(path) = config_path(preset) else {
        return fallback_effect(preset);
    };

    let Ok(source) = fs::read_to_string(&path) else {
        return fallback_effect(preset);
    };

    let dsl = EffectDsl::new();
    let compiler = dsl.compiler();

    match compiler.compile(&source) {
        Ok(effect) => effect,
        Err(error) => {
            eprintln!(
                "archmac-fx: invalid effect preset {}: {}",
                path.display(),
                error
            );
            fallback_effect(preset)
        }
    }
}

fn run_fullscreen(preset: Preset, message: &str) -> io::Result<()> {
    ratatui::run(|terminal| {
        let mut effects: EffectManager<()> = EffectManager::default();

        effects.add_effect(effect_for(preset));

        let started = Instant::now();
        let mut previous = Instant::now();

        loop {
            let now = Instant::now();
            let elapsed = now.duration_since(previous);
            previous = now;

            terminal.draw(|frame| {
                let area = frame.area();

                let width = message
                    .lines()
                    .map(|line| line.chars().count())
                    .max()
                    .unwrap_or(20)
                    .saturating_add(8)
                    .min(area.width.saturating_sub(2) as usize)
                    .max(24) as u16;

                let height = message
                    .lines()
                    .count()
                    .saturating_add(4)
                    .min(area.height.saturating_sub(2) as usize)
                    .max(5) as u16;

                let x = area.x + area.width.saturating_sub(width) / 2;
                let y = area.y + area.height.saturating_sub(height) / 2;

                let panel = Rect::new(x, y, width, height);

                let widget = Paragraph::new(message)
                    .alignment(Alignment::Center)
                    .style(
                        Style::default()
                            .fg(preset.colour())
                            .add_modifier(Modifier::BOLD),
                    )
                    .block(
                        Block::default()
                            .borders(Borders::ALL)
                            .title(format!(" {} ", preset.name().to_uppercase()))
                            .border_style(Style::default().fg(preset.colour())),
                    );

                frame.render_widget(widget, panel);

                effects.process_effects(elapsed.into(), frame.buffer_mut(), panel);
            })?;

            std::thread::sleep(Duration::from_millis(16));

            if !effects.is_running() || started.elapsed() >= Duration::from_secs(4) {
                break;
            }
        }

        Ok(())
    })
}

fn run_inline(preset: Preset, message: &str) -> io::Result<()> {
    let line_count = message.lines().count().max(1);
    let height = (line_count + 2).min(u16::MAX as usize) as u16;

    let options = TerminalOptions {
        viewport: Viewport::Inline(height),
    };

    let mut terminal = ratatui::init_with_options(options);
    let mut effects: EffectManager<()> = EffectManager::default();

    effects.add_effect(effect_for(preset));

    let started = Instant::now();
    let mut previous = Instant::now();

    let result = (|| -> io::Result<()> {
        loop {
            let now = Instant::now();
            let elapsed = now.duration_since(previous);
            previous = now;

            terminal.draw(|frame| {
                let area = frame.area();

                let widget = Paragraph::new(message).alignment(Alignment::Left).style(
                    Style::default()
                        .fg(preset.colour())
                        .add_modifier(Modifier::BOLD),
                );

                frame.render_widget(widget, area);

                effects.process_effects(elapsed.into(), frame.buffer_mut(), area);
            })?;

            std::thread::sleep(Duration::from_millis(16));

            if !effects.is_running() || started.elapsed() >= Duration::from_secs(4) {
                break;
            }
        }

        Ok(())
    })();

    ratatui::restore();

    result
}

fn usage() {
    println!(
        "\
ARCHMAC Galaxy terminal effects

USAGE:
    archmac-fx <preset> [message...]
    archmac-fx --inline <preset> [message...]

PRESETS:
    boot
    reveal
    success
    warn
    critical
    shutdown
    mode-change
    galaxy

EXAMPLES:
    archmac-fx boot
    archmac-fx --inline success 'SYSTEM NOMINAL'
    archmac-fx --inline warn 'PORTAL RECONNECTING'
    archmac-fx reveal 'GALAXY ONLINE'
    archmac-fx success 'SYSTEM NOMINAL'
    archmac-fx warn 'PORTAL RECONNECTING'
    archmac-fx critical 'BATTERY CRITICAL'
    archmac-fx mode-change 'PERFORMANCE MODE'
    archmac-fx shutdown
"
    );
}

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().skip(1).collect();

    if args.is_empty() {
        return run_fullscreen(Preset::Galaxy, Preset::Galaxy.default_message());
    }

    if matches!(args[0].as_str(), "-h" | "--help" | "help") {
        usage();
        return Ok(());
    }

    let inline = args[0] == "--inline";

    let preset_index = if inline { 1 } else { 0 };

    if args.len() <= preset_index {
        usage();
        return Ok(());
    }

    let preset = Preset::parse(&args[preset_index]);

    let supplied = args
        .iter()
        .skip(preset_index + 1)
        .cloned()
        .collect::<Vec<_>>()
        .join(" ");

    let message = if supplied.is_empty() {
        preset.default_message()
    } else {
        &supplied
    };

    if inline {
        run_inline(preset, message)
    } else {
        run_fullscreen(preset, message)
    }
}
