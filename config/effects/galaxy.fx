fx::sequence(&[
    fx::parallel(&[
        fx::coalesce((700, QuadOut))
            .with_pattern(CoalescePattern::new()),
        fx::fade_from_fg(
            Color::DarkGray,
            (650, SineOut)
        )
    ]),
    fx::sequence(&[
        fx::fade_to_fg(
            Color::White,
            (90, SineOut)
        ),
        fx::fade_to_fg(
            Color::Cyan,
            (180, SineInOut)
        )
    ])
])
