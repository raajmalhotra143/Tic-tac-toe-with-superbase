import React, { useEffect, useRef, useState } from 'react';

export default function Toast({ message, duration = 2500 }) {
    const [show, setShow] = useState(false);
    const timerRef = useRef(null);

    useEffect(() => {
        if (!message) return;
        setShow(true);
        clearTimeout(timerRef.current);
        timerRef.current = setTimeout(() => setShow(false), duration);
    }, [message, duration]);

    if (!message) return null;
    return <div className={`toast ${show ? 'show' : ''}`}>{message}</div>;
}
