import React from 'react';
import { getProgress } from '../progress';

const LEVELS = [
    { key: 'easy', label: 'Easy', icon: '🌱', desc: 'Beginner friendly AI', color: 'easy' },
    { key: 'normal', label: 'Normal', icon: '⚔️', desc: 'Smart AI, a real challenge', color: 'normal' },
    { key: 'impossible', label: 'Impossible', icon: '💀', desc: 'Unbeatable at stage 15', color: 'impossible' },
];

export default function LevelSelectPage({ onSelectLevel, onBack }) {
    const progress = getProgress();

    return (
        <div className="page">
            <button className="back-btn" onClick={onBack}>← Back</button>
            <h1 className="page-title">Select Level</h1>
            <p className="page-subtitle">Complete all 15 stages to unlock next level</p>
            <div className="section-gap" />
            <div className="level-grid">
                {LEVELS.map(lv => {
                    const levels = ['easy', 'normal', 'impossible'];
                    const unlockedIdx = levels.indexOf(progress.unlockedLevel);
                    const lvIdx = levels.indexOf(lv.key);
                    const locked = lvIdx > unlockedIdx;
                    const stages = progress[lv.key]?.stages || [];
                    const done = stages.filter(s => s.done).length;

                    return (
                        <div
                            key={lv.key}
                            className={`level-card ${lv.color} ${locked ? 'locked' : ''}`}
                            onClick={() => !locked && onSelectLevel(lv.key)}
                            role="button" tabIndex={locked ? -1 : 0}
                            onKeyDown={e => e.key === 'Enter' && !locked && onSelectLevel(lv.key)}
                            aria-disabled={locked}
                        >
                            {locked && <span className="locked-label">🔒 Locked</span>}
                            <span className="level-icon">{lv.icon}</span>
                            <h3>{lv.label}</h3>
                            <p style={{ fontSize: '0.78rem', color: 'var(--muted)', marginTop: 4 }}>{lv.desc}</p>
                            <div className="level-progress">{done}/15 stages</div>
                            <div className="progress-bar-wrap" style={{ marginTop: 10 }}>
                                <div className="progress-bar-fill" style={{ width: `${(done / 15) * 100}%` }} />
                            </div>
                        </div>
                    );
                })}
            </div>
        </div>
    );
}
