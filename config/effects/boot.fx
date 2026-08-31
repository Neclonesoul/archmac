fx::sequence(&[
    fx::parallel(&[
        fx::coalesce((900, QuadOut))
            .with_pattern(SpiralPattern::center()),
        fx::fade_from_fg(
            Color::Black,
            (850, SineOut)
        )
    ]),
    fx::fade_to_fg(
        Color::Cyan,
        (220, SineInOut)
    )
])
