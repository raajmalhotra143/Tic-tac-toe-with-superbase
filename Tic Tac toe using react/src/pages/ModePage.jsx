import React from 'react';

export default function ModePage({ onSelectMode, onBack }) {
    return (
        <div className="page">
            <button className="back-btn" onClick={onBack}>← Back</button>
            <h1 className="page-title">Choose Mode</h1>
            <p className="page-subtitle">How do you want to play?</p>
            <div className="section-gap" />
            <div className="mode-grid">
                <div
                    className="mode-card offline"
                    onClick={() => onSelectMode('offline')}
                    role="button" tabIndex={0}
                    onKeyDown={e => e.key === 'Enter' && onSelectMode('offline')}
                >
                    <span className="mode-icon">🤖</span>
                    <h2>Offline</h2>
                    <p>3 difficulty levels, 15 stages each</p>
                </div>
                <div
                    className="mode-card online"
                    onClick={() => onSelectMode('online')}
                    role="button" tabIndex={0}
                    onKeyDown={e => e.key === 'Enter' && onSelectMode('online')}
                >
                    <span className="mode-icon">🌐</span>
                    <h2>Online</h2>
                    <p>Real-time multiplayer</p>
                </div>
            </div>
        </div>
    );
}
