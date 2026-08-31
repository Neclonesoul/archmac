fx::sequence(&[
    fx::parallel(&[
        fx::coalesce((380, QuadOut))
            .with_pattern(SweepPattern::left_to_right()),
        fx::fade_from_fg(
            Color::DarkGray,
            (350, SineOut)
        )
    ]),
    fx::fade_to_fg(
        Color::Magenta,
        (130, SineInOut)
    )
])
