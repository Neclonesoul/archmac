fx::sequence(&[
    fx::fade_to_fg(
        Color::DarkGray,
        (250, SineIn)
    ),
    fx::dissolve((550, QuadIn))
        .with_pattern(DissolvePattern::new())
])
