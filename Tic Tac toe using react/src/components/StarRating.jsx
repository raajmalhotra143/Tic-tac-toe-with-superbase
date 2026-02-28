import React, { useEffect, useState } from 'react';

export default function StarRating({ stars, max = 3 }) {
    const [visible, setVisible] = useState(0);

    useEffect(() => {
        setVisible(0);
        // stagger star animations
        stars > 0 && Array.from({ length: stars }).forEach((_, i) => {
            setTimeout(() => setVisible(v => v + 1), i * 220 + 200);
        });
        // show empty stars after
        setTimeout(() => setVisible(max), stars * 220 + 400);
    }, [stars, max]);

    return (
        <div className="stars-row">
            {Array.from({ length: max }).map((_, i) => (
                <span
                    key={i}
                    className={`star ${i < stars ? 'filled' : 'empty'}`}
                    style={{ animationDelay: `${i * 0.18}s`, opacity: i < visible ? 1 : 0 }}
                >
                    {i < stars ? '⭐' : '☆'}
                </span>
            ))}
        </div>
    );
}
