fx::sequence(&[
    fx::coalesce((260, QuadOut))
        .with_pattern(DiamondPattern::center()),
    fx::sequence(&[
        fx::fade_to_fg(
            Color::White,
            (70, SineOut)
        ),
        fx::fade_to_fg(
            Color::Green,
            (150, SineInOut)
        )
    ])
])
