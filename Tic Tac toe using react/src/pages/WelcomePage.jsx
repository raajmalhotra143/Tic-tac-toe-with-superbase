import React from 'react';

export default function WelcomePage({ onPlay }) {
    return (
        <div className="page">
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '6px', zIndex: 1 }}>
                <div style={{ fontSize: '5rem', animation: 'float 2.4s ease-in-out infinite', marginBottom: '8px' }}>🎮</div>
                <h1 className="welcome-logo">TIC·TAC·TOE</h1>
                <p className="welcome-sub">Battle smarter. Play bolder. Win legendary.</p>
                <div style={{ height: '16px' }} />
                <button className="btn btn-primary btn-lg" onClick={onPlay}>
                    ▶ Play Now
                </button>
                <div style={{ marginTop: '48px', display: 'flex', gap: '24px', flexWrap: 'wrap', justifyContent: 'center' }}>
                    {[
                        { icon: '🤖', label: '15-Stage AI' },
                        { icon: '🌐', label: 'Realtime Multiplayer' },
                        { icon: '⭐', label: 'Star Ratings' },
                    ].map(f => (
                        <div key={f.label} style={{
                            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '6px',
                            animation: 'fade-in 0.6s ease both',
                        }}>
                            <span style={{ fontSize: '2rem' }}>{f.icon}</span>
                            <span style={{ fontSize: '0.78rem', color: 'var(--muted)', fontWeight: 600 }}>{f.label}</span>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}
