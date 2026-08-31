fx::parallel(&[
    fx::coalesce((500, QuadOut))
        .with_pattern(SweepPattern::left_to_right()),
    fx::fade_from_fg(
        Color::DarkGray,
        (550, SineOut)
    )
])
