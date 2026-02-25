import React from 'react';
import { getProgress } from '../progress';

export default function StageSelectPage({ difficulty, onSelectStage, onBack }) {
    const progress = getProgress();
    const stages = progress[difficulty]?.stages || Array(15).fill({ done: false, stars: 0 });

    // First incomplete stage index
    const firstIncomplete = stages.findIndex(s => !s.done);
    const currentIdx = firstIncomplete === -1 ? 14 : firstIncomplete;

    const diffLabel = { easy: '🌱 Easy', normal: '⚔️ Normal', impossible: '💀 Impossible' }[difficulty];

    return (
        <div className="page">
            <button className="back-btn" onClick={onBack}>← Back</button>
            <h1 className="page-title">{diffLabel}</h1>
            <p className="page-subtitle">Select a stage to play</p>
            <div className="section-gap" />
            <div className="stage-grid">
                {stages.map((s, i) => {
                    const locked = i > currentIdx && !s.done;
                    const isCurrent = i === currentIdx && !s.done;
                    return (
                        <div
                            key={i}
                            className={`stage-chip ${s.done ? 'completed' : ''} ${isCurrent ? 'current' : ''} ${locked ? 'locked' : ''}`}
                            onClick={() => !locked && onSelectStage(i)}
                            role="button" tabIndex={locked ? -1 : 0}
                            onKeyDown={e => e.key === 'Enter' && !locked && onSelectStage(i)}
                            aria-label={`Stage ${i + 1}${s.done ? `, ${s.stars} stars` : locked ? ', locked' : ''}`}
                        >
                            <span className="stage-num">{i + 1}</span>
                            {s.done && (
                                <span className="stage-stars">
                                    {'⭐'.repeat(s.stars)}{'☆'.repeat(3 - s.stars)}
                                </span>
                            )}
                            {locked && <span style={{ fontSize: '0.7rem' }}>🔒</span>}
                        </div>
                    );
                })}
            </div>
        </div>
    );
}
